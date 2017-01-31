require "administrate/field/base"

class MailboxerMessageField < Administrate::Field::Base
  def to_s
    data
  end
end
