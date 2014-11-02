
class DurationEditor extends Handsontable.editors.TextEditor

  getValue: (duration) ->
    try
      return Duration.parse(this.TEXTAREA.value)
    catch error
      return "error"
  
  setValue: (duration) ->
    try
      this.TEXTAREA.value = Duration.stringify(duration, {format: 'micro'})
    catch error
      this.TEXTAREA.value = ""


Handsontable.editors.DurationEditor = DurationEditor
Handsontable.editors.registerEditor('duration', DurationEditor)
