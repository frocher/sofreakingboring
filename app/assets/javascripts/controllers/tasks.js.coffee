
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

    $('#tasks_delta').removeClass('bg-red bg-green')
    if delta < 0
      $('#tasks_delta').addClass('bg-red')
    else if delta > 0
      $('#tasks_delta').addClass('bg-green')

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


