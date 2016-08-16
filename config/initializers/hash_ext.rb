Hash.class_eval do

  def underscore_keys
    self.deep_transform_keys{|key| key.is_a?(Symbol) ? key.to_s.underscore.to_sym : key.underscore }
  end

  def underscore_keys!
    self.deep_transform_keys!{|key| key.is_a?(Symbol) ? key.to_s.underscore.to_sym : key.underscore }
  end

  def camelize_keys
    self.deep_transform_keys{|key| key.is_a?(Symbol) ? key.to_s.camelize.to_sym : key.camelize }
  end

  def camelize_keys!
    self.deep_transform_keys!{|key| key.is_a?(Symbol) ? key.to_s.camelize.to_sym : key.camelize }
  end

end