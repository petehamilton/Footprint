get '/map/application.js' do
  coffee :map
end

get '/map/application.css' do
  scss :map
end

get "/map" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])
  puts session.inspect
  if session[:facebook_access_token]
    @result = @graph.get_connections('me', 'locations')
    @checkins = (@result).map{|c| FacebookLocation.new(c)}
  else
    redirect '/auth/facebook'
  end
  erb :map
end

get '/map/checkins.json' do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  if session[:facebook_access_token]
    @result = @graph.get_connections('me', 'locations')
    @checkins = (@result).reverse!
  else
    redirect '/auth/facebook'
  end
  
  fbcheckins = @checkins.map{|c| FacebookLocation.new(c)}

  fbcheckins.each do |c|
    c.location_object['photos'] = c.get_images(session)
  end

  real_checkins = fbcheckins.map{|c| c.location_object}
  # raise real_checkins.inspect

  content_type :json
  real_checkins.to_json
end

get '/map/checkin_timeline.json' do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  if session[:facebook_access_token]
    @result = @graph.get_connections('me', 'locations')
    @checkins = @result
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