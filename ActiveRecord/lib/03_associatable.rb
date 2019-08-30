require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )
  def model_class
    self.class_name.to_s.constantize
  end


  def table_name
    self.class_name.to_s.downcase + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
      string = name.to_s + "_id"
      @foreign_key = string.to_sym
      @primary_key = :id
      @class_name = name.camelcase
  @foreign_key = options[:foreign_key] if options[:foreign_key]
  @primary_key = options[:primary_key] if options[:primary_key]
  @class_name = options[:class_name] if options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
  string = self_class_name.to_s.downcase + "_id"
  @foreign_key = string.to_sym
  @primary_key = :id
  @class_name = name.singularize.camelcase
  @foreign_key = options[:foreign_key] if options[:foreign_key]
  @primary_key = options[:primary_key] if options[:primary_key]
  @class_name = options[:class_name] if options[:class_name]
 
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end




  