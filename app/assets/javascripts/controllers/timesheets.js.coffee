@Timesheet=

  init: ->
    Timesheet.initGrid()
    Timesheet.initPeriod()
    $('#members').change ->
      Timesheet.loadGridData()
    $('#filter').on 'keyup', (e) ->
      Timesheet.filterData()
    $('#display_completed').on 'click', (e) ->
      $('#display_completed').toggleClass('active')
      Timesheet.filterData()

  initDeltas: (tasks) ->
    for task in tasks
      task.delta = task.original_estimate - (task.work_logged + task.remaining_estimate + task.monday + task.tuesday + task.wednesday + task.thursday + task.friday)
    return

  loadGridData: ->
    user_id = $('#members').val()

    $('#timesheetContainer').show()

    Api.timesheet_tasks gon.project_id, user_id, gon.period_start, (tasks) ->
      Timesheet.initDeltas(tasks)
      Timesheet.tasks = tasks
      Timesheet.filterData()

    data = null

  filterData: ->
    data = Timesheet.tasks

    filter = $('#filter').val()
    if filter.length > 0
      filter = filter.toLowerCase()
      filtered = []
      for task in data
        addIt = task.code.toLowerCase().indexOf(filter) > -1

        if !addIt
          addIt = task.name.toLowerCase().indexOf(filter) > -1

        if !addIt
          tags = task.tag_list.split(',')
          for tag in tags
            tag = $.trim(tag)
            if tag.toLowerCase().indexOf(filter) > -1
              addIt = true
              break

        filtered.push(task) if addIt

      data = filtered

    if !$('#display_completed').hasClass('active')
      filtered = []
      for task in data
        filtered.push(task) if task.remaining_estimate > 0 or task.original_estimate == 0
      data = filtered

    handsontable = $('#timesheetGrid').data('handsontable')
    handsontable.loadData(data)
    Timesheet.updateVisibility()

  updateVisibility: ->
    Timesheet.hideAll()

    if Timesheet.tasks.length == 0
      Timesheet.showElement('#calloutNoTasks')
    else
      handsontable = $('#timesheetGrid').data('handsontable')
      if handsontable.getData().length == 0
        Timesheet.showElement('#calloutNoVisibleTasks')
    return

  hideAll: ->
    Timesheet.hideElement('#calloutNoTasks')
    Timesheet.hideElement('#calloutNoVisibleTasks')

  showElement: (e) ->
    $(e).show()
    return

  hideElement: (e) ->
    $(e).hide()
    return

  updatePeriod: (periodStart) ->
    periodEnd = moment(periodStart).add('d', 6)
    gon.period_start = periodStart.format("YYYYMMDD")
    gon.period_end = periodEnd.format("YYYYMMDD")
    Timesheet.loadGridData()
    period = periodStart.format("MMM DD, YYYY") + " - " + periodEnd.format("MMM DD, YYYY")
    $('#periodInput').val(period)
    $('#nextPeriod').attr("disabled", Timesheet.lastEditableDate <= gon.period_end)

  isReadOnly:  ->
    user_id = parseInt($('#members').val(), 10)
    resu = gon.project_state != 'opened' 
    if !resu and user_id != gon.user_id
      resu = !gon.can_update_members_task_work
    resu

  nameRenderer: (instance, td, row, col, prop, value, cellProperties) ->
    hot = $("#timesheetGrid").handsontable('getInstance')
    note = hot.getDataAtRowProp(row, 'description')
    icon = if (note? and note!= '') then 'fa-file-text-o' else 'fa-file-o'
    start = "<i class='timesheet-note fa #{icon}' title='' data-placement='right'/>&nbsp;"

    escaped = Handsontable.helper.stringify(value)
    $(td).html(start + escaped)
    if note?
      $(td).find('i').attr('title', note)
      $('i.timesheet-note').tooltip({container: 'body'})
    return td

  initGrid: ->
    grid = $('#timesheetGrid')
    grid.handsontable({
      data: Timesheet.loadGridData(),
      stretchH: 'all',
      currentRowClassName: 'currentRow',
      currentColClassName: 'currentCol',
      columnSorting: true,
      startRows: 0,
      startCols: 9,
      outsideClickDeselects: false,
      colHeaders: ["Code", "Name", "Tags", "Mon.", "Tue.", "Wed.", "Thu.", "Fri.", "Sat.", "Sun.", "Remaining", "Delta"]
      columns: [
        { data: "code", readOnly:true }
        { data: "name", renderer: Timesheet.nameRenderer, readOnly:true }
        {
          data: "tag_list"
          renderer: ProjectsHelper.tagsRenderer
          readOnly: true
        }
        {
          data: "monday"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          editor:"duration"
          allowInvalid: false
          readOnly:gon.project_state!='opened'
        }
        {
          data: "tuesday"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          editor:"duration"
          allowInvalid: false
          readOnly:gon.project_state!='opened'
        }
        {
          data: "wednesday"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          editor:"duration"
          allowInvalid: false
          readOnly:gon.project_state!='opened'
        }
        {
          data: "thursday"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          editor:"duration"
          allowInvalid: false
          readOnly:gon.project_state!='opened'
        }
        {
          data: "friday"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          editor:"duration"
          allowInvalid: false
          readOnly:gon.project_state!='opened'
        }
        {
          data: "saturday"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          editor:"duration"
          allowInvalid: false
          readOnly:gon.project_state!='opened'
        }
        {
          data: "sunday"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          editor:"duration"
          allowInvalid: false
          readOnly:gon.project_state!='opened'
        }        
        {
          data: "remaining_estimate"
          renderer: ProjectsHelper.durationRenderer
          validator: ProjectsHelper.durationValidator
          editor:"duration"
          allowInvalid: false
          readOnly:gon.project_state!='opened'
        }
        {
          data: "delta"
          type: 'numeric'
          renderer: ProjectsHelper.deltaRenderer
          readOnly:true
        }
      ]
      cells: (row, col, prop) ->
        cellProperties = {}
        switch col
          when 0, 1, 2 then cellProperties.readOnly = true
          when 3, 4, 5, 6, 7, 8, 9, 10 then cellProperties.readOnly = Timesheet.isReadOnly()

        cellProperties

      beforeChange: (changes, source) ->
        hot = grid.handsontable('getInstance')
        for change in changes
          value = parseInt(change[3])

          instance = grid.handsontable('getInstance')
          if instance.sortIndex.length > 0
            physicalIndex = instance.sortIndex[change[0]][0]
          else
            physicalIndex = change[0]
          item = instance.getSourceDataAtRow(physicalIndex)

          monday    = parseInt(hot.getDataAtCell(change[0], 3))
          tuesday   = parseInt(hot.getDataAtCell(change[0], 4))
          wednesday = parseInt(hot.getDataAtCell(change[0], 5))
          thursday  = parseInt(hot.getDataAtCell(change[0], 6))
          friday    = parseInt(hot.getDataAtCell(change[0], 7))
          saturday  = parseInt(hot.getDataAtCell(change[0], 8))
          sunday    = parseInt(hot.getDataAtCell(change[0], 9))
          remaining = parseInt(hot.getDataAtCell(change[0], 10))

          switch change[1]
            when "monday"    then monday = value
            when "tuesday"   then tuesday = value
            when "wednesday" then wednesday = value
            when "thursday"  then thursday = value
            when "friday"    then friday = value
            when "saturday"  then saturday = value
            when "sunday"    then sunday = value
            when "remaining_estimate" then remaining = value

          delta = item.original_estimate - (item.work_logged + remaining + monday + tuesday + wednesday + thursday + friday + saturday + sunday)
          hot.setDataAtCell(change[0], 11, delta)
        return

      afterChange: (changes, source) ->
        if source == 'loadData'
          return

        for change in changes
          if change[1] != 'delta'
            instance = grid.handsontable('getInstance')
            if instance.sortIndex.length > 0
              physicalIndex = instance.sortIndex[change[0]][0]
            else
              physicalIndex = change[0]
            item = instance.getSourceDataAtRow(physicalIndex)
            value = change[3]
            workLog = true
            switch change[1]
              when "monday"    then incDays = 0
              when "tuesday"   then incDays = 1
              when "wednesday" then incDays = 2
              when "thursday"  then incDays = 3
              when "friday"    then incDays = 4
              when "saturday"  then incDays = 5
              when "sunday"    then incDays = 6
              when "remaining_estimate"
                workLog = false
                remaining = value

            if workLog
              dateMoment = moment(gon.period_start, "YYYYMMDD")
              date = dateMoment.add('d', incDays).format("YYYYMMDD")
              data = {worked:value}
              Api.update_work_log gon.project_id, item.id, date, data, (log) ->

            else
              # update task
              data = {id:item.id, remaining_estimate:value}
              Api.update_remaining gon.project_id, item.id, data, (task) ->
        return

    })



  initPeriod: ->
    Timesheet.lastEditableDate = gon.period_end
    $('#nextPeriod').attr("disabled", true)

    $('#previousPeriod').click ->
        periodStart = moment(gon.period_start, "YYYYMMDD")
        periodStart.add('d', -7)
        Timesheet.updatePeriod(periodStart)

    $('#nextPeriod').click ->
        periodStart = moment(gon.period_start, "YYYYMMDD")
        periodStart.add('d', 7)
        Timesheet.updatePeriod(periodStart)

    $('#dpPeriod').datepicker({
      endDate: moment(gon.period_end, "YYYYMMDD").toDate()
      weekStart: 1
      autoclose: true
      daysOfWeekDisabled: "0,6"
    }).on( "changeDate", (e) ->
        periodStart = moment(e.date).startOf('isoWeek')
        Timesheet.updatePeriod(periodStart)
      )


