# frozen_string_literal: true

require 'csv'

# A utility class for handling CSV files
class CSVHandler
  # Initializes a new CSVHandler instance
  #
  # @param file_path [String] The path to the CSV file
  def initialize(file_path)
    @file_path = file_path
  end

  # Converts the CSV file to an array of hashes
  #
  # @return [Array<Hash>] An array of hashes representing the rows in the CSV file,
  #   with headers as keys and values as values. Numeric values are automatically
  #   converted to either integers or floats, depending on their format.
  def convert_to_hashes
    headers = csv_headers
    rows = csv_rows

    rows.map do |row|
      hash = headers.zip(row).to_h
      convert_values_to_number(hash)
    end
  end

  private

  # Converts string values to either integers or floats, depending on their format
  #
  # @param hash [Hash] The hash to convert values for
  # @return [Hash] A new hash with numeric values converted to either integers or floats
  def convert_values_to_number(hash)
    hash.transform_values do |value|
      case value
      when /^\d+$/
        value.to_i
      when /^\d+\.\d+$/
        value.to_f
      else
        value
      end
    end
  end

  # Retrieves the headers from the CSV file
  #
  # @return [Array<Symbol>] An array of symbols representing the headers in the CSV file
  def csv_headers
    CSV.read(@file_path, headers: true).headers.map { |header| normalize_string(header).to_sym }
  end

  # Normalize a string by converting it to lowercase, removing diacritical marks and replacing spaces and slashes with underscores.
  #
  # @param str [String] the string to be normalized
  # @return [String] the normalized string
  def normalize_string(str)
    str.downcase.strip.tr('áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc').gsub(%r{\s|/}, '_')
  end

  # Retrieves the rows from the CSV file
  #
  # @return [Array<Array<String>>] An array of arrays representing the rows in the CSV file,
  #   with each inner array representing a single row and containing the cell values as strings
  def csv_rows
    CSV.read(@file_path, headers: true).map(&:to_h).map(&:values)
  end
end
