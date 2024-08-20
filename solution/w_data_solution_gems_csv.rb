
require 'csv'

filename = "w_data.dat"

# native Ruby csv methods attempt:
# Figure out headers
header_words = "  Dy MxT   MnT   AvT   HDDay  AvDP 1HrP TPcpn WxType PDir AvSp Dir MxS SkyC MxR MnR AvSLP".scan(/\S+/)

# Unfortunately, cannot detect empty cells due to varying length space delimiting
raw_content = File.read(filename)
normalized_content = raw_content.lines.map do |line|
  line.gsub(/^\s+/, '').gsub(/\s+/, ",")
end.join("\n")

raw_rows = CSV.parse(normalized_content, headers: true)
puts raw_rows.headers
raw_rows.each{|row| p row}