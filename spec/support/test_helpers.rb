module TestHelpers
  def active_link?(url)
    uri = URI.parse(url)
    response = nil
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.head(!uri.path.empty? ? uri.path : "/")
    end
    response.code == "200"
  end
end
