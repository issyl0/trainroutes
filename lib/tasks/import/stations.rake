require 'csv'
require 'rest-client'

namespace :import do
  desc 'Import the list of current UK railway stations.'
  task :stations do
    CSV.foreach("public/uk_national_rail_stations.csv") do |name, abbr|
      next if name == "Station Name" && abbr == "CRS Code"

      Station.create(name: name, abbr: abbr) unless Station.find_by(name: name)
    end
    puts "Stations created."
  end
end
