module HomeHelper
  # TODO: Rewrite to showcase events from the leaderboard toppers of all running batches, if available
  def timeline_events_to_showcase(event_count)
    # if there is no current batch, just return the latest timeline_events which can be showcased
    return TimelineEvent.showcase.limit(3) unless Batch.current.present?

    leading_startup_ids = Startup.leaderboard_toppers_for_batch Batch.current, count: event_count
    leading_startup_ids.map { |startup_id| Startup.find(startup_id).showcase_timeline_event }.compact
  end

  def activity_class_for_count(count)
    if count == 0
      'activity-blank'
    elsif count <= 5
      'activity-low'
    elsif count <= 10
      'activity-medium'
    else
      'activity-high'
    end
  end

  def startup_village_redirect?
    params[:redirect_from] == 'startupvillage.in'
  end

  def registration_redirect?
    params[:redirect_from] == 'registration'
  end
end
