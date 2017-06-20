module Admin
  class DisputesController < Admin::ApplicationController

    def index
      search_term = params[:search].to_s.strip
      search = Dispute.ransack(search_params)
      resources = search.result.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)
      render locals: {
        resources: resources,
        search_term: search_term,
        page: page
      }
    end

    def message
      if params[:conversation_id].present?
        conversation = Conversation.find(params[:conversation_id])
        conversation.messages.create(body: params[:body], sender: current_user, subject: 'Dispute')
      else
        recipients = User.where(id: params[:recipient_ids].split)
        current_user.send_message(recipients, params[:body], 'Dispute')
        conversation = Conversation.between(*recipients).last
      end

      path = reply_conversation_path(conversation)
      message = conversation.messages.last
      string_received = render_to_string template: 'messages/_message_received.html.haml', locals:{message: message}, layout: false
      string_sent = render_to_string template: 'messages/_message_sent.html.haml', locals:{message: message}, layout: false
      (conversation.participants - [current_user]).each do |receiver|
        PrivatePub.publish_to "/chat/#{receiver.id}", :conversation_id => conversation.id, :receiver_id => receiver
        PrivatePub.publish_to path, message_received: string_received, message_sent: string_sent, sender_id: current_user.id
        Pusher.trigger(conversation.id.to_s, conversation.id.to_s, {last_message: message, avatar: message.sender.avatar.url(:small)})
        Pusher.notify([receiver.id.to_s], {
                                            fcm: {
                                                notification: {
                                                    title: message.subject,
                                                    body: message.body,
                                                    icon: 'androidlogo',
                                                    click_action: 'MY_MESSAGES'}
                                                },
                                                webhook_url: 'http://requestb.in/wiriy8wi',
                                                webhook_level: 'DEBUG'})
      end

      redirect_to admin_dispute_path(dispute)
    end

    def divide_sum
      resolve = if params[:amount].to_s.to_i.zero?
        RefundLesson.run(user: dispute.user, lesson: dispute.lesson)
      else
        ResolveDispute.run(dispute: dispute, amount: params[:amount])
      end
      if resolve.valid?
        dispute.finished!
      else
        flash[:notice] = resolve.errors.full_messages.to_sentence
      end
      redirect_to admin_dispute_path(dispute)
    end


    private

    def dispute
      @dispute ||= Dispute.find(params[:dispute_id])
    end

    def search_params
      (params[:q] || {}).merge s: params.values_at(:order, :direction).join(' ')
    end

  end
end
