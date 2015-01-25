class Projects::StatsController < Projects::ItemsController
  def index
  end

  def show
    period_start = params[:start]
    period_end   = params[:end]

    @members = @project.project_members


    # create an empty two dimensional array
    # columns are for members
    # rows are for days
    @results = Array.new
    @js_results = Array.new
    first = Date.strptime(period_start, '%Y%m%d')
    last  = Date.strptime(period_end, '%Y%m%d')
    first.upto(last) do |date|
      row    = Array.new(@members.size + 1, 0)
      row[0] = date.strftime("%b %d, %Y")
      @results << row
      
      js_hash = Hash.new
      js_hash['day'] = date.strftime("%Y-%m-%d")
      @members.each do |member|
        js_hash[member.email] = 0
      end
      @js_results << js_hash
    end

    @total = Array.new(@members.size, 0)

    # fill array
    @members.each_with_index do |member, index|
      logs = member.work_logs(period_start, period_end)
      logs.each do |log|
        date = Date.strptime(log.day, '%Y%m%d')
        diff = (date - first).to_i
        @results[diff][index+1] = view_context.duration(log.total_worked)
        @js_results[diff][member.email] = view_context.to_days(log.total_worked)

        @total[index] += log.total_worked
      end
    end

    @total.each_with_index do |item, index|
      @total[index] = view_context.duration(item)
    end


    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end
end
