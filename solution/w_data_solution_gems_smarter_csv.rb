require 'smarter_csv'

filename = "w_data.dat"

# smarter_csv version doesn't work, SmarterCSV::NoColSepDetected error
def min_spread_finder(filename, max_col_name=nil, min_col_name=nil)
  # raw_data = File.read(filename)
  options = {
    # row_sep: "\n", 
    comment_regexp: /^/,
    strip_whitespace: true, 
    # col_sep: " ",
    # strip_chars_from_headers: "\s*",
  }
  parsed_data = SmarterCSV.process(filename, options)
  puts parsed_data
  # reader = SmarterCSV::Reader.new(filename, options)
  # parsed_data = reader.process
  # puts reader.raw_headers
end
min_spread_finder(filename)
