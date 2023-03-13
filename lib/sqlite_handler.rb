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

  # Public: Inserts data into a specified table in the database.
  #
  # table_name - The String name of the table to insert data into.
  # data - The Array of Arrays containing data to be inserted.
  #        Each inner array represents a row of data and must have the same number of elements as the table's columns.
  #
  # Examples
  #
  #   db.insert_data('People', [[1, 'John Doe', 25, 'john.doe@example.com', '2022-01-01 10:00:00', '2022-01-01 10:00:00'],
  #                             [2, 'Jane Smith', 30, 'jane.smith@example.com', '2022-01-02 11:00:00', '2022-01-02 11:00:00'],
  #                             [3, 'Bob Johnson', 35, 'bob.johnson@example.com', '2022-01-03 12:00:00', '2022-01-03 12:00:00']])
  #   # => nil
  #
  # Raises RuntimeError if the number of elements in a row of data does not match the number of columns in the table.
  #
  # Returns nil.
  def insert_data(table_name, data)
    return if data.empty?

    columns = @db.table_info(table_name).map { |column| column['name'] }

    raise 'Invalid number of columns in data' unless data.all? { |tuple| tuple.size == columns.size }

    sql = "INSERT INTO #{table_name} (#{columns.join(', ')}) VALUES (#{(['?'] * columns.size).join(', ')})"

    @db.transaction do
      data.each do |tuple|
        @db.execute(sql, *tuple)
      end
    end
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
    return if [type, size, precision].compact.none?

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
