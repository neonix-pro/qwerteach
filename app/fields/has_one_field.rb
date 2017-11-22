require "administrate/field/base"

class HasOneField < Administrate::Field::Associative

  def self.permitted_attribute(attr)
    related_dashboard_attributes =
      Administrate::ResourceResolver.new("admin/#{attr}").
        dashboard_class.new.permitted_attributes + [:id]

    { "#{attr}_attributes": related_dashboard_attributes }
  end

  def nested_form
    @nested_form ||= Administrate::Page::Form.new(
      Administrate::ResourceResolver.new("admin/#{attribute}").dashboard_class.new,
      data || resolver.resource_class.new,
    )
  end

  def to_partial_path
    "/fields/has_one/#{page}"
  end

end