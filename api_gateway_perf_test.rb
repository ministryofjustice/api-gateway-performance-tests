require 'benchmark'
require 'optparse'
require 'byebug'


require_relative './gen_auth'
require_relative './command_line_parser'
require_relative './request_group'
require_relative './responses_printer'

BASE_URL              = ENV['NOMIS_API_BASE_URL'] || 'https://gateway.t3.nomis-api.hmpps.dsd.io/nomisapi'
ENDPOINT_404          = "#{BASE_URL}/foobar".freeze


require_relative './t3/prisoners'
require_relative './batches'

threads = []
responses = []

OPTS = CommandLineParser.parse_opts

chosen_batches = OPTS[:batches] || ['default']
batches_to_run = chosen_batches.map { |b| BATCHES[b.to_sym] }.flatten.compact
# allow default batch to take some measures from the cmd line param
default_batch_opts = {
  number_of_users: OPTS[:concurrent_users],
  endpoints: [ {endpoint: ENDPOINT_404, method: :get} ],
  interval_between_requests: OPTS[:interval_between_requests].to_i,
  interval_between_users: OPTS[:rampup_per_user].to_i,
  number_of_requests: OPTS[:number_of_requests] || 1
}

total_requests = 0

# start of main loop
batches_to_run.each do |batch_config|
  # create a thread for each batch
  this_batch = default_batch_opts.merge(batch_config)
  batch = RequestGroup.new(this_batch)

  threads << Thread.new do
    puts "starting batch #{batch.label}"
    # each batch creates one thread per user
    batch.run(threads, responses)
  end
  total_requests = total_requests + (batch.number_of_users * batch.number_of_requests)
end

threads.each(&:join)

puts "calculating ..."
all_responses = responses.flatten

puts "\n\n"
puts '-----------------------'
ResponsesPrinter.print_statistics(all_responses)
puts "\n"
ResponsesPrinter.print_status_code_counts(all_responses, total_requests)
ResponsesPrinter.print_missing_responses(all_responses, total_requests)
puts "\n"
