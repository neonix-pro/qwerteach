module Admin
  module AttributesHelper
    def resource_field(page, attribute_name, resource = nil, options = {})
      resource = resource || page.resource
      value = resource.public_send(attribute_name)
      field = page.send(:dashboard).attribute_type_for(attribute_name)
      field.new(attribute_name, value, page.class.to_s.underscore.split('/').last.to_sym, options)
    end
  end
end