require_relative './gen_auth'
require_relative './httparty_adapter'

class ApiRequest
  def self.get(params={})
    start = Time.now

    auth = GenAuth.run
    response = HTTPartyAdapter.get(params)

    response_time = Time.now - start
    result = HTTPartyAdapter.parse_response(response)
    result[:total_time] = (response_time * 1000).to_i
    result
  end

  def self.post(params={})
    start = Time.now

    auth = GenAuth.run
    response = HTTPartyAdapter.post(params)

    response_time = Time.now - start
    result = HTTPartyAdapter.parse_response(response)
    result[:total_time] = (response_time * 1000).to_i
    result
  end
end
