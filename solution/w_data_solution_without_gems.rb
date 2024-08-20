
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
  print col_names_arr
  while col_names_arr.any?{|name_ele| name_ele.first == "ID-#{num}"}
    num += 1
  end
  return "ID-#{num}"
end

# Returns e.g. [["word1", [start_idx1, end_idx1]], ["word2", [start_idx2, end_idx2]], ... ]
def map_words_to_start_end_indices(string)
  indices_array = []
  string.scan(/\S+/) do |match|
    indices_array << [match, Regexp.last_match.offset(0)]
  end
  return indices_array
end

def parse_whitespace_delimited_data(filename)
  # Split data file into array of rows, 
  raw_data = File.read(filename).split("\n")
  # Identify header row, ensure `id` col_name, setup indices
  first_data_row_idx = raw_data.index{|row| row.match?(/^\s*\d/)} # Find first line of data starting with a numerical digit, 
  raise "Data format not recognized" if first_data_row_idx == nil # If no data beginning with an id number, exit early
  header_idx = first_data_row_idx - 1                             # Find first non-blank header line before it
  while header_idx >= 0
    break if raw_data[header_idx].match?(/^\s*[a-zA-Z]/)
    header_idx -= 1
  end

  # Get starting and ending indices of each column header "word"
  col_name_indices = map_words_to_start_end_indices(raw_data[header_idx])

  # If id column doesn't have header, add it
  raw_data[first_data_row_idx].match(/\S+/)
  id_indices = Regexp.last_match.offset(0)
  if id_indices.last < col_name_indices.first.last.first
    id_col_name = generate_unique_id_col_name(col_name_indices)
    col_name_indices = [[id_col_name, [0, id_indices.last]]].concat(col_name_indices)
  end

  # With headers ready, clean each data row - discard delimiters, add empty strings for "empty" cells
  # cleaned_data = [col_name_indices.keys.join(",")] # initialize with headers row
  cleaned_data = []
  raw_data.each do |row|
    next if !row.match?(/^\s*\d+/) # skip any lines that don't begin with an id number
    row_data = {}
    mismatch = false
    word_indices = map_words_to_start_end_indices(row)
    word_idx = 0
    col_name_idx = 0
    while col_name_idx < col_name_indices.length
      curr_header = col_name_indices[col_name_idx].first
      curr_word = word_indices[word_idx].first
      # Check if overlap, if so, row's cell matches the col
      if(!(word_indices[word_idx].last.last <= col_name_indices[col_name_idx].last.first || 
        col_name_indices[col_name_idx].last.last <= word_indices[word_idx].last.first
      ))
        mismatch = false
        row_data[curr_header] = curr_word # it's a match, add it to the row_data object
        col_name_idx += 1
        word_idx += 1
      else
        mismatch = true
      end

      # If mismatch, check if word is ahead of col_name (meaning empty cell), or if word is behind col_name (meaning delimiter)
      if(mismatch)
        # If word is ahead of col_name
        if(col_name_indices[col_name_idx].last.first < word_indices[word_idx].last.last)
          row_data[curr_header] = "" # empty cell
          col_name_idx += 1
        else
          word_idx += 1 # delimiter, ignore it and move onto next word
        end
      end
    end
    if ["10", "13"].include?(word_indices.first.first)
    end
    cleaned_data << row_data
  end
  return cleaned_data
end

def min_spread(filename, max_col, min_col, select_col=nil, options={abs_val: true})
  raise "Please specify file" if !filename
  raise "Please specify columns to compare" if !max_col || !min_col
  parsed_data = parse_whitespace_delimited_data(filename)
  min_spread = Float::INFINITY
  min_spread_idx = nil
  parsed_data.each_with_index do |row, row_idx|
    diff = row[max_col].to_f - row[min_col].to_f
    diff = diff.abs if options[:abs_val]
    puts "#{select_col}: #{row[select_col]}: #{row[max_col]} - #{row[min_col]} = #{diff}"
    if diff < min_spread
      min_spread = diff
      min_spread_idx = row_idx
    end
  end
  return select_col ? parsed_data[min_spread_idx][select_col] : parsed_data[min_spread_idx]
end

# Weather data
filename = "../../data/w_data.dat"
data_file_path = File.expand_path(filename, __FILE__)
puts min_spread(data_file_path, "MxT", "MnT", "Dy")

# Soccer
filename = "../../data/soccer.dat"
data_file_path = File.expand_path(filename, __FILE__)
puts min_spread(data_file_path, "F", "A", "Team", abs_val: true)