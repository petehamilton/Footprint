# get "/auth/foursquare" do
#   session[:foursquare_access_token] = nil
#   redirect authenticator.url_for_oauth_code(:permissions => foursquare_SCOPE)
# end
@FSC = nil

def foursquare_client
  @FSC ||= Foursquare2::Client.new(:client_id => ENV['FOURSQUARE_CLIENT_ID'], :client_secret => ENV['FOURSQUARE_CLIENT_ID'])
  return @FSC
end