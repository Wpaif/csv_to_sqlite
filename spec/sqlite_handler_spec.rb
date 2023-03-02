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
end
