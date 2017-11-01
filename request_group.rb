require_relative './httparty_adapter'
require_relative './api_request'
require_relative './responses_printer'

require_relative './t3/prisoners'

require 'securerandom'

# wrapper around a number of concurrent users accessing a given url
# with a given interval between each request, and between the start
# of each user
class RequestGroup
  attr_accessor :endpoints, :label,
                :number_of_users, :number_of_requests,
                :interval_between_requests, :interval_between_users,
                :verify_ssl

  def initialize(params = {})
    self.endpoints = params[:endpoints]
    self.label = params[:label]
    self.number_of_requests = params[:number_of_requests] || 1
    self.number_of_users = params[:number_of_users] || 1
    self.interval_between_requests = params[:interval_between_requests] || 0
    self.interval_between_users = params[:interval_between_users] || 0
    self.verify_ssl = params[:verify_ssl] || false
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
            result = perform_request
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

  def perform_request
    prisoner = PRISONERS[rand(PRISONERS.length)]
    endpoint = endpoints[rand(endpoints.length)]

    url = perform_substitutions(endpoint[:endpoint], prisoner)

    method = endpoint[:method]

    case method
      when :get
        result = ApiRequest.get(url: url,
                                verify: self.verify_ssl,
                                headers: { Authorization: GenAuth.run })
      when :post
        this_body = endpoint[:body].dup
        this_body.each do |key, value|
          if value == :random_hex
            this_body[key] = SecureRandom.hex
          end
        end
        result = ApiRequest.post(url: url,
                                body: this_body,
                                verify: self.verify_ssl,
                                headers: { Authorization: GenAuth.run })
    end

    result
  end

  def perform_substitutions(url, data_values)
    if url =~ /NOMIS_ID/
      url.gsub!(/NOMIS_ID/, data_values[:nomis_id])
    end

    if url =~ /PRISON_ID/
      url.gsub!(/PRISON_ID/, data_values[:prison_id])
    end

    if url =~ /DOB/
      url.gsub!(/DOB/, data_values[:dob])
    end

    if url =~ /OFFENDER_ID/
      url.gsub!(/OFFENDER_ID/, data_values[:offender_id])
    end

    if url =~ /DATETIMEENCODED/
      url.gsub!(/DATETIMEENCODED/, URI.encode((Time.now - 60).strftime("%Y-%m-%e %H:%M:%S.%L")))
    end

    if url =~ /DATETIMEISO/
      url.gsub!(/DATETIMEISO/, (Time.now - 60).utc.iso8601)
    end

    url
  end

end
