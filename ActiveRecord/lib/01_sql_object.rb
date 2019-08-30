require_relative 'db_connection'
require 'active_support/inflector'
require "byebug"
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  attr_reader :cols
  def self.columns
    res = []
    var = self.table_name
    if @cols.nil?
    @cols = DBConnection.execute2(<<-SQL)
  SELECT
    *
  FROM
    #{var}
SQL
  @cols = @cols[0].map! { |col| col.to_sym} 
    end
     
        

    @cols
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) { return self.attributes[col] }
      define_method(col.to_s + "=") { |val| self.attributes[col] = val } 
    end
  end

  def self.table_name=(table_name)
    instance_variable_set("@" + self.to_s.downcase + "s", table_name)
  end

  def self.table_name
    return self.to_s.downcase + "s"
  end

  def self.all
    var = self.table_name
    rows = DBConnection.execute(<<-SQL)
      SELECT
        #{var}.*
      FROM 
        #{var}
       
    SQL
    self.parse_all(rows)
  end

  def self.parse_all(results)
    arr = []
    results.each do |hash|
    arr << self.new(hash)
    end
    arr
  end

  def self.find(id)
    var = self.table_name
    res = DBConnection.execute(<<-SQL, id)
  SELECT
    #{var}.*
  FROM
    #{var}
  WHERE
    #{var}.id = ?
SQL
    return nil if res[0] == nil
   self.new(res[0])
  end

  def initialize(params = {}) 
    self.class.finalize!
    params.each do |k, v|
      # define_method(k.to_s + "=") { |v| @attributes[k] = v }  unless !params[k].nil?
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      send(k.to_s + "=", v)
    
    end
    
  end

  def attributes
    @attributes ||= {}
    @attributes
    # ...
  end

  def attribute_values
    values = self.class.columns.map{|name| self.attributes[name.to_sym] }
    values
  end

  def insert
    col_names = self.class.columns.join(",")
    question_marks = (["?"] * col_names.split(",").length).join(",")
    values = col_names.split(",").map{|name| self.attributes[name.to_sym] }
    # debugger
    DBConnection.execute(<<-SQL, values) 
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
    (#{question_marks})

  SQL

  self.id = DBConnection.last_insert_row_id


  end

  def update
      arr = []
    col_names = self.class.columns
    # question_marks = (["?"] * col_names.split(",").length).join(",")
    values = col_names.map{|name| self.attributes[name] }
    # debugger
      col_names.each_with_index do |name, i|
        arr << (name.to_s + " = " + "?")
        
      end
      string = arr.join(", ")
    DBConnection.execute(<<-SQL, values)
    UPDATE
      #{self.class.table_name}
    SET
      #{string}
    WHERE
      id = #{self.id}

  SQL

  self.id = DBConnection.last_insert_row_id

  end

  def save
   if self.class.find(self.id).nil?
    self.insert
   else
    self.update
   end
  end


end
