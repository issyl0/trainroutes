# frozen_string_literal: true

require 'csv'
require 'nokogiri'
require 'open-uri'
require 'sinatra'

helpers do
  def stations
    station_list = {}
    CSV.foreach('public/uk_national_rail_stations.csv') do |name, abbr|
      next if name == 'Station Name' && abbr == 'CRS Code'

      station_list[abbr] = name
    end

    station_list
  end

  def scrape_national_rail(station_abbr, direction)
    @direction = direction
    @selected_station = stations[station_abbr]
    nr_base_url = 'https://ojp.nationalrail.co.uk'
    nr_board = 'service/ldbboard'
    @stopping_stations = []

    begin
      nr = Nokogiri::HTML.parse(URI.parse("#{nr_base_url}/#{nr_board}/#{direction}/#{station_abbr}").open)
      structure = 'div.results.trains > div.tbl-cont > table > tbody > tr'

      # Get the end destination of the train.
      nr.css("#live-departure-board > #{structure} > td.destination").each do |destination|
        @stopping_stations.push(destination.text.strip)

        # Find the stations it stops at on its way to its destination.
        nr.css("#live-departure-board > #{structure} > td > a").each do |detail_url|
          du = Nokogiri::HTML.parse(URI.parse("#{nr_base_url}#{detail_url['href']}").open)
          du.css("#live-departure-details > #{structure} > td.station").each do |stopping_station|
            @stopping_stations.push(stopping_station.text.strip)
          end
        end
      end
    rescue RuntimeError
      @stopping_stations
    end
  end
end

get '/' do
  erb :index
end

post '/search' do
  station_abbr = params[:station_name].split('[')[1].split(']')[0].strip

  if stations[station_abbr]
    direction = if params[:arrival_station] == 'on'
                  'arr'
                elsif params[:departure_station] == 'on'
                  'dep'
                end
    scrape_national_rail(station_abbr, direction)
  end
  erb :search_results
end
