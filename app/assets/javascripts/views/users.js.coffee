class @UsersCardsView
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

    $(".user-card .inner").flip( {trigger: 'manual'} )
    $(".user-info.flip-on").on 'click', (e) ->
      $(e.target).parents('.inner').flip(true)
    $(".user-info.flip-off").on 'click', (e) ->
      $(e.target).parents('.inner').flip(false)
