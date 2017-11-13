module Admin
  module ReportsHelper
    def period_to_range(period)
      if period.match(/^\d{4}-\d{2}$/)
        "#{period}-01 - #{ Date.parse("#{period}-01").end_of_month.to_s }"
      else
        "#{period} - #{period}"
      end
    end

    def admin_sort_link(presenter, attr_name, title = nil)
      link_to(params.merge( presenter.order_params_for(attr_name))) do
        %Q{
          #{title || t("helpers.label.#{resource_name}.#{attr_name}", default: attr_name.to_s).titleize}
          #{ presenter.ordered_by?(attr_name) &&
             content_tag(:span, class: 'cell-label__sort-indicator') do
               icon("sort-amount-#{presenter.ordered_html_class(attr_name)}")
             end
          }
        }.html_safe
      end
    end
  end
end