require 'csv'
require 'rest-client'

namespace :import do
  desc 'Import the list of current UK railway stations.'
  task :stations do
    CSV.parse(RestClient.get('https://www.nationalrail.co.uk/static/documents/content/station_codes.csv').body).each do |name, abbr|
      next if name == "Station Name" && abbr == "CRS Code"

      Station.create(name: name, abbr: abbr) unless Station.find_by(name: name)
    end
    puts "Stations created."
  end
end
