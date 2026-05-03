module SearchHelper
  def format_cluster_date_range(start_date, end_date)
    if start_date.month == end_date.month
      "#{start_date.strftime('%B %-d')}–#{end_date.strftime('%-d')}"
    else
      "#{start_date.strftime('%B %-d')} – #{end_date.strftime('%B %-d')}"
    end
  end
end
