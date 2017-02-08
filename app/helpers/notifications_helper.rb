module NotificationsHelper
  def notification_date date
    if date.today?
      return date.strftime('%H:%M')
    else
      return date.strftime('le %D/%m à %H:%M')
    end
  end
end