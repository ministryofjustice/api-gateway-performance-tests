require 'benchmark'

require_relative './gen_auth'
require_relative './httparty_adapter'

class ApiRequest

  def self.get(params={})
    result = timed_request(:get, params)
    format_result(result)
  end

  def self.post(params={})
    result = timed_request(:post, params)
    format_result(result)
  end

  protected

  def self.format_result(result)
    formatted_result = HTTPartyAdapter.parse_response(result[:response])
    formatted_result[:total_time] = result[:time]
    formatted_result
  end

  def self.timed_request(verb, params)
    response = nil

    response_time = Benchmark.realtime do
      auth = GenAuth.run
      response = HTTPartyAdapter.send(verb, params)
    end
    # we want response time in ms
    {response: response, time: response_time * 1000}
  end

end
