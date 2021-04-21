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
  # @param {User} user
  #   The user that's logging in.
  def sign_in(user)
    visit('/users/sign_in')
    fill_in('user_username', with: user.username)
    fill_in('user_password', with: user.password)
    click_button('Log in')
  end

  ##
  # Runs a basic search.
  # @param {Str} type
  #   The selection in the basic search dropdown - title, subject, etc.
  # @param {str} query
  #   The query to search for.
  def basic_search(type, query)
    visit root_path
    fill_in('search-field-header', with: query)
    click_button('Keyword')
    within('#search-form-header') do
      click_link(type)
    end
    click_button('Go')
  end
end
