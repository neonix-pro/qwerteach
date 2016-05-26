module BecomeTeacherHelper

def tutorial_progress_bar
  content_tag(:section, class: "container") do
    content_tag(:div, class: "row navigator") do
      content_tag(:ol) do
        wizard_steps.collect do |every_step|
          finished_state = "unfinished"
          finished_state = "current"  if every_step == step
          finished_state = "finished" if past_step?(every_step)
          class_str = "pull-left "
          concat(
            content_tag(:li, class: class_str + finished_state) do
              if finished_state == 'finished'
                link_to '<i class="fa fa-check"></i>'.html_safe+I18n.t(every_step, scope: 'become_teacher'), wizard_path(every_step)
              else
                link_to I18n.t(every_step, scope: 'become_teacher'), wizard_path(every_step)
              end
            end
          )
        end
      end
    end
  end
end 

end
