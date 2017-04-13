module OnboardingHelper

  def onboarding_progress_bar
    content_tag(:section, class: "container") do
      content_tag(:div, class: "row navigator onboarding-progress-bar ") do
        content_tag(:ul) do
          steps.each_with_index do |every_step, index|
            finished_state = "unfinished"
            finished_state = "current"  if every_step == step
            finished_state = "finished" if past_step?(every_step)
            class_str = "onboarding-step "
            concat(
                content_tag(:li, class: class_str + finished_state) do
                  link_to wizard_path(every_step), remote: true do
                    name = content_tag(:div, I18n.t(every_step, scope: 'onboarding'), class:'step-name')
                    number = content_tag(:span, "#{index+1}", class:'step-number')
                    number + name
                  end
                end
            )
          end
        end
      end
    end
  end

  def steps
    [:choose_role, :picture, :topics]
  end

end
