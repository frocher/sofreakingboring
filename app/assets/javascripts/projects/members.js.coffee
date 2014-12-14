@Members=

  init: ->
    Members.initSelectRole()

  userFormatResult: (user, container, query) ->
    "<img class='avatar' src='#{user.avatar_url}' width='40' height='40'>
    #{user.name}"
  userFormatSelection: (user, container) -> user.name


  initSelectRole: ->
    $("#user-search").select2
      placeholder: "Type a username"
      minimumInputLength: 2
      multiple: true
      query: (query) ->
        Api.users query.term, 20, (users) ->
          data = 
            results: users
            text: 'name'
          query.callback(data)
      initSelection: (element, callback) ->
        ids = $(element).val().split(',')
        data = []
        Api.user(id, (item) -> 
          data.push(item)
          callback(data) if data.length == ids.length
        ) for id in ids
      formatResult: Members.userFormatResult
      formatSelection: Members.userFormatSelection
      dropdownCssClass: "bigdrop"
      escapeMarkup: (m) -> m

    $(".role-select").on "change", ->
      $(this.form).submit()
