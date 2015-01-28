@Home=

  init: ->
    Home.initPeriod()
    return

  initPeriod: ->
    $('#previousPeriod').click ->
      periodStart = moment(gon.period_start, "YYYYMMDD")
      periodStart.add('d', -7)
      Home.updatePeriod(periodStart)
      return

    $('#nextPeriod').click ->
      periodStart = moment(gon.period_start, "YYYYMMDD")
      periodStart.add('d', 7)
      Home.updatePeriod(periodStart)
      return

    $('#dpPeriod').datepicker({
      endDate: moment(gon.period_end, "YYYYMMDD").toDate()
      weekStart: 1
      autoclose: true
      daysOfWeekDisabled: "0,6"
    }).on( "changeDate", (e) ->
        periodStart = moment(e.date).startOf('isoWeek')
        Home.updatePeriod(periodStart)
        return
      )

  updatePeriod: (periodStart) ->
    periodEnd = moment(periodStart).add('d', 6)
    gon.period_start = periodStart.format("YYYYMMDD")
    gon.period_end = periodEnd.format("YYYYMMDD")
    $.ajax(
      url: "/work_for_period"
      data:
        period_start: gon.period_start
        period_end: gon.period_end
    )
    period = periodStart.format("MMM DD, YYYY") + " - " + periodEnd.format("MMM DD, YYYY")
    $('#periodInput').val(period)
    return

