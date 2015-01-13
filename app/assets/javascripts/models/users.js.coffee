class @UsersModel
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
