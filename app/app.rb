ENV["RACK_ENV"] ||= "development"

require 'sinatra/base'
# require_relative 'models/link'
require_relative 'data_mapper_setup'

class BookmarkManager < Sinatra::Base
  get '/' do
    'Testing infrastructure working!'
  end

  get '/links' do
    @links = Link.all
    erb :'links/index'
  end

  get '/links/new' do
    erb :'links/new'
  end

  post '/links' do
    link = Link.new(url: params[:url], title: params[:title])  # 1. Create a link
    tag = Tag.first_or_create(name: params[:tags]) # 2. Create a tag for the link
    link.tags << tag # 3. Adding the tag to the link's DataMapper collection.
    link.save # 4. Saving the link.
    redirect '/links'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
