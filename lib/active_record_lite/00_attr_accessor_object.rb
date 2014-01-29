class AttrAccessorObject
  def self.my_attr_accessor(*items)
    items.each do |item|
      define_method(item) do
        instance_variable_get("@#{item}")
      end
      
      define_method("#{item}=") do |write_value|
        instance_variable_set("@#{item}", write_value)
      end
    end
  end
end
