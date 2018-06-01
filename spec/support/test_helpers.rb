module TestHelpers
  def active_link?(url)
    uri = URI.parse(url)
    response = nil
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.head(!uri.path.empty? ? uri.path : "/")
    end
    response.code == "200"
  end

  ##
  # Signs in.
  #
  # @params
  #   user {User} The user that's logging in.
  def sign_in(user)
    visit('/users/sign_in')
    fill_in('user_username', with: user.username)
    fill_in('user_password', with: user.password)
    click_button('Log in')
  end
end
