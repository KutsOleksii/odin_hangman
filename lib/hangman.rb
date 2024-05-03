require 'csv'
require 'google/apis/civicinfo_v2'
require "erb"

# =========================== ASSIGNMENTs ===========================
def clean_phone(phone)
  digits = phone.scan(/\d+/).join
  return 'bad number' unless phone_valid?(digits)

  "(#{digits[-10,3]}) #{digits[-7,3]}-#{digits[-4..-1]}"
end

def phone_valid?(digits)
  return false if digits.size < 10 || digits.size > 11
  return false if digits.size == 11 and digits[0] != '1'
  true
end

DATETIME_VALUES = Array.new(1000) { DateTime.new(2023, 1, 1) + rand * 365 }

# ========================= ASSIGNMENTs end =========================

def clean_zipcode(zipcode)
  zipcode.to_s[0..4].rjust(5, '0')
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

datetime_values = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  datetime_values << DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M")

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end

pp max_hour = datetime_values.map(&:hour).tally.max_by {|hour, count| count}
pp max_wday = datetime_values.map(&:wday).tally.max_by {|wday, count| count}
