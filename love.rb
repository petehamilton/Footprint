get '/love/application.js' do
  coffee :love
end

get '/love/application.css' do
  scss :love
end

get "/love" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])
  puts session.inspect
  if session[:facebook_access_token]
      @taggedPhotosOfMeByDate  = @graph.fql_query("SELECT src_big, caption FROM photo WHERE object_id IN (SELECT object_id FROM photo_tag WHERE subject=me()) ORDER BY created LIMIT 10")
      YourUID = @graph.fql_query("SELECT uid FROM user WHERE username='SiTox'")
      unless YourUID.nil?
        @taggedPhotosOfYouByDate = @graph.fql_query("SELECT src_big, caption FROM photo WHERE object_id IN (SELECT object_id FROM photo_tag WHERE subject=" + YourUID[0]["uid"].to_s + ") ORDER BY created LIMIT 10")
      end
  else
    redirect '/auth/facebook'
  end
  puts @taggedPhotosByDate
  erb :love
end