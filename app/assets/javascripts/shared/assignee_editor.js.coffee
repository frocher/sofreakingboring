
class AssigneeEditor extends Handsontable.editors.SelectEditor

  
  setValue: (member) ->
    newValue = "0"
    newValue = member.user_id if member != ""
    this.select.value = newValue

  prepare: ->
    Handsontable.editors.BaseEditor.prototype.prepare.apply(this, arguments);

    options = this.cellProperties.selectOptions;
    Handsontable.Dom.empty(this.select)
    for option in options
      optionElement = document.createElement('OPTION')
      optionElement.value = option.user_id
      Handsontable.Dom.fastInnerHTML(optionElement, option.username)
      this.select.appendChild(optionElement)



Handsontable.editors.AssigneeEditor = AssigneeEditor
Handsontable.editors.registerEditor('assignee', AssigneeEditor)
