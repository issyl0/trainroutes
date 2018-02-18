require 'sinatra'
require 'sinatra/activerecord'
require 'nokogiri'
require 'open-uri'

require './models/station.rb'

helpers do
  def find_station(station)
    Station.where(name: station).first
  end

  def scrape_national_rail(station_abbr,dep=nil)
    @selected_station = station_abbr
    nr_base_url = "http://ojp.nationalrail.co.uk"
    nr_board = "service/ldbboard"
    @stopping_stations = []

    nr = Nokogiri::HTML.parse(open("#{nr_base_url}/#{nr_board}/#{dep ? 'dep' : 'arr'}/#{station_abbr}"))
    structure = "div.results.trains > div.tbl-cont > table > tbody > tr"

    # Get the end destination of the train.
    nr.css("#live-departure-board > #{structure} > td.destination").each do |destination|
      @stopping_stations.push(destination.text.strip)

      # Find the stations it stops at on its way to its destination.
      nr.css("#live-departure-board > #{structure} > td > a").each do |detail_url|
        du = Nokogiri::HTML.parse(open("#{nr_base_url}#{detail_url['href']}"))
        du.css("#live-departure-details > #{structure} > td.station").each do |stopping_station|
          @stopping_stations.push(stopping_station.text.strip)
        end
      end
    end
  end
end

get '/' do
  erb :index
end

post '/search' do
  # Check that the requested station exists.
  if station_abbr = find_station(params[:station_name].split('(')[0].strip).abbr
    if params[:arrival_station] == 'on'
      scrape_national_rail(station_abbr)
    elsif params[:departure_station] == 'on'
      scrape_national_rail(station_abbr,'dep')
    end
  end
  erb :search_results
end
