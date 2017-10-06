require 'benchmark'
require 'optparse'
require 'byebug'


require_relative './gen_auth'
require_relative './command_line_parser'
require_relative './request_group'
require_relative './responses_printer'
require_relative './batches'

BASE_URL              = ENV['NOMIS_API_BASE_URL'] || 'https://noms-api-preprod.dsd.io/nomisapi'
ENDPOINT_1            = "#{BASE_URL}/foobar".freeze

threads = []
responses = []

OPTS = CommandLineParser.parse_opts

ResponsesPrinter.print_heading

chosen_batches = OPTS[:batches] || ['default']
batches_to_run = chosen_batches.map { |b| BATCHES[b.to_sym] }.flatten.compact
# allow default batch to take some measures from the cmd line param
default_batch_opts = {
  number_of_users: OPTS[:concurrent_users],
  url: (OPTS[:url] || ENDPOINT_1),
  interval_between_requests: OPTS[:interval_between_requests].to_i,
  interval_between_users: OPTS[:rampup_per_user].to_i,
  number_of_requests: OPTS[:number_of_requests] || 1
}

# start of main loop
batches_to_run.each do |batch_config|
  # create a thread for each batch
  this_batch = batch_config.merge(default_batch_opts)
  batch = RequestGroup.new(this_batch)

  threads << Thread.new do
    puts "starting batch #{batch.label}"
    # each batch creates one thread per user
    batch.run(threads, responses)
  end
end

threads.each(&:join)

puts "calculating ..."
all_responses = responses.flatten

puts "\n\n"
puts '-----------------------'
ResponsesPrinter.print_statistics(all_responses)
puts "\n"
ResponsesPrinter.print_status_code_counts(all_responses)
puts "\n"
