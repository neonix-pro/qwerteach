class BbbRecordingsController < Bigbluebutton::RecordingsController
  before_filter :authenticate_user!

  def find_playback
    @playback = @recording.playback_formats.first
  end
end