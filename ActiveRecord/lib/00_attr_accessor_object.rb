class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |var|
    define_method(var) { return instance_variable_get("@" + var.to_s) }
    define_method(var.to_s + "=") { |val| instance_variable_set("@" + var.to_s, val) } 
    end
  end
end
