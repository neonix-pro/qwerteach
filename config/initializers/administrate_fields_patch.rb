require 'administrate/field/base'
Administrate::Field::Base.class_eval do
  def tab
    options[:tab]
  end
end
