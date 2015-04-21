class HomeController < ApplicationController

  add_breadcrumb "Home", :root_path
  
  def index
    add_breadcrumb "Dashboard", :root_path

    @recent_openings = current_user.project_openings.includes(:project).order(updated_at: :desc).limit(3)
    today = Date.today
    @period_start    = today.beginning_of_week
    @period_end      = @period_start + 6
    gon.period_start = @period_start.strftime("%Y%m%d")
    gon.period_end   = @period_end.strftime("%Y%m%d")

    @work_week = current_user.work_week(@period_start, @period_end)
  end

  def work_for_period
    period_start = DateTime.strptime(params[:period_start], "%Y%m%d")
    period_end   = DateTime.strptime(params[:period_end],   "%Y%m%d")
    @work_week = current_user.work_week(period_start, period_end)
    respond_to do |format|
        format.js
    end
  end
end
