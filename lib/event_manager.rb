require "csv"

def clean_zipcode(zipcodes)
  zipcodes.to_s.rjust(5,"0")[0..4]
end

event_attendees_content = CSV.open "../event_attendees.csv",headers:true,header_converters: :symbol
event_attendees_content.each do |row|
  names = row[:first_name]
  zipcodes = clean_zipcode(row[:zipcode])
  p "#{names} #{zipcodes}"
end