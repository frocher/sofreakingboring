module Projects::TimesheetsHelper
  def format_period(period_start, period_end)
    period_start.strftime("%b %d, %Y") + " - " + period_end.strftime("%b %d, %Y")
  end
end
