@ProjectsHelper=

  getTagColor: (tag) ->
    tag = $.trim(tag)

    index = 0
    for i in [0..tag.length-1]
      index += tag.charCodeAt(i)
    index = index % 14

    switch index
      when 0 then labelClass = 'red'
      when 1 then labelClass = 'yellow'
      when 2 then labelClass = 'aqua'
      when 3 then labelClass = 'blue'
      when 4 then labelClass = 'light-blue'
      when 5 then labelClass = 'green'
      when 6 then labelClass = 'navy'
      when 7 then labelClass = 'teal'
      when 8 then labelClass = 'olive'
      when 9 then labelClass = 'lime'
      when 10 then labelClass = 'orange'
      when 11 then labelClass = 'fuchsia'
      when 12 then labelClass = 'purple'
      when 13 then labelClass = 'maroon'
      when 14 then labelClass = 'back'
    labelClass

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
    