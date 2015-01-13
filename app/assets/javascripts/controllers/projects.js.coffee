@Projects=
  
  init: ->
    @model = new ProjectsModel(false)
    @cardsView = new ProjectsCardsView(@model)
    @model.loadProjects( -> 
      $("#loadingSpinner").hide()
      Projects.cardsView.initialize()
    )
