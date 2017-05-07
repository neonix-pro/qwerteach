module OnboardingHelper

  def onboarding_progress_bar
    content_tag(:div, class: "navigator onboarding-progress-bar ") do
      content_tag(:ul) do
        steps.each_with_index do |every_step, index|
          finished_state = "unfinished"
          finished_state = "current"  if every_step == step
          finished_state = "finished" if past_step?(every_step)
          class_str = "onboarding-step "
          concat(
              content_tag(:li, class: class_str + finished_state) do
                link_to wizard_path(every_step), remote: true do
                  number = content_tag(:i, nil,class:'fa fa-circle')
                  name = content_tag(:span, I18n.t(every_step, scope: 'onboarding'), class: 'step-name')
                  step = content_tag(:div, number + name, class:'step')
                end
              end
          )
        end
      end
    end
  end

  def steps
    [:welcome, :choose_role, :topics]
  end

end
