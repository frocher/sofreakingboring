$ ->
  new Dispatcher()

class Dispatcher

  constructor: () ->
    @initFlash()
    @initPageScripts()

  initPageScripts: ->
    page = $('body').attr('data-page')

    unless page
      return false

    switch page
      when 'home:index'
        Home.init()
      when 'projects:show'
        ProjectDashboard.init()
      when 'projects:tasks:index'
        Tasks.init()
      when 'projects:members:index', 'projects:members:new'
        Members.init()
      when 'projects:timesheets:edit'
        Timesheet.init()

  initFlash: ->
    flash = $(".flash-container")
    if flash.length > 0
      flash.click -> $(@).fadeOut()
      flash.show()
      setTimeout (-> flash.fadeOut()), 5000