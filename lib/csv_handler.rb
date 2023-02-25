# frozen_string_literal: true

require 'byebug'

class CSVHandler
  def initialize(file_path)
    @file_path = "#{File.dirname(__dir__)}/#{file_path}"
  end

  def convert_to_hash
    arr = []
    collect_rows.count.times do |i|
      arr << collect_header.map(&:downcase).map(&:to_sym).zip(collect_rows[i]).to_h
    end
    arr
  end

  private

  def collect_header
    CSV.read(@file_path, headers: true).headers
  end

  def collect_rows
    rows = []
    CSV.foreach(@file_path, headers: true) do |row|
      rows << row.fields
    end
    rows
  end
end
