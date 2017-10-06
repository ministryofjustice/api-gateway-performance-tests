require 'httparty'

# abstraction of the request execution and output parsing for HTTParty
class HTTPartyAdapter
  # Perform a get request.
  # Params:
  #   :url      (required) the URL to GET
  #   :headers  (optional) any headers to provide
  def self.get(opts = {})
    raise ':url is required' unless opts[:url]
    HTTParty.get(opts[:url], verify: opts[:verify], headers: opts[:headers] || {})
  end

  def self.parse_response(response)
    timings = split_timings(response.headers['server-timing'])
    {
      code: response.code,
      appserver_time: timings['server'],
      db_time: timings['db']
    }
  end

  def self.split_timings(header)
    elements = header.to_s.split(',')
    h = {}
    elements.map{|e| e.split('=')}.each do |k,v|
      h[k]=( v ? v.to_i : '' )
    end
    h
  end
end