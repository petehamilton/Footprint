get "/auth/facebook" do
  session[:facebook_access_token] = nil
  redirect authenticator.url_for_oauth_code(:permissions => FACEBOOK_SCOPE)
end

get '/auth/facebook/callback' do
  session[:facebook_access_token] = authenticator.get_access_token(params[:code])
  redirect '/'
end