require 'csv'
require 'set'
require_relative 'union_find'

class CSVGrouper
  UNIQ_ID = "uniq_id".freeze

  def initialize(csv_file, matching_type)
    @csv_file = csv_file
    @matching_type = matching_type
    @csv_data = CSV.read(csv_file, headers: true)
    @uf = UnionFind.new
    @id = 1
  end

  def perform
    target_columns = get_target_columns

    if target_columns.empty?
      puts "Unfortunately, your matching_type : '#{@matching_type}' could not find any relevant columns from #{@csv_file}. \n" \
           "Please try one of #{@csv_data.headers} concatenated with _ if you want more than one column to group by. \n" \
           "Example - `firstname`   could group_by FirstName \n" \
           "        - `name`        could group_by FirstName and LastName \n" \
           "        - `email_phone` could group_by Email1, Email2, Phone1, and Phone2 \n"
      return
    end

    puts "Processing... please wait"

    uniq_ids = process_group_by_with(target_columns)
    write_output_csv(uniq_ids, target_columns)

    puts "Finished processing #{@csv_file}. Generated processed_#{@csv_file}."
  end

  private

  def get_target_columns
    # Infer columns to "group by", from `matching_type` that is provided.
    regexes = @matching_type.split('_').map { |type| /#{Regexp.escape(type)}/i }

    # return the index of those columns
    @csv_data.headers.each_with_index
              .select { |header, _| regexes.any? { |r| header.match?(r) } }
              .map(&:last)
  end

  def process_group_by_with(target_columns)
    group_ids = {}
    group_map = {}

    @csv_data.each do |row|
      values = target_columns.map { |idx| row[idx] }.compact
      next if values.empty?

      # Add each data from target_columns
      values.each { |val| @uf.add(val) }

      # Union all values from the same row
      values.combination(2).each { |val1, val2| @uf.union(val1, val2) }

      # Find the root of the group for the first value in the row
      root = @uf.find(values.first)

      unless group_map[root]
        group_map[root] = @id
        @id += 1
      end

      # Assign the group ID to each value in the row
      values.each { |val| group_ids[val] = group_map[root] }
    end

    group_ids
  end

  def write_output_csv(uniq_ids, target_columns)
    CSV.open("processed_#{@csv_file}", 'w') do |csv_out|
      csv_out << [UNIQ_ID, *@csv_data.headers]

      @csv_data.each do |row|
        group_value = target_columns.map { |idx| row[idx] }.compact.first
        uniq_id = uniq_ids[group_value]
        if uniq_id
          csv_out << [uniq_id, *row.fields]
        else
          csv_out << [@id, *row.fields]
          @id += 1
        end
      end
    end
  end
end

# Command-line argument validation
if ARGV.size != 2
  puts "Usage: ruby grouping.rb <input_csv_file> <matching_type>" \
       "Example - `ruby grouping.rb input1.csv firstname`   could group_by FirstName \n" \
       "        - `ruby grouping.rb input1.csv name`        could group_by FirstName and LastName \n" \
       "        - `ruby grouping.rb input1.csv email_phone` could group_by Email1, Email2, Phone1, and Phone2 \n"
  exit
end

CSVGrouper.new(ARGV[0], ARGV[1]).perform
