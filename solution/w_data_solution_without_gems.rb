
# Assumptions: 
# - column headers and values are never aligned in opposite directions
# - spaces used as delimiters only, e.g. soccer.dat uses underscore for team names
# - data has exactly one header row, no subheaders
# - columns contain the same data type

# ISSUE 1: cannot simply base indices of cells to equal start or end indices of col names - don't know if left or right aligned, 
#   which can differ per column - to be the start or end indices of cell data.
# FIX 1: split each data row into words, if same length as headers, we are good;
# but if there are too few or two many, we have incomplete row data, or extra markup words. However:
# > ISSUE 2: possible false positive: number of empty cells === number of extra delimiter chars

# FIX 2: start by split each data row into `words`. For each `curr_word` in row's `words`:
# Declare a row_data array to track found data in `words`, including empty values for cols
# Declare a flag, `mismatch`, in case curr_word not match col_name


# MAIN DATA CLEANING METHOD
# #######################################################
# Split data file into array of rows
# Locate headers:
#   Find first non-blank header row before first data row, then:
#     - per col_name, get starting and ending indices. Used to determine if row data is a cell based, regardless of left/right alignment
#     - check if col_name exists for `id`, if not, add it to parsed header data (not modifying original data)
# Each data row: split into `words`. Filter words for delimiters, to each col_name, map words or "" if empty cell.
# 
# To handle possible empty "cells" or extra delimiters:
# #######################################################
# Per row of `words`, declare `mismatch`, `row_data`, iterate thru each col_name of headers:
#   * If curr_word overlap with col_name, it is the data cell, add to row_data, set mismatch = false
#       Increment to next col_name
#       Increment to next curr_word
#     If not, set mismatch = true
#     If mismatch = true
#       Check if curr_word is before col_name, if so, it is delimiter, discard by ignore and increment to next curr_word
#       If not, curr_word is after, so current col_name corresponds to no data. add "" to row_data, increment to next col_name

# Ensure no overlap with any existing `id` col_names in hash
def generate_unique_id_col_name(col_names_arr)
  num = 0
  while col_names_arr.any?{|name_ele| name_ele.first == "ID-#{num}"}
    num += 1
  end
  return "ID-#{num}"
end

# Returns e.g. [["word1", [start_idx1, end_idx1]], ["word2", [start_idx2, end_idx2]], ... ]
def map_words_to_indices(string)
  indices_array = []
  string.scan(/\S+/) do |match|
    indices_array << [match, Regexp.last_match.offset(0)]
  end
  return indices_array
end

def get_col_name_indices(raw_data)
  # Identify header row
  first_data_row_idx = raw_data.index{|row| row.match?(/^\s*\d/)}
  header_idx = first_data_row_idx - 1                             # Find first non-blank header line before first data row
  while header_idx >= 0
    break if raw_data[header_idx].match?(/^\s*[a-zA-Z]/)          # Can modify to exclude delimiters / comments
    header_idx -= 1
  end

  # Get bounding indices of each column name in header row, used to match cells to columns per row
  col_name_indices = map_words_to_indices(raw_data[header_idx])

  # If the id column doesn't have a column name, add it
  sample_row_id_indices = raw_data[first_data_row_idx].match(/\S+/).offset(0)
  first_col_name_indices = col_name_indices.first.last
  if sample_row_id_indices.last < first_col_name_indices.first
    id_col_name = generate_unique_id_col_name(col_name_indices)
    col_name_indices = [[id_col_name, [0, sample_row_id_indices.last]]].concat(col_name_indices)
  end
  return col_name_indices
end

def parse_whitespace_delimited_data(filename)
  raw_data = File.read(filename).split("\n")

  # Get bounding indices of each column name in header row, used to match cells to columns per row
  col_name_indices = get_col_name_indices(raw_data)

  # Column header names identified, next parse rows: per row, compare position of "words" vs col names to determine 
  # whether word belongs to a given column, a later column (indicating empty cell), or before current column (indicating delimiter)
  cleaned_data = []
  raw_data.each do |row|
    next if !row.match?(/^\s*\d+/) # skip any lines that don't begin with an id number
    row_data = {}
    mismatch = false
    word_indices = map_words_to_indices(row)
    word_idx = 0
    col_name_idx = 0
    while col_name_idx < col_name_indices.length
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
        row_data[curr_header] = curr_word # it's a match, add k-v pair to row_data hash
        col_name_idx += 1
        word_idx += 1
      end

      # When mismatch, if word is ahead of col_name: empty cell, else it's behind: non-whitespace delimiter
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
# Accepts option hash to check for absolute value.
def min_range(filename, max_col, min_col, select_col=nil, options={abs_val: true})
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

# Weather data
data_file_path = File.expand_path("../../data/w_data.dat", __FILE__)
smallest_diff = min_range(data_file_path, "MxT", "MnT", "Dy")
puts "Weather: day with smallest temperature spread: ##{smallest_diff}"

# Soccer
data_file_path = File.expand_path("../../data/soccer.dat", __FILE__)
smallest_diff = min_range(data_file_path, "F", "A", "Team", abs_val: true)
puts "Soccer: team with smallest difference in 'for' and 'against' goals: #{smallest_diff}"