@Tasks=
  
  tasks: []

  init: ->
    Tasks.initMembers( ->
      Tasks.initGrid()
    ) 
    Tasks.initButtons()
    Tasks.initFilter()
    Tasks.initTaskDialog()

  getTable: ->
    $('#tasksGrid').handsontable('getInstance')

  getData: ->
    Api.tasks gon.project_id, (tasks) ->
      $('#loadingSpinner').hide()
      $('#tasksGrid').show()
      Tasks.tasks = tasks
      Tasks.filterData()
    data = null

  codeRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    escaped = "<a class='task-code' href='#taskModal' data-toggle='modal' data-tab='informations'>#{value}</a>"
    td.innerHTML = escaped
    return td

  assigneeRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    if value? and value != ''
      value = parseInt(value, 10)
      found = Tasks.members.where user_id:value
      if found.length > 0
        assigneeArguments = arguments
        value = found[0].username
        Handsontable.renderers.TextRenderer.apply(this, assigneeArguments)
    else
      Handsontable.renderers.TextRenderer.apply(this, arguments)

  dateRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    date = moment(value)
    value = date.format('YYYY/MM/DD')
    Handsontable.renderers.TextRenderer.apply(this, arguments)

  nameRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    hot = Tasks.getTable()
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
        tag = $.trim(tag)

        index = 0
        for i in [0..tag.length-1]
          index += tag.charCodeAt(i)
        index = index % 14

        switch index
          when 0 then labelClass = 'red'
          when 1 then labelClass = 'yellow'
          when 2 then labelClass = 'aqua'
          when 3 then labelClass = 'blue'
          when 4 then labelClass = 'light-blue'
          when 5 then labelClass = 'green'
          when 6 then labelClass = 'navy'
          when 7 then labelClass = 'teal'
          when 8 then labelClass = 'olive'
          when 9 then labelClass = 'lime'
          when 10 then labelClass = 'orange'
          when 11 then labelClass = 'fuchsia'
          when 12 then labelClass = 'purple'
          when 13 then labelClass = 'maroon'
          when 14 then labelClass = 'back'
        value += "<span class='label bg-#{labelClass}'>#{tag}</span>&nbsp;"
      escaped = Handsontable.helper.stringify(value)
      td.innerHTML = escaped
    else
      Handsontable.renderers.TextRenderer.apply(this, arguments)


  requiredTextValidator: (value, callback) ->
    callback(Boolean(value))


  initGrid: ->
    grid = $('#tasksGrid')
    grid.handsontable({
      data: Tasks.getData(),
      stretchH: 'all',
      columnSorting: true,
      startRows: 0,
      startCols: 8,
      outsideClickDeselects: false,
      colHeaders: ["ID", "Name", "Tags", "Created at", "Assigned to", "Estimate", "Work logged", "Remaining", "Delta"]
      columns: [
        {
          data: "code"
          renderer: Tasks.codeRenderer
          readOnly: true
        },
        {
          data: "name"
          renderer: Tasks.nameRenderer
          validator: Tasks.requiredTextValidator
          allowInvalid: false 
          readOnly:!gon.can_update_tasks
        },
        { data: "tag_list", renderer: Tasks.tagsRenderer, readOnly:!gon.can_update_tasks },
        { data: "created_at", renderer: Tasks.dateRenderer, readOnly:true },
        { 
          data: "assignee_id"
          selectOptions: Tasks.selectableMembers
          renderer: Tasks.assigneeRenderer
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
      beforeChange: (changes, source) ->
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


      cells: (row, col, prop) ->
        cellProperties = {}
        data = grid.handsontable('getInstance').getData()
        if col == 4 and data[row]
          logged = data[row].work_logged
          if logged != 0
            cellProperties.readOnly = true
          else
            if gon.can_take_unassigned_task && !gon.can_update_tasks
              cellProperties.readOnly = data[row].assignee_id != "" && data[row].assignee_id != null && parseInt(data[row].assignee_id) != gon.user_id
            else
              cellProperties.readOnly = !gon.can_update_tasks

        return cellProperties
          
    })

    hot = Tasks.getTable()

  initMembers: (callback) ->
    Api.project_members gon.project_id, (members) =>
      Tasks.members = members

      if gon.can_update_tasks
        Tasks.selectableMembers = members
      else
        found = Tasks.members.where user_id:gon.user_id
        Tasks.selectableMembers = found


      for member in Tasks.selectableMembers
        $('#task-assigned').append($('<option>', {
          value: member.user_id,
          text: member.username
        }));

      callback()

  initButtons: ->
    $("#btn-add-task").on "click", ->
      Tasks.createTask()

    $("#btn-delete-task").on "click", ->
      Tasks.deleteTasks()

    Mousetrap.bind 'a', Tasks.createTask
    Mousetrap.bind 'd', Tasks.deleteTasks

  initFilter: ->
    $('#tasksFilter').on 'keyup', (e) ->
      Tasks.getData()

    $('#display_completed').on 'ifChanged', (e) ->
      Tasks.getData()

  initTaskDialog: ->
    if !gon.can_update_tasks
      $('#task-name').prop("readonly",true)
      $('#task-notes').prop("readonly",true)
      $('#task-assigned').prop("readonly",true)
      $('#task-original').prop("readonly",true)
      $('#task-remaining').prop("readonly",true)
      $('#task-notes-save').hide()

    $('#taskModal').on 'show.bs.modal', (e) ->
      tab = $(e.relatedTarget).data('tab')
      $(".nav-tabs a[href='#tab_#{tab}']").tab('show')
      Tasks.fillTaskDialog()

    # Quickfix : conflict with handsontable. Must deselect cell
    selectedCell = null
    $('#taskModal').on 'shown.bs.modal', (e) ->
      hot = Tasks.getTable()
      selectedCell = hot.getSelected()
      hot.deselectCell()
      $('#task-notes').focus()

    $('#task-notes-save').on 'click', (e) ->
      hot = Tasks.getTable()
      if selectedCell?
        errors = Tasks.validateTaskDialog()
        if errors.length == 0
          row = selectedCell[0]
          note = $('#task-notes').val()
          hot.setDataAtRowProp(row, 'description', note)
          $('#taskModal').modal('hide')
        else
          Tasks.showErrorsTaskDialog(errors)

  fillTaskDialog: ->
    $('#task-errors').hide()
    hot = Tasks.getTable()
    cells = hot.getSelected()
    if cells?
      row = cells[0]
      $('#task-id').val(hot.getDataAtRowProp(row, 'code'))
      $('#task-name').val(hot.getDataAtRowProp(row, 'name'))
      $('#task-notes').val(hot.getDataAtRowProp(row, 'description'))
      $('#task-assigned').val(hot.getDataAtRowProp(row, 'assignee_id'))

      original = hot.getDataAtRowProp(row, 'original_estimate')
      $('#task-original').val(Duration.stringify(original, {format: 'micro'}))

      remaining = hot.getDataAtRowProp(row, 'remaining_estimate')
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

  showErrorsTaskDialog: (errors) ->
    value = ""
    for error in errors
      value += "<li>#{error}</li>"
    $("#task-errors ul").html(value)
    $("#task-errors").show()

  createTask: ->
    task = {name: "New task", original_estimate: 0}
    Api.create_task gon.project_id, task, (task) ->
      hot = $("#tasksGrid").handsontable('getInstance')
      hot.getData().push task
      if hot.getData() != Tasks.tasks
        Tasks.tasks.push task
      hot.render()
      Tasks.updateSummary()

  deleteTasks: ->
    hot = Tasks.getTable()
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
        for row in [startRow..endRow]
          task_id = hot.getDataAtRowProp(row, 'id')
          Api.delete_task gon.project_id, task_id

        hot.alter('remove_row', startRow, endRow - startRow + 1)
        Tasks.updateSummary()
    else
      alert('You must select at least one row')

  filterData: ->
    data = Tasks.tasks
    filter = $('#tasksFilter').val()
    if filter.length > 0
      filtered = []
      for task in data
        addIt = task.name.indexOf(filter) > -1

        if !addIt
          tags = task.tag_list.split(',')
          for tag in tags
            tag = $.trim(tag)
            if tag.indexOf(filter) > -1
              addIt = true
              break

        if !addIt
          found = Tasks.members.where user_id:task.assignee_id
          addIt = found.length > 0 && found[0].username.indexOf(filter) > -1

        filtered.push(task) if addIt

      data = filtered
  
    if !$('#display_completed').prop("checked")
      filtered = []
      for task in data
        if task.remaining_estimate > 0 or task.original_estimate == 0
          filtered.push(task)
      data = filtered

    handsontable = $('#tasksGrid').data('handsontable')
    handsontable.loadData(data)

  updateSummary: ->
    items = Tasks.getTable().getData()
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
    if items.length != Tasks.tasks.length
      tasks_count += '<small>/' + Tasks.tasks.length + "</small>"

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


