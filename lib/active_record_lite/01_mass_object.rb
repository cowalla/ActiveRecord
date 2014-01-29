require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    formatted_attributes = new_attributes.map(&:to_sym)
    self.attributes.concat(formatted_attributes)
  end

  def self.attributes
    if self == MassObject
      raise "must not call #attributes on MassObject directly"
    end
    
    @attributes ||= []
  end

  def initialize(params = {})
    params.each do |attribute, write_value|
      formatted_attribute = attribute.to_sym
      
      if self.class.attributes.include?(formatted_attribute)
        self.send("#{formatted_attribute}=", write_value)
      else
        raise "mass assignment to unregistered attribute '#{formatted_attribute}'"
      end
    end
  end
  
end
