require "benchmark"
require "csv"

=begin
* Assumptions:
- Spaces used as delimiters only, e.g. soccer.dat uses underscore for team names
- Columns contain the same, valid data type
- HEADER ROW: exactly one header row, with column names beginning with alphabetical character
- DATA ROWS: begin with numeric digit

* Simple solution:
This solution is simpler than the no_dependency_solution, using Ruby's CSV class to convert data into an Array of Hashes.
Since the Ruby's CSV :headers option uses the first row as headers, not to mention varying white-space delimited data
with gaps and extra non-data characters, it still must be cleaned.

Unlike the other solution, it does not attempt to match cells to the proper column, resulting in some mismatches.
However, for the scope of the prompts, it still produces the correct results.
=end

# Helper method in case table missing id col name
def generate_unique_id_col_name(col_names_arr)
  num = 0
  num += 1 while col_names_arr.include?("ID-#{num}")
  "ID-#{num}"
end


# Convert varying-space-delimited values to CSV: 
# - consolidate spaces and convert them into comma delimiters, keep only /[\w. ]/ characters,
# - isolate header row and data rows only
def clean_data(filename)
  raw_content = File.read(filename).split("\n")
  formatted_content = raw_content.map {|row| row.strip.gsub(/[^\w. ]*/, "").gsub(/ +/, ",")}

  # header is first alphabetic-leading row before first numeric-leading row
  first_data_row_idx = formatted_content.index{|row| row.match?(/^\s*\d/)}
  header_idx = first_data_row_idx
  header_idx -= 1 until formatted_content[header_idx].match?(/^\s*[a-zA-Z]/)
  header_and_data_only = [formatted_content[header_idx]] 

  # prepend unique `id` col name if missing
  id_header_missing = raw_content[first_data_row_idx].match(/\d/).offset(0).last <= raw_content[header_idx].match(/[a-zA-Z]/).offset(0).first
  if(id_header_missing)
    header_string = formatted_content[header_idx]
    header_and_data_only[0] = generate_unique_id_col_name(header_string.split(",")) + "," + header_string
  end

  # extract data rows, skip any lines that don't begin with an id number, return as string
  header_and_data_only.concat(formatted_content.filter{|row| row.match?(/^\s*\d+/)}).join("\n")
end


# Given a whitespace-delimited data file,
# identify the row with the smallest difference between two specified columns, 
# and return the value of a third specified column from the identified row.
def min_range(filename, max_col, min_col, select_col)
  csv_data = clean_data(filename)
  parsed_data = CSV.parse(csv_data, headers: :first_row).map(&:to_h)
  min_range = Float::INFINITY
  min_range_idx = nil
  parsed_data.each_with_index do |row, row_idx|
    diff = (row[max_col].to_f - row[min_col].to_f).abs
    if diff < min_range
      min_range = diff
      min_range_idx = row_idx
    end
  end
  parsed_data[min_range_idx][select_col]
end


puts "Solution with CSV Class"
puts "==========================================="

time = Benchmark.measure do
  # Weather data
  data_file_path = File.expand_path("../../data/w_data.dat", __FILE__)
  smallest_diff = min_range(data_file_path, "MxT", "MnT", "Dy")
  puts "Weather: day with smallest temperature spread: ##{smallest_diff}"
end
puts "Time elapsed in seconds: #{time}"

puts

time = Benchmark.measure do
  # Soccer
  data_file_path = File.expand_path("../../data/soccer.dat", __FILE__)
  smallest_diff = min_range(data_file_path, "F", "A", "Team")
  puts "Soccer: team with smallest difference in 'for' and 'against' goals: #{smallest_diff}"
end
puts "Time elapsed in seconds: #{time}"