
class TasksModel
  
  constructor: ->
    @tasks = []
    @members = []
    @selectableMembers = []
    @subscribers = []

  subscribe: (callback) ->
    @subscribers.push callback

  unsubscribe: (callback) ->
    @subscribers = @subscribers.filter (item) -> item isnt callback

  notify: ->
    subscriber() for subscriber in @subscribers

  loadTasks: ->
    Api.tasks gon.project_id, (tasks) =>
      @tasks = tasks
      @notify()
    data = null

  getTasksTotal: ->
    @tasks.length

  getTasks: (filter = '', displayCompleted = true, sort = '', order = 'asc') ->
    tasks = @filterTasks(@tasks, filter, displayCompleted)
    tasks = @sortTasks(tasks, sort, order) if sort.length > 0
    tasks

  createTask: =>
    task = {name: "New task", original_estimate: 0}
    Api.create_task gon.project_id, task, (task) =>
      @tasks.push task
      @notify()

  removeTasks: (tasks) ->
    @removeTask(task) for task in tasks
    @notify()    

  addTask: (item) ->
    @tasks.push(item)

  updateTask: (item) ->
    task = @getTask(item.id)
    task.name = item.name
    task.description = item.description
    task.tags = item.tags
    task.assignee_id = item.assignee_id
    task.original_estimate = item.original_estimate
    task.remaining_estimate = item.remaining_estimate
    task.delta = item.delta
    Api.update_task gon.project_id, item.id, item, (task) =>
      @getTask(task.id).updated_at = task.updated_at
      @notify()

  removeTask: (item) ->
    Api.delete_task gon.project_id, item.id
    index = @tasks.indexOf(item)
    @tasks.splice(index, 1)

  getTask: (id) ->
    found = @tasks.where id:id
    if found.length > 0 then found[0] else null

  getTaskAt: (index) ->
    @tasks[index]

  setTask: (tasks) ->
    @tasks = tasks

  filterTasks: (tasks, filter = '', displayCompleted = true) ->
    data = tasks
    if filter.length > 0
      filtered = []
      for task in data
        addIt = task.code.indexOf(filter) > -1

        if !addIt
          addIt = task.name.indexOf(filter) > -1

        if !addIt
          tags = task.tag_list.split(',')
          for tag in tags
            tag = $.trim(tag)
            if tag.indexOf(filter) > -1
              addIt = true
              break

        if !addIt
          found = @members.where user_id:task.assignee_id
          addIt = found.length > 0 && found[0].username.indexOf(filter) > -1

        filtered.push(task) if addIt

      data = filtered
  
    if !displayCompleted
      filtered = []
      for task in data
        if task.remaining_estimate > 0 or task.original_estimate == 0
          filtered.push(task)
      data = filtered

    data

  sortTasks: (tasks, key, order) ->
    tasks.sort (a,b) ->
      m = if order == 'asc' then 1 else -1
      return -1 * m if  a[key] < b[key]
      return +1 * m if a[key] > b[key]
      return 0

  loadMembers: (callback) ->
    Api.project_members gon.project_id, (members) =>
      @members = members

      if gon.can_update_tasks
        @selectableMembers = members
      else
        found = @members.where user_id:gon.user_id
        @selectableMembers = found

      callback()

  findUsername: (user_id) ->
    found = @members.where user_id:user_id
    if found.length > 0 then found[0].username else null

  canChangeAssignee: (task) ->
    resu = true
    logged = task.work_logged
    if logged != 0
      resu = true
    else
      if gon.can_take_unassigned_task && !gon.can_update_tasks
        resu = task.assignee_id == "" or task.assignee_id == null or parseInt(task.assignee_id) == gon.user_id
      else
        resu = gon.can_update_tasks
    resu

class TasksGridView
  constructor: (@model) ->
    @model.subscribe @onUpdate
    @saveSelected = null

  getTable: ->
    $('#tasksGrid').handsontable('getInstance')

  getTasks: ->
    filter = $('#tasksFilter').val()
    displayCompleted = $('#display_completed').hasClass('active')
    @model.getTasks(filter, displayCompleted)

  initialize: ->
    @initGrid()

  initGrid: ->
    grid = $('#tasksGrid')
    grid.handsontable({
      data: @model.loadTasks()
      stretchH: 'all',
      columnSorting: true,
      startRows: 0,
      startCols: 8,
      outsideClickDeselects: false,
      colHeaders: ["ID", "Name", "Tags", "Created at", "Assigned to", "Estimate", "Work logged", "Remaining", "Delta"]
      columns: [
        {
          data: "code"
          renderer: @codeRenderer
          readOnly: true
        },
        {
          data: "name"
          renderer: @nameRenderer
          validator: @requiredTextValidator
          allowInvalid: false 
          readOnly:!gon.can_update_tasks
        },
        { data: "tag_list", renderer: @tagsRenderer, readOnly:!gon.can_update_tasks },
        { data: "created_at", renderer: @dateRenderer, readOnly:true },
        { 
          data: "assignee_id"
          selectOptions: @model.selectableMembers
          renderer: @assigneeRenderer
          editor:"assignee"
          readOnly:!gon.can_update_tasks
        },
        {
          data: "original_estimate"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          editor:"duration"
          allowInvalid: false
          readOnly:!gon.can_update_tasks
        },
        { data: "work_logged", renderer: ProjectsHelper.durationRenderer, readOnly:true },
        {
          data: "remaining_estimate"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          allowInvalid: false
          editor:"duration"
          readOnly:!gon.can_update_tasks
        },
        { data: "delta", renderer: ProjectsHelper.deltaRenderer, readOnly:true }
      ]
      beforeChange: (changes, source) =>
        hot = @getTable()
        for change in changes
          value = parseInt(change[3])

          original  = parseInt(hot.getDataAtRowProp(change[0], "original_estimate"))
          logged    = parseInt(hot.getDataAtRowProp(change[0], "work_logged"))
          remaining = parseInt(hot.getDataAtRowProp(change[0], "remaining_estimate"))

          if change[1] == "original_estimate" and logged == 0 and remaining == original
            remaining = value
            data = hot.getData()
            data[change[0]].remaining_estimate = remaining

          if change[1] == "original_estimate" or change[1] == "work_logged" or change[1] == "remaining_estimate"
            switch change[1]
              when "original_estimate"  then original  = value
              when "work_logged"        then logged    = value
              when "remaining_estimate" then remaining = value

            delta = original - (logged + remaining)
            hot.setDataAtRowProp(change[0], 'delta', delta)
      afterChange: (changes, source) ->
        Tasks.updateSummary()

        if source == 'loadData'
          return
        for change in changes
          if change[1] != 'delta'
            instance = grid.handsontable('getInstance')
            if instance.sortIndex.length > 0
              physicalIndex = instance.sortIndex[change[0]][0]
            else
              physicalIndex = change[0]
            item = instance.getDataAtRow(physicalIndex)
            Api.update_task gon.project_id, item.id, item, (task) ->
              # nothing to do here

      cells: (row, col, prop) =>
        cellProperties = {}
        data = grid.handsontable('getInstance').getData()
        if col == 4 and data[row]
          cellProperties.readOnly = !@model.canChangeAssignee(data[row])

        return cellProperties
    })

  codeRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    escaped = "<a class='task-code' href='#taskModal' data-toggle='modal' data-tab='informations'>#{value}</a>"
    td.innerHTML = escaped
    return td

  nameRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    hot = @getTable()
    note = hot.getDataAtRowProp(row, 'description')
    icon = if (note? and note!= '') then 'fa-file-text-o' else 'fa-file-o'
    start = "<i class='task-note fa #{icon}' title='' data-placement='right'"
    start += " data-toggle='modal' data-target='#taskModal' data-tab='notes'"
    start += "/>&nbsp;"

    escaped = Handsontable.helper.stringify(value)
    $(td).html(start + escaped)
    if note?
      $(td).find('i').attr('title', note)
      $('i.task-note').tooltip({container: 'body'})
    return td

  tagsRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    if value? and value != ''
      tags = value.split(',')
      value = ''
      for tag in tags
        labelClass = ProjectsHelper.getTagColor(tag)
        value += "<span class='label bg-#{labelClass}'>#{tag}</span>&nbsp;"
      escaped = Handsontable.helper.stringify(value)
      td.innerHTML = escaped
    else
      Handsontable.renderers.TextRenderer.apply(this, arguments)

  assigneeRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    if value? and value != ''
      value = parseInt(value, 10)
      value = Tasks.model.findUsername(value)
    Handsontable.renderers.TextRenderer.apply(this, arguments)

  dateRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    date = moment(value)
    value = date.format('YYYY/MM/DD')
    Handsontable.renderers.TextRenderer.apply(this, arguments)

  requiredTextValidator: (value, callback) ->
    callback(Boolean(value))

  # hot.getDataAtRow doesn't work with sorting
  getTaskAtRow: (row) ->
    hot = @getTable()
    id = hot.getDataAtRowProp(row, 'id')
    @model.getTask(id)

  getSelectedTask: ->
    cells = @getTable().getSelected()
    if cells?
      @model.getTaskAt(cells[0]) 
    else
      @saveSelected

  # fix for handsontable focus problem
  deselectTask: ->
    @saveSelected = @getSelectedTask()
    @getTable().deselectCell()

  deleteTasks: ->
    hot = @getTable()
    cells = hot.getSelected()
    if cells?
      startRow = cells[0]
      endRow   = cells[2]
      [startRow, endRow] = [endRow, startRow] if startRow > endRow

      for row in [startRow..endRow]
        if hot.getDataAtRowProp(row, 'work_logged') > 0
          alert("Tasks with work logged can't be deleted")
          return

      if confirm('Task(s) will be deleted. Are you sure ?')
        tasks = []
        for row in [startRow..endRow]
          task = @getTaskAtRow(row)
          tasks.push task

        @model.removeTasks(tasks)
    else
      alert('You must select at least one row')

  render: ->
    @getTable().render()

  onUpdate: =>
    $('#loadingSpinner').hide()
    $('#tasksGrid').show()

    @getTable().loadData(@getTasks())
    @render()


class TasksCardsView

  constructor: (@model) ->
    @model.subscribe @onUpdate
    @selectedTask = null

  initialize: ->
    $('#tasksSort').change =>
      @render()

  getSelectedTask: ->
    @selectedTask

  deselectTask: ->
    # nothing to do here

  deleteTasks: ->
    selectedTasks = $('.card-check:checked')
    if selectedTasks.length > 0
      if confirm('Task(s) will be deleted. Are you sure ?')
        tasks = []
        for selected in selectedTasks
          tasks.push(@model.getTask($(selected).data('id')))
        @model.removeTasks(tasks)
    else
      alert('You must select at least one task')

  getTasks: ->
    filter = $('#tasksFilter').val()
    sort   = $('#tasksSort').val()
    order  = $('#tasksSort').find('option:selected').data('order')
    @model.getTasks(filter, true, sort, order)

  render: ->
    tasks = @getTasks()

    toDo       = tasks.filter (task) -> task.work_logged == 0
    inProgress = tasks.filter (task) -> task.work_logged > 0 and task.remaining_estimate > 0
    done       = tasks.filter (task) -> task.work_logged > 0 and task.remaining_estimate == 0

    @renderColumn($('#tasks-cards-todo'), toDo, true)
    @renderColumn($('#tasks-cards-inprogress'), inProgress, false)
    @renderColumn($('#tasks-cards-done'), done, false)

    # Must tooltip after dynamic creation
    $("[data-toggle='tooltip']").tooltip({container: 'body'})

    $('.card-clickable').on 'click', (e) =>
      id = $(e.currentTarget).data('id')
      @selectedTask = @model.getTask(id)
      $('#taskModal').modal('show', e.currentTarget)
      false

  renderColumn: (column, tasks, deletable) ->
    tpl = $('#task-card-tpl').html()
    column.html('')
    for task in tasks
      tags = task.tag_list.split(',')
      value = ''
      for tag in tags
        labelClass = ProjectsHelper.getTagColor(tag)
        value += "<span class='card-tag bg-#{labelClass}' title='#{tag}' data-toggle='tooltip'>&nbsp;</span>"

      descriptionClass = if task.description then 'fa-file-text-o' else 'fa-file-o'
      description = if task.description then task.description else ''
      badge_description = "<i class='task-description fa #{descriptionClass}' title='' data-toggle='tooltip'/>"

      task_total = task.work_logged + task.remaining_estimate
      task_progress = Math.round(if task_total > 0 then task.work_logged * 100 / task_total else 0)
      delta_color = if task.delta < 0 then 'red' else 'green'

      work = "estimate : #{Duration.stringify(task.original_estimate, {format: 'micro'})}, done : #{Duration.stringify(task.work_logged, {format: 'micro'})}, todo : #{Duration.stringify(task.remaining_estimate, {format: 'micro'})}"

      html = tpl.replace('data-src', 'src')
      html = html.replace( /%%id%%/g, task.id)
      html = html.replace('%%tags%%', value)
      html = html.replace('%%code%%', task.code)
      html = html.replace('%%name%%', task.name)
      html = html.replace('%%badge-description%%', badge_description)
      html = html.replace(/%%task-progress%%/g, task_progress)
      html = html.replace('%%delta-color%%', delta_color)
      html = html.replace('%%work%%', work)

      if deletable
        html = html.replace('%%hide_cardcheck%%', '')
      else
        html = html.replace('%%hide_cardcheck%%', 'hide')


      if task.assignee_id? and task.assignee_id > 0
        html = html.replace('%%hide_avatar%%', '')
        html = html.replace('%%user_id%%', task.assignee_id)
        html = html.replace('%%username%%', @model.findUsername(task.assignee_id))
        
      else
        html = html.replace('%%user_id%%', 1)
        html = html.replace('%%hide_avatar%%', 'hide')

      column.append(html)
      $("#card-#{task.id}").find('i.task-description').attr('title', description)

  onUpdate: =>
    @render()


@Tasks=
  
  init: ->
    Tasks.model = new TasksModel()
    Tasks.model.subscribe Tasks.onUpdate

    Tasks.gridView = new TasksGridView(Tasks.model)
    Tasks.cardsView = new TasksCardsView(Tasks.model)

    Tasks.model.loadMembers( ->
      Tasks.initDialogAssignee()
      Tasks.gridView.initialize()
      Tasks.cardsView.initialize()
    )

    Tasks.initTabs()    
    Tasks.initButtons()
    Tasks.initFilter()
    Tasks.initTaskDialog()

  initDialogAssignee: ->
    for member in Tasks.model.selectableMembers
      $('#task-assigned').append($('<option>', {
        value: member.user_id,
        text: member.username
      }));

  initTabs: ->
    $('#tab-sheet').hide()

    $('#show-sheet').on 'click', ->
      Tasks.showGridView()

    $('#show-cards').on 'click', ->
      Tasks.showCardsView()


  showGridView: ->
    $('#tab-sheet').show()
    $('#tab-cards').hide()
    $('#show-cards').toggleClass('active')
    $('#show-cards').removeClass('btn-primary')
    $('#show-cards').addClass('btn-default')
    $('#show-sheet').toggleClass('active')
    $('#show-sheet').removeClass('btn-default')
    $('#show-sheet').addClass('btn-primary')
    $('#tasksSort').addClass('hide')
    $('#display_completed').removeClass('hide')
    Tasks.currentView().render()
    Tasks.updateSummary()

  showCardsView: ->
      $('#tab-cards').show()
      $('#tab-sheet').hide()
      $('#show-cards').toggleClass('active')
      $('#show-cards').removeClass('btn-default')
      $('#show-cards').addClass('btn-primary')
      $('#show-sheet').toggleClass('active')
      $('#show-sheet').removeClass('btn-primary')
      $('#show-sheet').addClass('btn-default')
      $('#tasksSort').removeClass('hide')
      $('#display_completed').addClass('hide')
      Tasks.currentView().render()
      Tasks.updateSummary()

  initButtons: ->
    $("#btn-add-task").on "click", ->
      Tasks.model.createTask()

    $("#btn-delete-task").on "click", ->
      Tasks.deleteTasks()

    Mousetrap.bind 'a', Tasks.model.createTask
    Mousetrap.bind 'd', Tasks.deleteTasks

  initFilter: ->
    $('#tasksFilter').on 'keyup', (e) ->
      Tasks.model.loadTasks()

    $('#display_completed').on 'click', (e) ->
      $('#display_completed').toggleClass('active')
      tooltip = if $('#display_completed').hasClass('active') then 'hide' else 'show'
      tooltip += ' completed tasks'
      $('#display_completed').attr('data-original-title', tooltip)
      Tasks.model.loadTasks()

  onUpdate: =>
    Tasks.updateSummary()

  currentView: ->
    if $('#tab-sheet').is(':visible')
      Tasks.gridView
    else
      Tasks.cardsView

  deleteTasks: =>
    Tasks.currentView().deleteTasks()

  initTaskDialog: ->
    if !gon.can_update_tasks
      $('#task-name').prop("readonly", true)
      $('#task-tags').prop("readonly", true)
      $('#task-notes').prop("readonly", true)
      $('#task-original').prop("readonly", true)
      $('#task-remaining').prop("readonly", true)
      if !gon.can_take_unassigned_task
        $('#task-assigned').prop("disabled", true)
        $('#task-notes-save').hide()
     
    $("#task-tags").select2({tags:[], tokenSeparators: [",", " "]})
      
    $('#taskModal').on 'show.bs.modal', (e) ->
      tab = $(e.relatedTarget).data('tab')
      $(".nav-tabs a[href='#tab_#{tab}']").tab('show')
      Tasks.fillTaskDialog()

    # Quickfix : conflict with handsontable. Must deselect cell
    Tasks.selectedCell = null
    $('#taskModal').on 'shown.bs.modal', (e) ->
      task = Tasks.currentView().getSelectedTask()
      Tasks.currentView().deselectTask()
      tab = $(e.relatedTarget).data('tab')
      if tab == 'informations'
        if gon.can_update_tasks
          $('#task-name').focus()
        else if Tasks.model.canChangeAssignee(task)
          $('#task-assigned').focus()
      else
        $('#task-notes').focus()

    $('#task-notes-save').on 'click', (e) ->
      errors = Tasks.validateTaskDialog()
      if errors.length == 0
        Tasks.saveTaskDialog()          
        $('#taskModal').modal('hide')
      else
        Tasks.showErrorsTaskDialog(errors)

  fillTaskDialog: ->
    $('#task-errors').hide()
    task = Tasks.currentView().getSelectedTask()
    if task?
      user_id = task.assignee_id
      if Tasks.model.canChangeAssignee(task)
        $('#task-assigned').show()
        $('#task-assigned-text').hide()
        $('#task-assigned').val(user_id)
      else
        $('#task-assigned').hide()
        $('#task-assigned-text').show()
        $('#task-assigned-text').val(Tasks.model.findUsername(user_id))

      $('#task-id').val(task.code)
      $('#task-name').val(task.name)
      $('#task-notes').val(task.description)

      $('#task-tags').select2('val', task.tag_list.split(','))

      original = task.original_estimate
      $('#task-original').val(Duration.stringify(original, {format: 'micro'}))

      remaining = task.remaining_estimate
      $('#task-remaining').val(Duration.stringify(remaining, {format: 'micro'}))

  validateTaskDialog: ->
    name = $('#task-name').val()
    original = $('#task-original').val()
    remaining = $('#task-remaining').val()

    errors = []
    errors.push("Task name shouldn't be blank") if name.length == 0

    try
      Duration.parse(original)
    catch error
      errors.push("Original estimate format is incorrect")

    try
      Duration.parse(remaining)
    catch error
      errors.push("Remaining estimate format is incorrect")
    
    errors

  saveTaskDialog: ->
    item = Tasks.currentView().getSelectedTask()
    doSave = false
    
    if gon.can_update_tasks
      item.name        = $('#task-name').val()
      item.description = $('#task-notes').val()
      item.tag_list    = $('#task-tags').select2('val').join(',')
      item.original_estimate =  Duration.parse($('#task-original').val())
      item.remaining_estimate = Duration.parse($('#task-remaining').val())
      item.delta = item.original_estimate - (item.work_logged + item.remaining_estimate)
      doSave = true

    if Tasks.model.canChangeAssignee(item)
      item.assignee_id = $('#task-assigned').val()
      doSave = true
    
    if doSave
      Tasks.model.updateTask(item)

  showErrorsTaskDialog: (errors) ->
    value = ""
    for error in errors
      value += "<li>#{error}</li>"
    $("#task-errors ul").html(value)
    $("#task-errors").show()


  updateSummary: ->
    items = Tasks.currentView().getTasks()
    estimate = 0
    logged = 0
    remaining = 0
    delta = 0
    
    for item in items
      estimate  += parseInt(item.original_estimate)
      logged    += parseInt(item.work_logged)
      remaining += parseInt(item.remaining_estimate)
      delta     += parseInt(item.delta)

    estimate  = Duration.stringify(estimate, {format: 'micro'}) if estimate != 0
    remaining = Duration.stringify(remaining, {format: 'micro'}) if remaining != 0
    logged    = Duration.stringify(logged, {format: 'micro'}) if logged != 0
    delta     = Duration.stringify(delta, {format: 'micro'}) if delta != 0

    tasks_count = '' + items.length
    if items.length != Tasks.model.getTasksTotal()
      tasks_count += '<small>/' + Tasks.model.getTasksTotal() + "</small>"

    $("#tasks_count").html(tasks_count)
    $("#tasks_estimate").html(estimate)
    $("#tasks_logged").html(logged)
    $("#tasks_remaining").html(remaining)
    $("#tasks_delta").html(delta)

    $('#tasks_delta').removeClass('bg-red bg-green')
    if delta < 0
      $('#tasks_delta').addClass('bg-red')
    else if delta > 0
      $('#tasks_delta').addClass('bg-green')
