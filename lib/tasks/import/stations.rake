require 'csv'

namespace :import do
  desc 'Import the list of current UK railway stations.'
  task :stations do
    CSV.foreach('public/assets/files/station_codes.csv', { :headers => true }) do |station|
      if !Station.where(name: station[0]).first
        Station.create(name: station[0], abbr: station[1])
      end
    end
    puts "Stations created."
  end
end
