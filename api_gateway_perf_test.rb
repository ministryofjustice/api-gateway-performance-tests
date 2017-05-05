require_relative './gen_auth'
require 'benchmark'
require 'httparty'

BASE_URL              = 'https://noms-api-preprod.dsd.io/nomisapi'
ENDPOINT_1            = "#{BASE_URL}/health"
ENDPOINT_2            = "#{BASE_URL}/foobar"

CONCURRENT_REQUESTS = ARGV[0].to_i || 10

threads = []
logs = []

CONCURRENT_REQUESTS.times.each do |i|
  threads << Thread.new do
    start = Time.now
    logs[i] = [HTTParty.get(ENDPOINT_1, headers: { Authorization: GenAuth.run })]
    response_time = Time.now - start
    logs[i] << (response_time * 1000).to_i
  end
end

threads.each(&:join)

output = logs.inject([]) do |arr, log|
  time = log[1]
  code = log[0].code
  appserver_time = log[0].headers['server-timing'].split(',').first.gsub(/\D/, '').to_i rescue nil
  db_time = log[0].headers['server-timing'].split(',').last.gsub(/\D/, '').to_i rescue nil

  arr << [time, code, appserver_time, db_time]
end

puts (["total_time, code, appserver_time"] + output.map{ |o| o.join(', ') }).join("\n")

average_total_time = output.inject(0){ |sum, l| sum + l[0] }.to_f / output.size
average_appserver_time = output.inject(0){ |sum, l| sum + l[2] }.to_f / output.size rescue ''
average_db_time = output.inject(0){ |sum, l| sum + l[3] }.to_f / output.size rescue ''
status_codes = output.map { |l| l[1] }.flatten.sort.inject(Hash.new(0)) {|h, v| h[v] += 1; h}

puts
puts "Average total time: #{average_total_time}"
puts "Average appserver time: #{average_appserver_time}"
puts "Average db time: #{average_db_time}"
puts "Status code counts: #{status_codes}"
