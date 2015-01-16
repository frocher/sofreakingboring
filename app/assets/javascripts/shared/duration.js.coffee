
# Converted and adaptated from Juration, a natural language duration parser
# https://github.com/domchristie/juration
# With this version, we have 8 hours work days
class @Duration
  UNITS = {
    minutes: {
      patterns: ['minute', 'min', 'm(?!s)']
      value: 1
      formats: {
        'chrono': ':'
        'micro':  'm'
        'short':  'min'
        'long':   'minute'
      }
    }
    hours: {
      patterns: ['hour', 'hr', 'h']
      value: 60
      formats: {
        'chrono': ':'
        'micro':  'h'
        'short':  'hr'
        'long':   'hour'
      }
    }
    days: {
      patterns: ['day', 'dy', 'd']
      value: 480
      formats: {
        'chrono': ':'
        'micro':  'd'
        'short':  'day'
        'long':   'day'
      }
    }
    months: {
      patterns: ['month', 'mon', 'mo']
      value: 10440
      formats: {
        'chrono': ':'
        'micro':  'mo'
        'short':  'mon'
        'long':   'month'
      }
    }
    years: {
      patterns: ['year', 'yr', 'y']
      value: 125280
      formats: {
        'chrono': ':'
        'micro':  'y'
        'short':  'yr'
        'long':   'year'
      }
    }
  }
    
  @stringify: (seconds, options) ->
    if !@_isNumeric(seconds)
      throw "duration.stringify(): Unable to stringify a non-numeric value"
    
    if (typeof options == 'object' and options.format != undefined) and (options.format != 'micro' and options.format != 'short' and options.format != 'long' and options.format != 'chrono')
      throw "duration.stringify(): format cannot be '" + options.format + "', and must be either 'micro', 'short', or 'long'"
    
    defaults = {
      format: 'short'
    }
    
    opts = @_extend(defaults, options)

    if seconds < 0
      prefix = '-'
      seconds = -seconds
    else
      prefix = ''
    
    units = ['years', 'months', 'days', 'hours', 'minutes']
    values = []

    for unit, i in units
      if i == 0
        values[i] = seconds // UNITS[unit].value
      else
        values[i] = (seconds % UNITS[units[i-1]].value) // UNITS[unit].value

      if opts.format == 'micro' or opts.format == 'chrono'
        values[i] += UNITS[unit].formats[opts.format]
      else
        values[i] += ' ' + @_pluralize(values[i], UNITS[unit].formats[opts.format])

    output = ''
    for value, i in values
      if value.charAt(0) != '0' and opts.format != 'chrono'
        output += value + ' '
      else if opts.format == 'chrono'
        output += @_padLeft(value + '', '0', if i == values.length - 1 then 2 else 3)

    output = output.replace(/\s+$/, '').replace(/^(00:)+/g, '').replace(/^0/, '')
    output = '0' if output == ''
    output = prefix + output

  @parse: (string) ->
    # returns calculated values separated by spaces
    for unit of UNITS
      for pattern in UNITS[unit].patterns
        regex = new RegExp("((?:\\d+\\.\\d+)|\\d+)\\s?(" + pattern + "s?(?=\\s|\\d|\\b))", 'gi')
        string = string.replace(regex, (str, p1, p2) ->
          return " " + (p1 * UNITS[unit].value).toString() + " "
        )
    
    sum = 0

    # replaces non-word chars (excluding '.') with whitespace
    # trim L/R whitespace, replace known join words with ''
    numbers = string
                    .replace(/(?!\.)\W+/g, ' ')   
                    .replace(/^\s+|\s+$|(?:and|plus|with)\s?/g, '')
                    .split(' ')
    
    for number in numbers
      if number and isFinite(number)
         sum += parseFloat(number)
      else if !number
        throw "duration.parse(): Unable to parse: a falsey value"
      else
        # throw an exception if it's not a valid word/unit
        throw "duration.parse(): Unable to parse: " + numbers[j].replace(/^\d+/g, '')

    sum

  # _padLeft('5', '0', 2) => 05
  @_padLeft: (s, c, n) ->
      if s and c and s.length < n
        max = (n - s.length) / c.length
        for i in [0..max]
          s = c + s
      s

  @_pluralize: (count, singular) ->
    if count == 1 then singular else singular + 's'

  @_isNumeric: (n) ->
    !isNaN(parseFloat(n)) and isFinite(n)

  @_extend: (obj, extObj) ->
    for i of extObj
      if extObj[i] != undefined
        obj[i] = extObj[i]
    obj

