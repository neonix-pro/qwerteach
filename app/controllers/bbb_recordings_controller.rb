class BbbRecordingsController < Bigbluebutton::RecordingsController
  before_filter :authenticate_user!
end