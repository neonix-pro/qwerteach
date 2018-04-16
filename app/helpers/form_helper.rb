module FormHelper
  def to_form_params(attribute, prefix = nil, params = {}) # :nodoc:
    case attribute
    when Hash
      attribute.each do |key, value|
        hash_prefix = prefix ? "#{prefix}[#{key}]" : key
        to_form_params(value, hash_prefix, params)
      end
    when Array
      array_prefix = "#{prefix}[]"
      attribute.each do |value|
        to_form_params(value, array_prefix, params)
      end
    else
      params[prefix] = attribute.to_param
    end

    params
  end
end