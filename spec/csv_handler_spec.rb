# frozen_string_literal: true

require_relative '../lib/csv_handler'

describe CSVHandler do
  describe '#convert_to_hash' do
    subject(:array_of_hashs) { csv_handle.convert_to_hashes }

    let(:file_path) { File.join('tmp', 'dummy_csv') }
    let(:headers) { %w[name age email phone] }
    let(:rows) do
      Faker::Config.locale = 'pt-BR'
      10.times.map do
        [Faker::Name.name,
         Faker::Number.between(from: 18, to: 80),
         Faker::Internet.email,
         Faker::PhoneNumber.phone_number]
      end
    end
    let(:csv_handle) do
      CSV.open(file_path, 'w') do |csv|
        csv << headers
        rows.each { |row| csv << row }
      end

      described_class.new(file_path)
    end

    it 'converts CSV to an array of hashes' do
      expect(array_of_hashs).to be_an_instance_of(Array)
      expect(array_of_hashs).not_to be_empty
      expect(array_of_hashs.count).to eq(10)
      expect(array_of_hashs.first.keys).to eq(headers.map(&:downcase).map(&:to_sym))
    end

    it 'The hashes was in valid format' do
      expect(array_of_hashs.first[:name]).to eq rows.first[0]
      expect(array_of_hashs.first[:age]).to eq rows.first[1]
      expect(array_of_hashs.first[:email]).to eq rows.first[2]
      expect(array_of_hashs.first[:phone]).to eq rows.first[3]
    end
  end
end
