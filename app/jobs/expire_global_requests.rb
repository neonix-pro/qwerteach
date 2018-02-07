class ExpireGlobalRequests
  @queue = :bookings

  def self.perform(*args)
    #fetch expiring bookings
    @global_requests = GlobalRequest.open.where('expiry_date < ?', Time.now)
    @global_requests.each do |gr|
      gr.status = 0
      gr.save!
    end
  end
end