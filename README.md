# Requirement
- ruby@3.2.7

# Sample Usages

## Usage: ruby grouping.rb <input_csv_file> <matching_type>

- ruby grouping.rb input1.csv name         (group by FirstName and LastName)
- ruby grouping.rb input2.csv email        (group by Email1 and Email2)
- ruby grouping.rb input3.csv email_phone  (group by Email1, Email2, Phone1, and Phone2)
- ruby grouping.rb input3.csv email_zip    (group by Email1, Email2, and Zip)

# Output
- processed_#{input_csv_file} in the same directory
