
@AdminProjects=
  
  init: ->
    @model  = new ProjectsModel(true)
    @cardsView = new ProjectsCardsView(@model)
    @model.loadProjects( -> 
      $("#loadingSpinner").hide()
      AdminProjects.cardsView.initialize()
    )
