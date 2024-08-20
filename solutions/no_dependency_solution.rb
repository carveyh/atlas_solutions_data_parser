require 'benchmark'



def generate_unique_id_col_name(col_names_arr)
  num = 0
  num += 1 while col_names_arr.any?{|name_ele| name_ele.first == "ID-#{num}"}
  "ID-#{num}"
end


# Maps cell "words" with their bounding indices in original data row
# e.g. [ ["word1", [start_idx1, end_idx1]], ["word2", [start_idx2, end_idx2]], ... ]
def map_words_to_indices(string)
  indices_array = []
  string.scan(/\S+/) {|match| indices_array << [match, Regexp.last_match.offset(0)] }
  indices_array
end


# Identifies header row, and maps each column name with their bounding indices,
# prepends unique `id` column name if it is missing
def get_col_name_indices(raw_data_rows)
  # Locate header row
  first_data_row_idx = raw_data_rows.index{|row| row.match?(/^\s*\d/)}
  header_idx = first_data_row_idx
  header_idx -= 1 until raw_data_rows[header_idx].match?(/^\s*[a-zA-Z]/)

  # From header row, map each column name to its bounding indices
  col_name_indices = map_words_to_indices(raw_data_rows[header_idx])

  # If the id column doesn't have a column name, add it
  sample_row_id_indices = raw_data_rows[first_data_row_idx].match(/\S+/).offset(0)
  first_col_name_indices = col_name_indices.first.last
  if sample_row_id_indices.last < first_col_name_indices.first
    id_col_name = generate_unique_id_col_name(col_name_indices)
    col_name_indices = [[id_col_name, [0, sample_row_id_indices.last]]].concat(col_name_indices)
  end
  return col_name_indices
end


def parse_whitespace_delimited_data(filename)
  raw_data = File.read(filename).split("\n")

  # Get bounding indices of each column name in the header row, used to match cells to their appropriate columns per row
  col_name_indices = get_col_name_indices(raw_data)

  # Parse rows: per row, compare position of "words" vs col names to determine whether word occurs:
  # within a column (indicating match), in a later column (indicating empty cell), or in a previous column (indicating delimiter)
  cleaned_data = []
  raw_data.each do |row|
    next if !row.match?(/^\s*\d+/) # skip any lines that don't begin with an id number
    row_data = {} # k-v pairs: <column name> => <cell data>
    mismatch = false
    word_indices = map_words_to_indices(row)
    word_idx = 0
    col_name_idx = 0
    while col_name_idx < col_name_indices.length && word_idx < word_indices.length
      curr_header = col_name_indices[col_name_idx].first
      curr_word = word_indices[word_idx].first
      # Check if overlap, if so, row's cell matches the col
      curr_word_left = word_indices[word_idx].last.first
      curr_word_right = word_indices[word_idx].last.last
      col_name_left = col_name_indices[col_name_idx].last.first
      col_name_right = col_name_indices[col_name_idx].last.last
      if(curr_word_right <= col_name_left || col_name_right <= curr_word_left)
        mismatch = true
      else
        mismatch = false
        row_data[curr_header] = curr_word # match
        col_name_idx += 1
        word_idx += 1
      end

      if(mismatch)
        if(col_name_left < curr_word_right)
          row_data[curr_header] = "" # empty cell
          col_name_idx += 1
        else 
          word_idx += 1 # delimiter, ignore
        end
      end
    end
    cleaned_data << row_data
  end
  return cleaned_data
end


# Given a whitespace-delimited data file,
# identify the row with the smallest difference between two specified columns, 
# and return the value of a third specified column from the identified row.
# 
# Accepts option hash to check for absolute value.
def min_range(filename, max_col, min_col, select_col, options={abs_val: false})
  parsed_data = parse_whitespace_delimited_data(filename)
  min_range = Float::INFINITY
  min_range_idx = nil
  parsed_data.each_with_index do |row, row_idx|
    diff = row[max_col].to_f - row[min_col].to_f
    diff = diff.abs if options[:abs_val]
    if diff < min_range
      min_range = diff
      min_range_idx = row_idx
    end
  end
  return parsed_data[min_range_idx][select_col]
end

puts "Solution without gems or built-in CSV class"
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
  smallest_diff = min_range(data_file_path, "F", "A", "Team", abs_val: true)
  puts "Soccer: team with smallest difference in 'for' and 'against' goals: #{smallest_diff}"
end
puts "Time elapsed in seconds: #{time}"