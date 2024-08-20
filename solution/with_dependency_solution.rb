require "csv"
require "benchmark"

# Helper method in case table missing id col name
def generate_unique_id_col_name(col_names_arr)
  num = 0
  num += 1 while col_names_arr.include?("ID-#{num}")
  "ID-#{num}"
end

# Convert varying-space-delimited values to CSV: 
# - consolidate spaces and convert them into comma delimiters, keep only [\w. ] characters,
# - isolate header row and data rows only
def clean_data(filename)
  raw_content = File.read(filename).split("\n")
  formatted_content = raw_content.map {|row| row.strip.gsub(/[^\w. ]*/, "").gsub(/ +/, ",")}

  # header is first non-numeric-leading row before first numeric-leading row
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

  # add data rows, skip any lines that don't begin with an id number
  header_and_data_only.concat(formatted_content.filter{|row| row.match?(/^\s*\d+/)}).join("\n")
end

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



# fileword = "customers-100.csv"
# fileword = "soccer.dat"
# fileword = "w_data.dat"
# filename = File.expand_path("../../data/#{fileword}", __FILE__)

# puts min_range(filename, "F", "A", "Team")
# puts min_range(filename, "MxT", "MnT", "Dy")

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