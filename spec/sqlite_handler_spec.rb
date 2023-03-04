# frozen_string_literal: true

require 'sqlite3'
require_relative '../lib/sqlite_handler'

describe SqliteHandler do
  let(:db) { described_class.new(':memory:') }

  describe '#create_table' do
    let(:columns) { [%w[int_col integer], %w[float_col float], ['dec_col', 'decimal', 10, 5]] }

    it 'creates a new table with columns of different types' do
      expect { db.send(:create_table, table_name: 'People', columns:) }.not_to raise_error

      expect(db.send(:table_exists?, 'People')).to be true

      table_info = db.instance_variable_get(:@db).table_info('People')
      expect(table_info.length).to eq(columns.length)

      columns.each_with_index do |(name, type, size, precision), index|
        expect(table_info[index]['name']).to eq(name)
        expect(table_info[index]['notnull']).to eq(0)

        expected_type = case type
                        when 'integer'
                          'INTEGER'
                        when 'float'
                          'REAL'
                        when 'decimal'
                          "NUMERIC(#{size}, #{precision})"
                        else
                          "VARCHAR(#{size})"
                        end

        expect(table_info[index]['type'].upcase).to eq(expected_type)
      end
    end

    context 'when table already exists' do
      before do
        db.send(:create_table, table_name: 'People', columns:)
      end

      it 'raises an error' do
        expect { db.send(:create_table, table_name: 'People', columns:) }
          .to raise_error(RuntimeError, "The table 'People' already exists.")
      end
    end
  end

  describe '#insert_data' do
    let(:columns) do
      [
        %w[id integer],
        %w[name varchar 255],
        %w[age integer],
        %w[email varchar 255],
        %w[created_at datetime],
        %w[updated_at datetime]
      ]
    end
    let(:data) do
      [[1, 'John Doe', 25, 'john.doe@example.com', '2022-01-01 10:00:00', '2022-01-01 10:00:00'],
       [2, 'Jane Smith', 30, 'jane.smith@example.com', '2022-01-02 11:00:00', '2022-01-02 11:00:00'],
       [3, 'Bob Johnson', 35, 'bob.johnson@example.com', '2022-01-03 12:00:00', '2022-01-03 12:00:00']]
    end

    before { db.send(:create_table, table_name: 'People', columns:) }

    context 'when inserting data with the correct number of columns' do
      it 'inserts data into the table' do
        expect { db.send(:insert_data, 'People', data) }.not_to raise_error

        query = 'SELECT * FROM People;'
        results = db.instance_variable_get(:@db).execute(query)

        expect(results.length).to eq(data.length)

        results.each_with_index do |row, index|
          expect(row[0]).to eq(data[index][0])
          expect(row[1]).to eq(data[index][1])
          expect(row[2]).to eq(data[index][2])
          expect(row[3]).to eq(data[index][3])
        end
      end
    end

    context 'when inserting data with the incorrect number of columns' do
      let(:invalid_data) { [[1, 'John Doe', 25, 'john.doe@example.com', '2022-01-01 10:00:00']] }

      it 'raises an exception' do
        expect { db.send(:insert_data, 'People', invalid_data) }.to raise_error(RuntimeError)
      end
    end

    context 'when inserting an empty array' do
      let(:empty_data) { [] }

      it 'does not insert any data into the table' do
        expect { db.send(:insert_data, 'People', empty_data) }.not_to raise_error

        query = 'SELECT * FROM People;'
        results = db.instance_variable_get(:@db).execute(query)

        expect(results.length).to eq(0)
      end

      context 'when inserting data into a table with an invalid name' do
        let(:invalid_table_name) { 'Invalid Table Name' }

        it 'raises an error' do
          expect { db.send(:insert_data, invalid_table_name, data) }.to raise_error(SQLite3::SQLException)
        end
      end

      context 'when inserting data with an incorrect number of elements' do
        let(:invalid_data) { [[1, 'John Doe', 25, 'john.doe@example.com']] }

        it 'raises an error' do
          expect { db.send(:insert_data, 'People', invalid_data) }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
