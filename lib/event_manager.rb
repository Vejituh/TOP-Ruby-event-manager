require "csv"
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcodes)
  zipcodes.to_s.rjust(5,"0")[0..4]
end

def clean_phone_numbers(phones)
  phones.gsub!(/[^a-z0-9]/i,'')
  if
    phones.length == 11 && phones[0].to_i == 1
    phones[1,11]
  elsif phones.length < 10 || phones.length > 10
    "Invalid phone number"
  elsif
    phones.length == 11 && phones[0].to_i != 1
    "Invalid phone number"
  else
    phones
  end
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

def save_thank_you_letter(id,form_letter)
  Dir.mkdir("output") unless Dir.exists? ("output")
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

event_attendees_content = CSV.open "event_attendees.csv",headers:true,header_converters: :symbol
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
event_attendees_content.each do |row|
  id = row[0]
  names = row[:first_name]
  phones = clean_phone_numbers(row[:homephone])
  zipcodes = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcodes)
  form_letter = erb_template.result(binding)
  #save_thank_you_letter(id,form_letter)
  p phones
end