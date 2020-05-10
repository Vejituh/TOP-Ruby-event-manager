require "csv"
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def clean_zipcode(zipcodes)
  zipcodes.to_s.rjust(5,"0")[0..4]
end

event_attendees_content = CSV.open "../event_attendees.csv",headers:true,header_converters: :symbol
event_attendees_content.each do |row|
  names = row[:first_name]
  zipcodes = clean_zipcode(row[:zipcode])
  
  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcodes,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody'])
    legislators = legislators.officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
  p "#{names} #{zipcodes} #{legislators}"
end