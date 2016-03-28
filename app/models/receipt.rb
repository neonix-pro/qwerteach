class Receipt < Mailboxer::Receipt

  public
  def self.email_sender
    # nombre de receipts recus entre il y a 5 et 10 minutes, non lus par user
    # renvoie une map : user_id => nombre_receipts
    @receipts = Receipt.where(:is_read => false).where("created_at <= ? AND created_at > ?", DateTime.now - 5.minutes, DateTime.now - 10.minutes).group(:receiver_id).count
    @receipts.keys.each do |k|
      @kk = User.find(k)
      CustomMessageMailer.email_sender_prout(@kk, @receipts[k].to_s).deliver_now
    end
  end
end