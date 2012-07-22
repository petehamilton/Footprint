get '/earth/application.js' do
  coffee :earth
end

get '/earth/application.css' do
  scss :earth
end

get "/earth" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])
  puts session.inspect
  if session[:facebook_access_token]
    @checkins = @graph.get_connections('me', 'checkins').map{|c| FacebookLocation.new(c)}
    @lons = @checkins.map{|c| c.lon}
    @lats = @checkins.map{|c| c.lat}
  else
    redirect '/auth/facebook'
  end

  erb :earth
end

get '/earth/checkins.json' do
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

get '/earth/checkin_timeline.json' do
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