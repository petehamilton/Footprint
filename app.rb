$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra'
require 'koala'
require 'coffee-script'
require 'sass'
require 'json'

require 'lib/facebook_location'

set :raise_errors, true # Set false on prod
set :show_exceptions, true # Set false on prod

# Scope defines what permissions that we are asking the user to grant.
# In this example, we are asking for the ability to publish stories
# about using the app, access to what the user likes, and to be able
# to use their pictures.  You should rewrite this scope with whatever
# permissions your app needs.
# See https://developers.facebook.com/docs/reference/api/permissions/
# for a full list of permissions
FACEBOOK_SCOPE = 'user_likes,user_photos,user_photo_video_tags,user_checkins,friends_checkins,user_status,friends_status'

configure do
  enable :sessions
end

before do
  unless ENV["FACEBOOK_APP_ID"] && ENV["FACEBOOK_SECRET"]
    abort("missing env vars: please set FACEBOOK_APP_ID and FACEBOOK_SECRET with your app credentials")
  end

  # HTTPS redirect
  if settings.environment == :production && request.scheme != 'https'
    redirect "https://#{request.env['HTTP_HOST']}"
  end
end

helpers do
  def host
    request.env['HTTP_HOST']
  end

  def scheme
    request.scheme
  end

  def url_no_scheme(path = '')
    "//#{host}#{path}"
  end

  def url(path = '')
    "#{scheme}://#{host}#{path}"
  end

  def authenticator
    @authenticator ||= Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_SECRET"], url("/auth/facebook/callback"))
  end

end

# the facebook session expired! reset ours and restart the process
error(Koala::Facebook::APIError) do
  session[:facebook_access_token] = nil
  redirect "/auth/facebook"
end

get "/" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])
  # # query = "SELECT src FROM photo WHERE object_id=#{@location_object['id']} ORDER BY created"
  # query = "SELECT src, created FROM photo WHERE object_id IN (SELECT object_id FROM photo_tag WHERE subject=me() AND created) ORDER BY created DESC"
  # photos = @graph.fql_query(query)

  # @user    = @graph.get_object("me")
  # @friends = @graph.fql_query("SELECT uid2 FROM friend WHERE uid1 = me()")

  # raise @friends.inspect
  # raise @user.inspect
  # raise photos.inspect

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  if session[:facebook_access_token]
    @user    = @graph.get_object("me")
    # @friends = @graph.get_connections('me', 'friends')
    # @photos  = @graph.get_connections('me', 'photos')
    # @likes   = @graph.get_connections('me', 'likes').first(4)

    # for other data you can always run fql
    # @friends_using_app = @graph.fql_query("SELECT uid, name, is_app_user, pic_square FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 1")
  end
  erb :index
end

# used by Canvas apps - redirect the POST to be a regular GET
post "/" do
  redirect "/"
end

# used to close the browser window opened to post to wall/send to friends
get "/close" do
  "<body onload='window.close();'/>"
end

get "/sign_out" do
  session[:facebook_access_token] = nil
  redirect '/'
end

get "/auth/facebook" do
  session[:facebook_access_token] = nil
  redirect authenticator.url_for_oauth_code(:permissions => FACEBOOK_SCOPE)
end

get '/auth/facebook/callback' do
  session[:facebook_access_token] = authenticator.get_access_token(params[:code])
  redirect '/map'
end

require './earth_app.rb'
require './maps_app.rb'
require './checkins_app.rb'
require './love.rb'
