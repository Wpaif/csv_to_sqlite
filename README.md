# CSV to SQLite

This is a simple command-line program to load data from a CSV file into an SQLite database. The program uses Ruby and requires the `sqlite3` and `csv` gems.

## Installation

To install the program, follow these steps:

1. Clone this repository to your local machine using:
```bash
git clone https://github.com/Wpaif/csv_to_sqlite.git
```
2. Run `bundle install` to install the required gems.

## Usage

To use the program, run the following command:

```bash
ruby main.rb path/to/csv/file.csv table_name
```

Replace `path/to/csv/file.csv` with the path to your **CSV file**, and `table_name` with the name of the **SQLite table** you want to create.

## Testing

To run the tests, run the following command:

```bash
bundle exec rspec
```

This will run the test suite located in the `spec` directory.

## License

This program is licensed under the MIT License. See the [LICENSE.md](LICENSE.md) file for details.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Wpaif/csv_to_sqlite. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

## Credits

This program was created by Wpaif."
