class WorkWeek
  attr_accessor :projects, :total

  def initialize(logs)
    @projects = Hash.new
    @total = [0, 0, 0, 0, 0, 0, 0]
    logs.each do |log|
      value = @projects[log.name]
      value = [0, 0, 0, 0, 0, 0, 0] if value.nil?
      date = DateTime.parse(log.day, "%Y%m%d")
      value[date.wday-1] += log.total_worked
      @total[date.wday-1] += log.total_worked
      @projects[log.name] = value
    end
  end

end