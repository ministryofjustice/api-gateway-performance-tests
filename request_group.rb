require_relative './httparty_adapter'
require_relative './api_request'
require_relative './responses_printer'

# wrapper around a number of concurrent users accessing a given url
# with a given interval between each request, and between the start
# of each user
class RequestGroup
  PRISONERS = [
    { prisoner_id: "G4027GP", prison_id: "FNI" },
    { prisoner_id: "G4805UP", prison_id: "CFI" },
    { prisoner_id: "G0351UK", prison_id: "LLI" },
    { prisoner_id: "G4591GU", prison_id: "WLI" },
    { prisoner_id: "G5507UO", prison_id: "WYI" },
    { prisoner_id: "G0682VU", prison_id: "LEI" }
  ]

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
            prisoner = PRISONERS[rand(PRISONERS.length + 1)]

            endpoint = endpoints[rand(endpoints.length + 1)]]

            url = endpoint[:endpoint]

            if url =~ /NOMS_ID/
              url.gsub!(/NOMS_ID/, prisoner[:prisoner_id])
            end

            if url =~ /PRISON_ID/
              url.gsub!(/PRISON_ID/, prisoner[:prison_id])
            end

            if url =~ /DATETIMEENCODED/
              url.gsub!(/DATETIMEENCODED/, URI.encode((Time.now - 60).strftime("%Y-%m-%e %H:%M:%S.%L")))
            end

            if url =~ /DATETIMEISO/
              url.gsub!(/DATETIMEISO/, (Time.now - 60).utc.iso8601)
            end

            method = endpoint[:method]

            case method
              when :get
                result = ApiRequest.get(url: url,
                                        verify: self.verify_ssl,
                                        headers: { Authorization: GenAuth.run })
              when :post
                result = ApiRequest.post(url: url,
                                        body: endpoint[:body],
                                        verify: self.verify_ssl,
                                        headers: { Authorization: GenAuth.run })
            end

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
