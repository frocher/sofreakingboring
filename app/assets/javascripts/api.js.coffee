@Api =
  users_path:             "/api/:version/users.json"
  user_path:              "/api/:version/users/:id.json"
  project_members_path:   "/api/:version/projects/:project_id/members.json"
  project_snapshots_path: "/api/:version/projects/:project_id/snapshots.json"
  tasks_path:             "/api/:version/projects/:project_id/tasks.json"
  task_path:              "/api/:version/projects/:project_id/tasks/:id.json"
  work_log_update_path:   "/api/:version/projects/:project_id/tasks/:id/work_logs/:day.json"
  remaining_update_path:  "/api/:version/projects/:project_id/tasks/:id/remaining.json"
  timesheet_path:         "/api/:version/projects/:project_id/timesheets/:start.json"
  timesheet_tasks_path:   "/api/:version/projects/:project_id/timesheets/:start/tasks.json"

  user: (user_id, callback) ->
    url = Api.buildUrl(Api.user_path)
    url = url.replace(':id', user_id)

    $.ajax(
      url: url
      data:
        private_token: gon.api_token
      dataType: "json"
    ).done (user) ->
      callback(user)

  # Return users list. Filtered by query
  # Only active users retrieved
  users: (query, callback) ->
    url = Api.buildUrl(Api.users_path)

    $.ajax(
      url: url
      data:
        private_token: gon.api_token
        search: query
        per_page: 20
        active: true
      dataType: "json"
    ).done (users) ->
      callback(users)

  project_members: (project_id, callback) ->
    url = Api.buildUrl(Api.project_members_path)
    url = url.replace(':project_id', project_id)

    $.ajax(
      url: url
      data:
        private_token: gon.api_token
      dataType: "json"
    ).done (tasks) ->
      callback(tasks)

  project_snapshots: (project_id, callback) ->
    url = Api.buildUrl(Api.project_snapshots_path)
    url = url.replace(':project_id', project_id)

    $.ajax(
      url: url
      data:
        per_page: 2000
        private_token: gon.api_token
      dataType: "json"
    ).done (shots) ->
      callback(shots)

  tasks: (project_id, callback) ->
    url = Api.buildUrl(Api.tasks_path)
    url = url.replace(':project_id', project_id)

    $.ajax(
      url: url
      data:
        per_page: 2000
        private_token: gon.api_token
      dataType: "json"
    ).done (tasks) ->
      callback(tasks)

  task: (project_id, task_id, callback) ->
    url = Api.buildUrl(Api.task_path)
    url = url.replace(':project_id', project_id)
    url = url.replace(':id', task_id)

    $.ajax(
      url: url
      data:
        private_token: gon.api_token
      dataType: "json"
    ).done (task) ->
      callback(task)


  create_task: (project_id, data, callback) ->
    url = Api.buildUrl(Api.tasks_path)
    url = url.replace(':project_id', project_id)

    $.extend(data, {private_token: gon.api_token})

    $.ajax(
      url: url
      type: "post"
      data: data
      dataType: "json"
    ).done (task) ->
      callback(task)

  update_task: (project_id, task_id, data, callback) ->
    url = Api.buildUrl(Api.task_path)
    url = url.replace(':project_id', project_id)
    url = url.replace(':id', task_id)

    $.extend(data, {private_token: gon.api_token})

    $.ajax(
      url: url
      type: "put"
      data: data
      dataType: "json"
    ).done (task) ->
      callback(task)

  delete_task: (project_id, task_id, callback) ->
    url = Api.buildUrl(Api.task_path)
    url = url.replace(':project_id', project_id)
    url = url.replace(':id', task_id)

    $.ajax(
      url: url
      type: "delete"
      data:
        private_token: gon.api_token
      dataType: "json"
    ).done (task) ->
      callback(task)

  timesheet: (project_id, start, callback) ->
    url = Api.buildUrl(Api.timesheet_path)
    url = url.replace(':project_id', project_id)
    url = url.replace(':start', start)

    $.ajax(
      url: url
      data:
        private_token: gon.api_token
      type: "get"
      dataType: "json"
    ).done (timesheet) ->
      callback(timesheet)


  timesheet_tasks: (project_id, user_id, start, callback) ->
    url = Api.buildUrl(Api.timesheet_tasks_path)
    url = url.replace(':project_id', project_id)
    url = url.replace(':start', start)

    $.ajax(
      url: url
      data:
        private_token: gon.api_token
        user_id: user_id
      type: "get"
      dataType: "json"
    ).done (tasks) ->
      callback(tasks)
    

  update_work_log: (project_id, task_id, date, data, callback) ->
    url = Api.buildUrl(Api.work_log_update_path)
    url = url.replace(':project_id', project_id)
    url = url.replace(':id', task_id)
    url = url.replace(':day', date)

    $.extend(data, {private_token: gon.api_token})

    $.ajax(
      url: url
      type: "put"
      data: data
      dataType: "json"
    ).done (log) ->
      callback(log)

  update_remaining: (project_id, task_id, data, callback) ->
    url = Api.buildUrl(Api.remaining_update_path)
    url = url.replace(':project_id', project_id)
    url = url.replace(':id', task_id)

    $.extend(data, {private_token: gon.api_token})

    $.ajax(
      url: url
      type: "put"
      data: data
      dataType: "json"
    ).done (task) ->
      callback(task)

  buildUrl: (url) ->
    return url.replace(':version', gon.api_version)
