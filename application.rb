require 'sinatra'
require 'sinatra/activerecord'

require './models/station.rb'

get '/' do
  erb :index
end
