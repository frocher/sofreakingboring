
class @TasksGridView
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
      data: [],
      stretchH: 'all',
      columnSorting: true,
      currentRowClassName: 'currentRow',
      currentColClassName: 'currentCol',
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
        {
          data: "tag_list"
          renderer: ProjectsHelper.tagsRenderer
          readOnly:!gon.can_update_tasks
        },
        {
          data: "created_at"
          renderer: @dateRenderer
          readOnly:true
        },
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
        {
          data: "work_logged"
          renderer: ProjectsHelper.durationRenderer
          readOnly:true
        },
        {
          data: "remaining_estimate"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          allowInvalid: false
          editor:"duration"
          readOnly:!gon.can_update_tasks
        },
        {
          data: "delta"
          renderer: ProjectsHelper.deltaRenderer
          readOnly:true
        }
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
            physicalIndex = @getPhysicalIndex(change[0])
            data[physicalIndex].remaining_estimate = remaining

          if change[1] == "original_estimate" or change[1] == "work_logged" or change[1] == "remaining_estimate"
            switch change[1]
              when "original_estimate"  then original  = value
              when "work_logged"        then logged    = value
              when "remaining_estimate" then remaining = value

            delta = original - (logged + remaining)
            hot.setDataAtRowProp(change[0], 'delta', delta)
      afterChange: (changes, source) =>
        Tasks.updateSummary()

        return if source != 'edit' and source != 'paste'

        for change in changes
          if change[1] != 'delta'
            physicalIndex = @getPhysicalIndex(change[0])
            instance = grid.handsontable('getInstance')
            item = instance.getSourceDataAtRow(physicalIndex)
            if item?
              Api.update_task gon.project_id, item.id, item, (task) ->
                # nothing to do here

      cells: (row, col, prop) =>
        cellProperties = {}
        data = grid.handsontable('getInstance').getData()
        if col == 4 and data[row]
          cellProperties.readOnly = !@model.canChangeAssignee(data[row])

        return cellProperties
    })

  getPhysicalIndex: (row) ->
    instance = @getTable()
    if instance.sortIndex.length > 0 then instance.sortIndex[row][0] else row


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
      @getTaskAtRow(cells[0]) 
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
    @getTable().loadData(@getTasks())
    @render()


class @TasksCardsView

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

    toDo       = tasks.filter (task) -> task.work_logged == 0 and (!task.assignee_id? or task.assignee_id <= 0)
    assigned   = tasks.filter (task) -> task.work_logged == 0 and (task.assignee_id? and task.assignee_id > 0)
    inProgress = tasks.filter (task) -> task.work_logged > 0 and task.remaining_estimate > 0
    done       = tasks.filter (task) -> task.work_logged > 0 and task.remaining_estimate == 0

    @renderColumn($('#tasks-cards-todo'), toDo, true)
    @renderColumn($('#tasks-cards-assigned'), assigned, true)
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
