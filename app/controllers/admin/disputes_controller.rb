module Admin
  class DisputesController < Admin::ApplicationController

    def index
      search = Dispute.ransack(params[:q])
      resources = search.result.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)
      render locals: {
        resources: resources,
        search: search,
        page: page
      }
    end

    def resolve
      resolve = if params[:amount].to_i.zero?
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
  end
end
