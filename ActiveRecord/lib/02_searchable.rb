require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable

   def where(params)
    keys = params.keys
    values = params.values 
    string = keys.map{ |key| key.to_s + " = ?"}.join(" AND ")
  res = DBConnection.execute(<<-SQL, values)
SELECT
  *
FROM
  #{self.to_s.downcase + "s"}
WHERE
    #{string}
   

SQL
res.map{|hash| self.new(hash)}
# [self.new(res[0])]
end
  
end

class SQLObject
  extend Searchable
end
