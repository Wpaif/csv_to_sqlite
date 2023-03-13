# frozen_string_literal: true

require 'csv'
require_relative '../../lib/csv_handler'
require_relative '../../lib/sqlite_handler'
require_relative '../../lib/helpers/db_helper'

RSpec.describe DBHelper do
  let(:csv_path) { File.join(Dir.pwd, 'tmp', 'test.csv') }
  let(:db_path) { File.join(Dir.pwd, 'tmp', 'db.sqlite') }
  let(:table_name) { 'TEST_TABLE' }
  let(:csv_data) { "name,age\nJohn,30\nJane,\n" }

  describe '.load_csv_data' do
    let(:csv_handler_mock) { instance_double(CSVHandler, convert_to_hashes: csv_hashes) }
    let(:sqlite_handler_mock) { spy(SqliteHandler) }
    let(:csv_hashes) do
      [{ 'name' => 'John', 'age' => '30' }, { 'name' => 'Jane', 'age' => nil }]
    end

    before do
      allow(CSVHandler).to receive(:new).with(csv_path).and_return(csv_handler_mock)
      allow(SqliteHandler).to receive(:new).with(db_path).and_return(sqlite_handler_mock)
    end

    after do
      FileUtils.rm_rf('tmp/*')
    end

    it 'creates table and inserts data to database' do
      described_class.load_csv_data(csv_path:, table_name:)

      expect(sqlite_handler_mock).to have_received(:create_table).with(table_name:, columns: %w[name age])
      expect(sqlite_handler_mock).to have_received(:insert_data).with(table_name, [%w[John 30], ['Jane', nil]])
    end
  end

  describe '.remove_null_array' do
    it 'removes subarrays that contain only nil values' do
      arr = [[1, 2, nil], [3, nil, nil], [nil, nil, nil]]
      expect(described_class.remove_null_array(arr)).to eq([[1, 2, nil], [3, nil, nil]])
    end

    it 'does not remove subarrays that contain at least one non-nil value' do
      arr = [[1, nil], [nil, 2]]
      expect(described_class.remove_null_array(arr)).to eq([[1, nil], [nil, 2]])
    end

    it 'does not modify the original array' do
      arr = [[1, nil], [nil, 2]]
      described_class.remove_null_array(arr)
      expect(arr).to eq([[1, nil], [nil, 2]])
    end
  end
end
