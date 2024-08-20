# Atlas Solutions: Data Parser

### To run, execute:
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