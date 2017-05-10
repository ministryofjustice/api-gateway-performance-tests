require 'benchmark'
require 'optparse'
require 'byebug'

require_relative './gen_auth'
require_relative './command_line_parser'
require_relative './httparty_adapter'
require_relative './api_request'
require_relative './responses_printer'

BASE_URL              = ENV['NOMIS_API_BASE_URL'] || 'https://noms-api-preprod.dsd.io/nomisapi'
ENDPOINT_1            = "#{BASE_URL}/health".freeze
ENDPOINT_2            = "#{BASE_URL}/foobar".freeze

puts opts = CommandLineParser.parse_opts

threads = []
responses = []

ResponsesPrinter.print_heading

opts[:concurrent_users].times.each do |_|
  threads << Thread.new do
    result = ApiRequest.get(url: ENDPOINT_1,
                            headers: { Authorization: GenAuth.run })
    responses << result
    ResponsesPrinter.print(result)
  end
  sleep(opts[:rampup_per_user])
end

threads.each(&:join)

all_responses = responses.flatten

ResponsesPrinter.print_statistics(all_responses)
