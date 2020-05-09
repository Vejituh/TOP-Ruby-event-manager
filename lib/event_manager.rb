require "csv"
event_attendees_content = CSV.open "../event_attendees.csv",headers:true,header_converters: :symbol
event_attendees_content.each do |row|
  names = row[:first_name]
  zipcodes = row[:zipcode]
  p "#{names} #{zipcodes}"
end