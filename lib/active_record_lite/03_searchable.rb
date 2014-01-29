require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    search_params = params.keys.map{ |s_param| "#{s_param} = ?"}
      .join(" AND ")
    
    results = DBConnection.execute(<<-SQL, *params.values)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{search_params}
    SQL
    
    parse_all(results)
  end
end

class SQLObject
  extend Searchable
  #adds searchable method to SQLObject
end
