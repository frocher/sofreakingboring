@Stats=
  
  init: ->
    $('#periodPicker').daterangepicker(
      { 
        format: 'MMM DD, YYYY'
      }
      (start, end, label) ->
        url = "/projects/#{gon.project_id}/stats/show"
        $.ajax(
          url: url
          data:
            start: start.format('YYYYMMDD')
            end:   end.format('YYYYMMDD')
        ).done (html) ->
          $('#results').html(html)
          $('.avatar').tooltip({container: 'body'})
    )
