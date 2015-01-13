
class @TasksModel
  
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
    task.tag_list = item.tag_list
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
      filter = filter.toLowerCase()
      filtered = []
      for task in data
        addIt = task.code.toLowerCase().indexOf(filter) > -1

        if !addIt
          addIt = task.name.toLowerCase().indexOf(filter) > -1

        if !addIt
          tags = task.tag_list.split(',')
          for tag in tags
            tag = $.trim(tag)
            if tag.toLowerCase().indexOf(filter) > -1
              addIt = true
              break

        if !addIt
          found = @members.where user_id:task.assignee_id
          addIt = found.length > 0 && found[0].username.toLowerCase().indexOf(filter) > -1

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
    resu = false
    logged = task.work_logged
    if logged == 0
      if gon.can_take_unassigned_task && !gon.can_update_tasks
        resu = task.assignee_id == "" or task.assignee_id == null or parseInt(task.assignee_id) == gon.user_id
      else
        resu = gon.can_update_tasks
    resu
