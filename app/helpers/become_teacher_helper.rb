module BecomeTeacherHelper

def tutorial_progress_bar
  content_tag(:section, class: "content") do
    content_tag(:div, class: "navigator") do
      content_tag(:ol) do
        wizard_steps.collect do |every_step|
          class_str = "unfinished"
          class_str = "current"  if every_step == step
          class_str = "finished" if past_step?(every_step)
          concat(
            content_tag(:li, class: class_str) do
              if class_str == 'finished'
                link_to '<i class="fa fa-check"></i>'.html_safe+I18n.t(every_step), wizard_path(every_step)
              else
                link_to I18n.t(every_step), wizard_path(every_step)
              end
              
            end 
          )   
        end 
      end 
    end
  end
end 

end
