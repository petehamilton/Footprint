get "/checkins" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])
  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  if session[:facebook_access_token]
    @checkins = @graph.get_connections('me', 'checkins').map{|c| FacebookLocation.new(c)}
  else
    redirect '/auth/facebook'
  end
  # raise foursquare_client.inspect
  # @fsc = foursquare_client.user_checkins

  erb :checkins
end