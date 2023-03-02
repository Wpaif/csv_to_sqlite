# frozen_string_literal: true

require 'sqlite3'

class SqliteHandler
  # Initializes a new instance of the SqliteHandler class.
  #
  # @param database_path [String] The path to the SQLite database file.
  def initialize(database_path)
    @db = SQLite3::Database.new(database_path)
  end

  # Creates a new table in the SQLite database with the specified table name and columns.
  #
  # @param table_name [String] The name of the table to create.
  # @param columns [Array<Array<String, String, Integer, Integer>>] An array of column definitions, where each column is an array of [name, type, size, precision].
  # @raise [RuntimeError] If the table already exists in the database.
  def create_table(table_name:, columns:)
    raise "The table '#{table_name}' already exists." if table_exists?(table_name)

    columns_sql = columns.map { |column| column_sql(column) }.join(', ')

    query = "CREATE TABLE #{table_name} (#{columns_sql});"
    @db.execute(query)
  end

  private

  # Returns the SQL statement for creating a column with the specified name, type, size, and precision.
  #
  # @param column [Array<String, String, Integer, Integer>] The column definition as an array of [name, type, size, precision].
  # @return [String] The SQL statement for creating the column.
  def column_sql(column)
    name, type, size, precision = column
    "#{name} #{column_type_sql(type, size, precision)}"
  end

  # Returns the SQL data type for the specified column type, size, and precision.
  #
  # @param type [String] The column type.
  # @param size [Integer] The column size (if applicable).
  # @param precision [Integer] The column precision (if applicable).
  # @return [String] The SQL data type for the specified column type, size, and precision.
  def column_type_sql(type, size, precision)
    sql_types = {
      'integer' => 'INTEGER',
      'float' => 'REAL',
      'decimal' => 'NUMERIC(%<size>s, %<precision>s)',
      'datetime' => 'DATETIME',
      'boolean' => 'BOOLEAN'
    }

    return format(sql_types[type.downcase], size:, precision:) if type.downcase == 'decimal'

    sql_types[type.downcase] || "VARCHAR(#{size})"
  end

  # Returns whether the specified table exists in the SQLite database.
  #
  # @param table_name [String] The name of the table to check.
  # @return [Boolean] Whether the specified table exists in the SQLite database.
  def table_exists?(table_name)
    @db.table_info(table_name).any?
  end
end
