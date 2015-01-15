# Transitive class used to manipulate tasks on timesheets
class TimesheetTask

  attr_accessor :id
  attr_accessor :code
  attr_accessor :name
  attr_accessor :description
  attr_accessor :tag_list
  attr_accessor :monday
  attr_accessor :tuesday
  attr_accessor :wednesday
  attr_accessor :thursday
  attr_accessor :friday
  attr_accessor :saturday
  attr_accessor :sunday
  attr_accessor :original_estimate
  attr_accessor :remaining_estimate
  attr_accessor :work_logged

  def initialize(task, period_start, period_end)
    @id                 = task.id
    @code               = task.code
    @name               = task.name
    @description        = task.description
    @tag_list           = task.tag_list
    @monday             = 0
    @tuesday            = 0
    @wednesday          = 0
    @thursday           = 0
    @friday             = 0
    @saturday           = 0
    @sunday             = 0
    @original_estimate  = task.original_estimate
    @remaining_estimate = task.remaining_estimate
    @work_logged        = 0


    task.work_logs.each do |log|

      # if log is in period, add it to one of the days
      # else add it to the other work_logged
      if log.day >= period_start && log.day <= period_end
        date = DateTime.parse(log.day)
        weekday = date.strftime("%u")

        case weekday
        when '1'
          @monday += log.worked
        when '2'
          @tuesday += log.worked
        when '3'
          @wednesday += log.worked
        when '4'
          @thursday += log.worked
        when '5'
          @friday += log.worked
        when '6'
          @saturday += log.worked
        when '7'
          @sunday += log.worked
        end
      else
        @work_logged += log.worked
      end
    end

  end

  def delta
    @original_estimate - (@work_logged + @remaining_estimate)
  end

end