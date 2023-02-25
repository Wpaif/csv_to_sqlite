# frozen_string_literal: true

require 'csv'

class CSVHandler
  def initialize(file_path)
    @file_path = File.join(File.dirname(__dir__), file_path)
  end

  def convert_to_hash
    headers = collect_headers
    rows = collect_rows

    rows.map do |row|
      headers.map(&:downcase).map(&:to_sym).zip(row).to_h
    end
  end

  private

  def collect_headers
    CSV.read(@file_path, headers: true).headers
  end

  def collect_rows
    CSV.read(@file_path, headers: true).map(&:to_h)
  end
end
