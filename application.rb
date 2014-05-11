require 'sinatra'
require 'sinatra/activerecord'

require './models/station.rb'

get '/' do
  erb :index
end

post '/search' do
  # Search code here...
end
