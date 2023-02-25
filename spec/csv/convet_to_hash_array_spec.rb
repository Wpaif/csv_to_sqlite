# frozen_string_literal: true

require 'faker'
require 'csv'
require_relative '../../lib/csv_handler'

describe 'CSV Conversion' do
  it 'can be converted to an array of hash' do
    headers = %w[name age email phone]
    rows = 10.times.map do
      [Faker::Name.name,
       Faker::Number.between(from: 18, to: 80),
       Faker::Internet.email,
       Faker::PhoneNumber.phone_number]
    end

    CSV.open('tmp/exemplo.csv', 'w') do |csv|
      csv << headers
      rows.each { |row| csv << row }
    end

    csv_handle = CSVHandler.new('tmp/exemplo.csv')
    array_of_hash = csv_handle.convert_to_hash

    expect(array_of_hash).not_to be_empty
    expect(array_of_hash.count).to eq(10)
    expect(array_of_hash.first.keys).to eq(headers.map(&:to_sym))
  end
end
