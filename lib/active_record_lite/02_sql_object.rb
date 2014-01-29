require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map{ |result| self.new(result) }
  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
    #if you have the table name defined, return it
    #otherwise, convert the stringy table name into an SQL format
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    
    SQL
    
    parse_all(results)
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = ?
    
    SQL
    
    parse_all(results)[0]
    #parse_all returns array, but in this case it will have 1 elt.
    #so just return that element
  end

  def insert
    columns = self.class.attributes.join(", ")
    #puts attributes into SQL column format
    q_marks = (["?"]*self.class.attributes.count).join(", ")
    #number of question marks necessary for VALUES insertion
    
    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{columns})
    VALUES
      (#{q_marks})
    SQL
      
    self.id = DBConnection.last_insert_row_id
    #apparently this is a method
  end

  def update
    set_attributes = self.class.attributes.map{ |attr| "#{attr} = ?"}
      .join(", ")
    #string of attributes to be set
    DBConnection.execute(<<-SQL, *attribute_values, id)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_attributes}
    WHERE
      #{self.class.table_name}.id = ?
    SQL
  end
  
  def save
    #if the item has an ID it needs to be updated,
    #else create a new record
    
    if id.nil?
      insert
    else
      update
    end
  end

  def attribute_values
    self.class.attributes.map{ |attr| self.send(attr) }
  end
  
end
