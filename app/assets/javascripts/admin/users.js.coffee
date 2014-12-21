class UsersModel
  constructor: ->
    @users = []
    @subscribers = []

  subscribe: (callback) ->
    @subscribers.push callback

  unsubscribe: (callback) ->
    @subscribers = @subscribers.filter (item) -> item isnt callback

  notify: ->
    subscriber() for subscriber in @subscribers

  getUsers: (filter = '', sort = '', order = 'asc') ->
    users = @filterUsers(@users, filter)
    users = @sortUsers(users, sort, order) if sort.length > 0
    users

  filterUsers: (users, filter = '') ->
    data = users
    if filter.length > 0
      filter = filter.toLowerCase()
      filtered = []
      for user in data
        addIt = user.email.toLowerCase().indexOf(filter) > -1

        if !addIt
          addIt = user.name.toLowerCase().indexOf(filter) > -1

        filtered.push(user) if addIt

      data = filtered
  
    data

  sortUsers: (users, key, order) ->
    users.sort (a,b) ->
      m = if order == 'asc' then 1 else -1
      return -1 * m if  a[key] < b[key]
      return +1 * m if a[key] > b[key]
      return 0

  loadUsers: (callback) ->
    Api.users '', 10000, (users) =>
      @users = users
      @notify()
      callback()

class UsersCardsView
  constructor: (@model) ->
    @model.subscribe @onUpdate

  initialize: ->
    $('#usersSort').change =>
      @render()

    $('#usersFilter').on 'keyup', (e) =>
      @render()

  onUpdate: =>
    @render()

  getUsers: ->
    filter = $('#usersFilter').val()
    sort   = $('#usersSort').val()
    order  = $('#usersSort').find('option:selected').data('order')
    @model.getUsers(filter, sort, order)

  render: ->
    tpl = $('#user-card-tpl').html()
    target = $('#users')
    target.html('')
    users = @getUsers()
    for user in users
      html = tpl.replace('data-src', 'src')
      html = html.replace('%%card-item%%', 'user-card')
      html = html.replace( /%%id%%/g, user.id)
      html = html.replace('%%avatar_url%%', user.avatar_url)
      html = html.replace( /%%name%%/g, user.name)
      html = html.replace( /%%email%%/g, user.email)

      html = html.replace('%%created%%', moment(user.created_at).fromNow())
      html = html.replace('%%last_login%%', moment(user.current_sign_in_at).fromNow())
      html = html.replace('%%last_ip%%', user.current_sign_in_ip)
      html = html.replace('%%sign_in_count%%', user.sign_in_count)

      if gon.user_id == user.id
        html = html.replace('%%hide_delete%%', 'hide')
      else
        html = html.replace('%%hide_delete%%', '')

      target.append(html)

    # Must tooltip after dynamic creation
    $("[data-toggle='tooltip']").tooltip({container: 'body'})

    $(".user-card .inner").flip( {trigger: 'click'} );

@AdminUsers=
  
  init: ->
    @model  = new UsersModel()
    @cardsView = new UsersCardsView(@model)
    @model.loadUsers( -> 
      AdminUsers.cardsView.initialize()
    )
