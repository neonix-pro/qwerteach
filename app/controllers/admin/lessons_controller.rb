module Admin
  class LessonsController < ApplicationController

    def index
      search = Lesson.ransack(search_params)
      resources = search.result.page(params[:page]).per(records_per_page)
      resources = order.apply(resources)
      page = Administrate::Page::Collection.new(dashboard, order: order)
      render locals: {
         resources: resources,
         search: search,
         page: page
      }
    end

    private

    def search_params
      params[:q]
    end
  end
end

