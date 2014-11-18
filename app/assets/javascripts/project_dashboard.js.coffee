@ProjectDashboard=
  init: ->
      ProjectDashboard.initCharts()
      ProjectDashboard.initData()
      $(".knob").knob()

  initCharts: ->
    ProjectDashboard.burndown = new Morris.Line({
      element: 'burndown-chart',
      resize: true,
      data: [],
      xkey: 'created_at',
      ykeys: ['remaining_estimate'],
      labels: ['Value'],
      dateFormat: (d) ->
        moment(d).format('MMMM Do YYYY')
      lineColors: ['#efefef'],
      lineWidth: 2,
      pointSize: 3,
      hideHover: 'auto',
      gridTextColor: "#fff",
      gridStrokeWidth: 0.4,
      pointStrokeColors: ["#efefef"],
      gridLineColor: "#efefef",
      gridTextFamily: "Open Sans",
      gridTextSize: 10
    })

    ProjectDashboard.budget = new Morris.Line({
      element: 'budget-chart',
      resize: true,
      data: [],
      xkey: 'created_at',
      ykeys: ['original_estimate', 'total'],
      labels: ['Original estimate', 'Target'],
      dateFormat: (d) ->
        moment(d).format('MMMM Do YYYY')
      lineColors: ['#ffaaaa', '#efefef'],
      lineWidth: 2,
      pointSize: 3,
      hideHover: 'auto',
      gridTextColor: "#fff",
      gridStrokeWidth: 0.4,
      pointStrokeColors: ["#efefef"],
      gridLineColor: "#efefef",
      gridTextFamily: "Open Sans",
      gridTextSize: 10
    })

    $.plot("#members-chart", [members_done_data, members_tbd_data], {
      grid: {
          borderWidth: 1
          borderColor: "#f3f3f3"
          tickColor: "#f3f3f3"
          hoverable: true
      }
      tooltip: true
      tooltipOpts: {
          content: "%x.2 day(s)"
      }
      series: {
          stack: true
          bars: {
              show: true
              barWidth: 0.5
              fill: 0.9
              horizontal: true
              align: "center"
          }
      }
      yaxis: {
          mode: "categories"
          tickLength: 0
      }
    })

    $.plot("#tags-chart", [tags_done_data, tags_tbd_data], {
      grid: {
          borderWidth: 1
          borderColor: "#f3f3f3"
          tickColor: "#f3f3f3"
          hoverable: true
      }
      tooltip: true
      tooltipOpts: {
          content: "%x.2 day(s)"
      }
      series: {
          stack: true
          bars: {
              show: true
              barWidth: 0.5
              fill: 0.9
              horizontal: true
              align: "center"
          }
      }
      yaxis: {
          mode: "categories"
          tickLength: 0
      }
    })


  initData: ->
    Api.project_snapshots gon.project_id, (shots) ->
      toDay = 60 * 8
      for shot in shots
        shot.original_estimate  /= toDay
        shot.work_logged        /= toDay
        shot.remaining_estimate /= toDay
        shot.delta              /= toDay
        shot.total = shot.work_logged + shot.remaining_estimate

        shot.original_estimate  = Math.round(shot.original_estimate * 100) / 100
        shot.work_logged        = Math.round(shot.work_logged * 100) / 100
        shot.remaining_estimate = Math.round(shot.remaining_estimate * 100) / 100
        shot.delta              = Math.round(shot.delta * 100) / 100
        shot.total              = Math.round(shot.total * 100) / 100

        

      ProjectDashboard.burndown.setData(shots)
      ProjectDashboard.budget.setData(shots)

