require_relative './httparty_adapter'
require_relative './api_request'
require_relative './responses_printer'

# wrapper around a number of concurrent users accessing a given url
# with a given interval between each request, and between the start
# of each user
class RequestGroup
  attr_accessor :url, :label,
                :number_of_users, :number_of_requests,
                :interval_between_requests, :interval_between_users

  def initialize(params = {})
    self.url = params[:url]
    self.label = params[:label]
    self.number_of_requests = params[:number_of_requests] || 1
    self.number_of_users = params[:number_of_users] || 1
    self.interval_between_requests = params[:interval_between_requests] || 0
    self.interval_between_users = params[:interval_between_users] || 0
  end

  def run(threads, responses)
    number_of_users.times.each do |user_no|
      prefix = "[#{label} user #{user_no}]"
      puts "#{prefix} starting"
      user_threads = []
      threads << Thread.new do
        number_of_requests.times do |request_no|
          request_prefix = "#{prefix} request #{request_no}"
          puts "#{request_prefix} starting"
          begin
            result = ApiRequest.get(url: url,
                                    headers: { Authorization: GenAuth.run })
            responses << result
            ResponsesPrinter.print(result, request_prefix)
          rescue => e
            puts "#{request_prefix} exception - #{e.message}"
            puts e.backtrace
          end
          puts "#{prefix} waiting #{interval_between_requests}s between requests"
          sleep(interval_between_requests)
        end
      end
      puts "#{prefix} finished"
      puts "waiting #{interval_between_users}s between users"
      sleep(interval_between_users)
    end
  end

end
