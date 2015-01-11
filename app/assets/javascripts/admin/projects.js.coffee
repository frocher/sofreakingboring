class ProjectsModel
  constructor: ->
    @projects = []
    @subscribers = []

  subscribe: (callback) ->
    @subscribers.push callback

  unsubscribe: (callback) ->
    @subscribers = @subscribers.filter (item) -> item isnt callback

  notify: ->
    subscriber() for subscriber in @subscribers

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
    Api.projects true, 10000, (projects) =>
      @projects = projects
      @notify()
      callback()

class ProjectsCardsView
  constructor: (@model) ->
    @model.subscribe @onUpdate

  initialize: ->
    $('#projectsSort').change =>
      @render()

    $('#projectsFilter').on 'keyup', (e) =>
      @render()

    $('#display_closed').on 'click', (e) =>
      $('#display_closed').toggleClass('active')
      @render()

  onUpdate: =>
    @render()

  getProjects: ->
    filter        = $('#projectsFilter').val()
    sort          = $('#projectsSort').val()
    order         = $('#projectsSort').find('option:selected').data('order')
    displayClosed = $('#display_closed').hasClass('active')

    @model.getProjects(filter, sort, order, displayClosed)

  render: ->
    tpl = $('#project-card-tpl').html()
    target = $('#projects')
    target.html('')
    projects = @getProjects()

    total_estimate = 0
    total_logged = 0
    total_remaining = 0
    total_delta = 0

    for project in projects
      html = tpl.replace('data-src', 'src')
      html = html.replace('%%card-item%%', 'project-card-no-members')
      html = html.replace( /%%id%%/g, project.id)
      html = html.replace('%%picture_url%%', project.picture_url)
      html = html.replace( /%%name%%/g, project.name)
      html = html.replace( /%%code%%/g, project.code)
      html = html.replace( /%%description%%/g, project.description)

      html = html.replace('%%created%%', moment(project.created_at).fromNow())
      html = html.replace('%%original_estimate%%', Duration.stringify(project.original_estimate, {format: 'micro'}))
      html = html.replace('%%remaining_estimate%%', Duration.stringify(project.remaining_estimate, {format: 'micro'}))
      html = html.replace('%%work_logged%%', Duration.stringify(project.work_logged, {format: 'micro'}))
      html = html.replace('%%delta%%', Duration.stringify(project.delta, {format: 'micro'}))

      total = project.work_logged + project.remaining_estimate
      progress = if total > 0 then project.work_logged * 100 // total else 0
      html = html.replace(/%%progress%%/g, progress)
      
      progress_color = if project.delta < 0 then 'red' else 'green'
      html = html.replace('%%progress_color%%', progress_color)

      target.append(html)

      total_estimate += project.original_estimate
      total_remaining += project.remaining_estimate
      total_logged += project.work_logged
      total_delta += project.delta

    $('#projects_count').html(projects.length)
    $('#projects_estimate').html(Duration.stringify(total_estimate, {format: 'micro'}))
    $('#projects_logged').html(Duration.stringify(total_logged, {format: 'micro'}))
    $('#projects_remaining').html(Duration.stringify(total_remaining, {format: 'micro'}))
    $('#projects_delta').html(Duration.stringify(total_delta, {format: 'micro'}))

    # Must tooltip after dynamic creation
    $("[data-toggle='tooltip']").tooltip({container: 'body'})

    $(".project-card-no-members .inner").flip( {trigger: 'click'} );

@AdminProjects=
  
  init: ->
    @model  = new ProjectsModel()
    @cardsView = new ProjectsCardsView(@model)
    @model.loadProjects( -> 
      $("#loadingSpinner").hide()
      AdminProjects.cardsView.initialize()
    )
