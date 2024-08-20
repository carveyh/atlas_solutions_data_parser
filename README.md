# Atlas Solutions: Data Parser

## *Instructions:*
- Install gem dependencies:

    ```
    bundle install
    ```
- For a more robust solution that properly handles missing/empty data:

    ```
    bundle exec ruby solutions/no_dependency_solution.rb
    ```
- For a simple solution using Ruby's CSV class that satisfies the prompt (but does not attempt to handle missing/empty data):

    ```
    bundle exec ruby solutions/with_dependency_solution.rb
    ```

## *Constraints & key differences*
Based on given data, several observations assumed to be problem constraints can be made:
- *The position of each data cell always overlaps with at least 1 character of the column name it belongs to* ^1
- Spaces used as delimiters only, e.g. soccer.dat uses underscore for team names
- Cell data for each column are of the same / valid data type
- HEADER ROW: exactly one header row, begins with alphabetical character (following whitespace)
- DATA ROWS: begin with numeric digit (following whitespace)

#### Challenges:
---
Ruby's `CSV` class, and existing gems like `smarter_csv`, are not designed to handle
data with values delimited by varying whitespace (specifically, spaces, not tabs \t),
empty cells, and possible additional markup characters (e.g. '-' characters).
The column header for `id` may also be missing.

#### No dependency solution:
---
This solution attempts to solve the [prompt](prompt.md) while addressing the above challenges by matching each cell's data
to their appropriate column by comparing the bounding indices of column headers against those cell data ^1,
and adding a unique `id` column header if missing. It then populates an array of hashes manually, allowing O(1) lookup based on `id`. Depite the comparisons required, **benchmarks** show this solution to perform better than the simpler solution for the given data sets.

#### With dependency solution:
---
This solution performs a simpler cleaning of data, treating each contiguous stretch of whitespace as individual delimiters, and does not atttempt to account for empty cells. It converts said delimiters to commas, and uses Ruby's CSV class to convert the cleaned string data into an array of hashes. Note, this approach is still able to satisfy the prompts for the exercise.
