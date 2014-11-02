@ProjectsHelper=

  deltaRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    try 
      if value < 0
        $(td).css({
          color: 'red'
        })
      else if value > 0
        $(td).css({
          color: 'green'
        })
      $(td).css({
          'text-align': 'right'
        })
      value = Duration.stringify(value, {format: 'micro'})
    catch error
      value = "error"
    Handsontable.renderers.TextRenderer.apply(this, arguments)

  integerValidator: (value, callback) ->
    if value == null
      value = ''
    callback(/^\d*$/.test(value))

  durationRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    if value != 0 and value != "0"
      try 
        value = Duration.stringify(value, {format: 'micro'})
      catch error
        value = "error"
    Handsontable.renderers.TextRenderer.apply(this, arguments)

  durationValidator: (value, callback) ->
    try
      value = Duration.parse(value)
      callback(true)
    catch error
      callback(false)
    