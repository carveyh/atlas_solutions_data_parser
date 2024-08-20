
# ### CLEAN DATA

# Challenges: 
#   - non-data delimiters e.g. "-" in soccer.dat
#   - missing "id" header in soccer.dat
#   - not csv, but variable whitespace separated
#   - header row not necessarily first row, nor right above first data row
#   - empty cells in some data rows

# Approach:
#   Find the first data row, which begins with a number (id), turn into csv string
#   Find the header row, which is the first non-blank row above first data row
#   Convert first data row

# RESOURCES
# https://stackoverflow.com/questions/59679688/smarter-csv-ignore-blank-lines-in-csv
# https://stackoverflow.com/questions/14552652/how-to-convert-space-delimited-txt-file-to-delimited-txt-file-using-ruby
# https://stackoverflow.com/questions/1634750/ruby-function-to-remove-all-white-spaces
# https://stackoverflow.com/questions/42627280/how-to-correct-missing-cells-missing-delimiters-causing-shifted-data-in-sets

# Docs
# https://github.com/tilo/smarter_csv/
# https://ruby.github.io/csv/doc/csv/recipes/parsing_rdoc.html#label-Parsing+from+a+String
# https://github.com/scottwillson/tabular


# R...
# https://stackoverflow.com/questions/22229109/r-data-table-fread-command-how-to-read-large-files-with-irregular-separators/32597914#32597914