$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra'
require 'koala'
require 'coffee-script'
require 'sass'
require 'json'

require 'lib/facebook_checkin'

set :raise_errors, true # Set false on prod
set :show_exceptions, true # Set false on prod

# Scope defines what permissions that we are asking the user to grant.
# In this example, we are asking for the ability to publish stories
# about using the app, access to what the user likes, and to be able
# to use their pictures.  You should rewrite this scope with whatever
# permissions your app needs.
# See https://developers.facebook.com/docs/reference/api/permissions/
# for a full list of permissions
FACEBOOK_SCOPE = 'user_likes,user_photos,user_photo_video_tags'

unless ENV["FACEBOOK_APP_ID"] && ENV["FACEBOOK_SECRET"]
  abort("missing env vars: please set FACEBOOK_APP_ID and FACEBOOK_SECRET with your app credentials")
end

configure do
  enable :sessions
end

before do
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
  session[:access_token] = nil
  redirect "/auth/facebook"
end

get '/javascripts/application.js' do
  coffee :application
end

get '/stylesheets/application.css' do
  scss :application
end

get "/" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  if session[:access_token]
    @user    = @graph.get_object("me")
    @friends = @graph.get_connections('me', 'friends')
    @photos  = @graph.get_connections('me', 'photos')
    @likes   = @graph.get_connections('me', 'likes').first(4)

    # for other data you can always run fql
    @friends_using_app = @graph.fql_query("SELECT uid, name, is_app_user, pic_square FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 1")
  end
  erb :index
end

get "/checkins" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  if session[:facebook_access_token]
    @checkins = @graph.get_connections('me', 'checkins').map{|c| FacebookCheckin.new(c)}
  else
    redirect '/auth/facebook'
  end

  erb :checkins
end

get '/checkins.json' do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  if session[:facebook_access_token]
    @checkins = @graph.get_connections('me', 'checkins').reverse!
  else
    redirect '/auth/facebook'
  end

  content_type :json
  # @checkins.map{|c| {lat: c.lat, lon: c.lon}}.to_json
  @checkins.to_json
end

get '/checkin_timeline.json' do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  if session[:facebook_access_token]
    @checkins = @graph.get_connections('me', 'checkins')
  else
    redirect '/auth/facebook'
  end

  content_type :json
  timeline_checkins = @checkins.map do |c|
    {
      "startDate" => Date.strptime("#{c['created_time'][0..9]}", "%Y-%m-%d").strftime("%Y,%m,%d"),
      "headline" => "#{c['place']['name']}",
      "text" => "",
      "asset" => {
          "media" => "",
          "thumbnail" => "http://www.contagiousmagazine.com/magazine/upload/Facebook-Places-Icon-Large_midinail_39x39.jpg",
          "credit" => "",
          "caption" => ""
      }
    }
  end

  timeline_data = {
    "timeline" => {
        "headline" => "Sh*t People Say",
        "type" => "default",
        "text" => "People say stuff",
        "date" => timeline_checkins
    }
  }

  content_type :json
  # @checkins.map{|c| {lat: c.lat, lon: c.lon}}.to_json
  timeline_data.to_json
end

get "/earth" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])
  puts session.inspect
  if session[:facebook_access_token]
    @checkins = @graph.get_connections('me', 'checkins').map{|c| FacebookCheckin.new(c)}
    @lons = @checkins.map{|c| c.lon}
    @lats = @checkins.map{|c| c.lat}
  else
    redirect '/auth/facebook'
  end

  erb :earth
end

get "/map" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])
  puts session.inspect
  if session[:facebook_access_token]
    @checkins = @graph.get_connections('me', 'checkins').map{|c| FacebookCheckin.new(c)}
  else
    redirect '/auth/facebook'
  end
  erb :map
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
	redirect '/'
end
