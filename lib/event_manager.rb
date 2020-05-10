require "csv"
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcodes)
  zipcodes.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

event_attendees_content = CSV.open "event_attendees.csv",headers:true,header_converters: :symbol
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
event_attendees_content.each do |row|
  names = row[:first_name]
  zipcodes = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcodes)
  form_letter = erb_template.result(binding)

  #p "#{names} #{zipcodes} #{legislators}"
  p form_letter
end