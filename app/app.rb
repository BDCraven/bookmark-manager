ENV["RACK_ENV"] ||= "development"

require 'sinatra/base'
require 'sinatra/flash'
# require_relative 'models/link'
require_relative 'data_mapper_setup'


class BookmarkManager < Sinatra::Base
  register Sinatra::Flash
  enable :sessions
  set :sessions_secret, 'super secret'

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
    params[:tags].split.each do |tag|
      link.tags << Tag.first_or_create(name: tag)
    end
    link.save # 4. Saving the link.
    redirect '/links'
  end

  get '/tags/:name' do
    tag = Tag.first(name: params[:name])
    @links = tag ? tag.links : []
    erb :'links/index'
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    # p params
    # we just inialize the object
    # without saving it. It may be invalid
    @user = User.new(email: params[:email],
                password: params[:password],
                password_confirmation: params[:password_confirmation])
                # p @user.password
    if @user.save #save returns true/false depending on whether the model is successfully saved to the database.
    # the user.id will be nil if the user wasn't saved
    # because of password mismatch
      session[:user_id] = @user.id
      redirect to('/links')
      # if it's not valid,
      # we'll render the sign up form again
    else
      flash.now[:notice] = 'Password and confirmation password do not match'
      erb :'users/new'
    end
  end

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
