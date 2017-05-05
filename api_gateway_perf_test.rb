require 'benchmark'
require 'optparse'
require 'byebug'

require_relative './gen_auth'
require_relative './command_line_parser'
require_relative './httparty_adapter'

BASE_URL              = ENV['NOMIS_API_BASE_URL'] || 'https://noms-api-preprod.dsd.io/nomisapi'
ENDPOINT_1            = "#{BASE_URL}/health"
ENDPOINT_2            = "#{BASE_URL}/foobar"

adapter = HTTPartyAdapter
puts opts = CommandLineParser.parse_opts

threads = []
logs = []
responses = []

puts "total_time, code, appserver_time, db_time"
opts[:concurrent_users].times.each do |i|
  threads << Thread.new do
    responses[i] = []
    start = Time.now

    auth = GenAuth.run
    response = HTTPartyAdapter.get(url: ENDPOINT_1,
                                   headers: { Authorization: auth })
    response_time = Time.now - start
    result = HTTPartyAdapter.parse_response(response)
    result[:total_time] = (response_time * 1000).to_i
    responses[i] << result
    puts [result[:total_time], result[:code], result[:appserver_time], result[:db_time]].join(', ')
  end
  sleep(opts[:rampup_per_user])
end

threads.each(&:join)

all_responses = responses.flatten

average_total_time = all_responses.inject(0){ |sum, l| sum + l[:total_time] }.to_f / all_responses.size
average_appserver_time = all_responses.inject(0){ |sum, l| sum + l[:appserver_time] }.to_f / all_responses.size rescue ''
average_db_time = all_responses.inject(0){ |sum, l| sum + l[:db_time] }.to_f / all_responses.size rescue ''
status_codes = all_responses.map { |l| l[:code] }.flatten.sort.inject(Hash.new(0)) {|h, v| h[v] += 1; h}

puts
puts "Average total time: #{average_total_time}"
puts "Average appserver time: #{average_appserver_time}"
puts "Average db time: #{average_db_time}"
puts "Status code counts: #{status_codes}"
