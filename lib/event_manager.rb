require "csv"
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

date_time = Array.new

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

def time_targeting(date_time)
  common_hours = Array.new
  date_time.each do |hour|
    if date_time.count(hour) > 2
      common_hours.push(hour)
    end
  end
  common_hours.uniq.each do |common_hour|
  p "this is a common hour:  #{common_hour}"
  end
end

event_attendees_content = CSV.open "event_attendees.csv",headers:true,header_converters: :symbol
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
event_attendees_content.each do |row|
  id = row[0]
  names = row[:first_name]
  phones = clean_phone_numbers(row[:homephone])
  reg_date = row[:regdate]
  date_time.push(DateTime.strptime(reg_date, '%m/%d/%y %H').hour)
  zipcodes = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcodes)
  form_letter = erb_template.result(binding)
  #save_thank_you_letter(id,form_letter)
end
  time_targeting(date_time)