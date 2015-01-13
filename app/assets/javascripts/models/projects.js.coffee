class @ProjectsModel
  constructor: (@isAdmin) ->
    @projects = []
    @subscribers = []

  subscribe: (callback) ->
    @subscribers.push callback

  unsubscribe: (callback) ->
    @subscribers = @subscribers.filter (item) -> item isnt callback

  notify: ->
    subscriber() for subscriber in @subscribers

  getProject: (id) ->
    found = @projects.where id:id
    if found.length > 0 then found[0] else null

  getProjects: (filter = '', sort = '', order = 'asc', displayClosed = false) ->
    projects = @filterProjects(@projects, filter, displayClosed)
    projects = @sortProjects(projects, sort, order) if sort.length > 0
    projects

  filterProjects: (projects, filter = '', displayClosed = false) ->
    data = projects
    if filter.length > 0
      filter = filter.toLowerCase()
      filtered = []
      for project in data
        addIt = project.name.toLowerCase().indexOf(filter) > -1

        if !addIt
          addIt = project.code.toLowerCase().indexOf(filter) > -1
        if !addIt
          addIt = project.description.toLowerCase().indexOf(filter) > -1

        filtered.push(project) if addIt

      data = filtered
  
    if !displayClosed
      filtered = []
      for project in data
        filtered.push(project) if project.state != 'closed'
      data = filtered

    data

  sortProjects: (projects, key, order) ->
    projects.sort (a,b) ->
      m = if order == 'asc' then 1 else -1
      return -1 * m if  a[key] < b[key]
      return +1 * m if a[key] > b[key]
      return 0

  loadProjects: (callback) ->
    Api.projects @isAdmin, 10000, (projects) =>
      @projects = projects
      @notify()
      callback()

  loadMembers: (project, callback) ->
    Api.project_members project.id, (members) ->
      project.members = members
      callback()
    
