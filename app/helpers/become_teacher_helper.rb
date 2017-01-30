module BecomeTeacherHelper

def tutorial_progress_bar
  content_tag(:section, class: "container") do
    content_tag(:div, class: "row navigator become-teacher-progress-bar ") do
      content_tag(:ul) do
        wizard_steps.each_with_index do |every_step, index|
          finished_state = "unfinished"
          finished_state = "current"  if every_step == step
          finished_state = "finished" if past_step?(every_step)
          class_str = "become-teacher-step "
          concat(
            content_tag(:li, class: class_str + finished_state) do
              link_to wizard_path(every_step) do
                name = content_tag(:div, I18n.t(every_step, scope: 'become_teacher'), class:'step-name')
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

end
