module Admin
  module ReportsHelper
    def period_to_range(period, gradation)
      case gradation
      when :monthly then "#{period.beginning_of_month.strftime('%Y-%m-%d')} - #{period.end_of_month.strftime('%Y-%m-%d')}"
      when :daily then "#{period.strftime('%Y-%m-%d')} - #{period.strftime('%Y-%m-%d')}"
      when :weekly then "#{period.beginning_of_week.strftime('%Y-%m-%d')} - #{period.end_of_week.strftime('%Y-%m-%d')}"
      when :quarterly then "#{period.beginning_of_quarter.strftime('%Y-%m-%d')} - #{period.end_of_quarter.strftime('%Y-%m-%d')}"
      end
    end

    def admin_sort_link(presenter, attr_name, title = nil)
      link_to(params.merge( presenter.order_params_for(attr_name))) do
        %Q{
          #{title || t("helpers.label.#{resource_name}.#{attr_name}", default: attr_name.to_s).titleize}
          #{ presenter.ordered_by?(attr_name) ?
             content_tag(:span, class: 'cell-label__sort-indicator') do
               icon("sort-amount-#{presenter.ordered_html_class(attr_name)}")
             end : nil
          }
        }.html_safe
      end
    end

    def period_format(date, gradation)
      case gradation
      when :monthly then date.strftime('%m-%Y')
      when :daily then date.strftime('%d-%m-%Y')
      when :weekly then "#{date.strftime('%d')} - #{date.end_of_week.strftime('%d-%m-%Y')}"
      when :quarterly then "#{date.strftime('%d-%m')} - #{date.end_of_quarter.strftime('%d-%m-%Y')}"
      end
    end
  end
end