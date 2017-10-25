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

PRISONERS = [
  { prisoner_id: "G4027GP", prison_id: "FNI" },
  { prisoner_id: "G4805UP", prison_id: "CFI" },
  { prisoner_id: "G0351UK", prison_id: "LLI" },
  { prisoner_id: "G4591GU", prison_id: "WLI" },
  { prisoner_id: "G5507UO", prison_id: "WYI" },
  { prisoner_id: "G0682VU", prison_id: "LEI" }
]

ENDPOINTS = [
  { endpoint: "#{BASE_URL}/prison/PRISON_ID/offenders/NOMS_ID/accounts/", method: :get },
  # DATETIME FORMAT: 2017-09-24
  { endpoint: "#{BASE_URL}/prison/PRISON_ID/offenders/NOMS_ID/accounts/spends/transactions?from_date=DATETIME", method: :get },
  # DATETIME FORMAT: 2017-10-24%2015:36:24.380
  { endpoint: "#{BASE_URL}/offenders/events?prison_id=PRISON_ID", method: :get },
  { endpoint: "#{BASE_URL}/lookup/active_offender?date_of_birth=DATETIME&noms_id=NOMS_ID", method: :get },
  { endpoint: "#{BASE_URL}/prison/PRISON_ID/slots?start_date=DATETIME&end_date=DATETIME", method: :get },
  { endpoint: "#{BASE_URL}/offenders/NOMS_ID/visits/available_dates", method: :get },
  { endpoint: "#{BASE_URL}/offenders/NOMS_ID/visits/restrictions", method: :get },
  { endpoint: "#{BASE_URL}/offenders/NOMS_ID/visits/contact_list", method: :get },
  { endpoint: "#{BASE_URL}/offenders/events/case_notes?from_datetime=DATETIME", method: :get },
  { endpoint: "#{BASE_URL}/offenders/events/case_notes_for_delius?from_datetime=DATETIME", method: :get },
  { endpoint: "#{BASE_URL}/prison/PRISON_ID/offenders/NOMS_ID/transactions/", method: :post },
]

threads = []
responses = []

OPTS = CommandLineParser.parse_opts

ResponsesPrinter.print_heading

chosen_batches = OPTS[:batches] || ['default']
batches_to_run = chosen_batches.map { |b| BATCHES[b.to_sym] }.flatten.compact
# allow default batch to take some measures from the cmd line param
default_batch_opts = {
  number_of_users: OPTS[:concurrent_users],
  endpoints: ENDPOINTS,
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
