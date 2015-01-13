@AdminUsers=
  
  init: ->
    @model  = new UsersModel()
    @cardsView = new UsersCardsView(@model)
    @model.loadUsers( ->
      $("#loadingSpinner").hide()
      AdminUsers.cardsView.initialize()
    )