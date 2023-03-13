# frozen_string_literal: true

require_relative '../sqlite_handler'
require_relative '../csv_handler'

# The DBHelper module provides methods for loading data from CSV files into SQLite databases
module DBHelper
  # Loads data from a CSV file into a specified table in a SQLite database
  #
  # @param csv_path [String] the file path of the CSV file to load
  # @param table_name [String] the name of the table to create and load data into
  #
  # @return [void]
  def self.load_csv_data(csv_path:, table_name:)
    absolute_path = File.absolute_path(File.dirname(csv_path)).concat('/db.sqlite')
    hashes = CSVHandler.new(csv_path).convert_to_hashes
    headers = hashes[0].keys.map(&:to_s)
    values = remove_null_array(hashes.map(&:values))

    db = SqliteHandler.new(absolute_path)
    db.create_table(table_name: table_name.upcase, columns: headers)
    db.insert_data(table_name, values)
  end

  # Removes any subarrays in a 2D array that have only nil values
  #
  # @param arr [Array<Array>] the 2D array to remove null subarrays from
  #
  # @return [Array<Array>] the modified 2D array without null subarrays
  def self.remove_null_array(arr)
    arr.select { |subarray| subarray.compact.any? }
  end
end
