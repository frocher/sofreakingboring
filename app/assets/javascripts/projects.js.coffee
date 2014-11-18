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

  loadProjects: ->
    Api.projects (projects) =>
      @projects = projects
      @notify()

class ProjectsCardsView
  constructor: (@model) ->
    @model.subscribe @onUpdate

  onUpdate: ->
    @render()

  render: ->

@Projects=
  init: ->
    @model  = new ProjectsModel()
    @model.loadProjects()
    @cardsView = new ProjectsCardsView(@model)
