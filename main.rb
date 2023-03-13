# frozen_string_literal: true

require_relative 'lib/sqlite_handler'
require_relative 'lib/csv_handler'
require_relative 'lib/helpers/db_helper'

csv_path, table_name = ARGV

DBHelper.load_csv_data(csv_path:, table_name:)
