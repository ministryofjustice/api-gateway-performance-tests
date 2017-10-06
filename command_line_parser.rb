require 'optparse'

# simple abstraction on top of optparse to
# clean up the calling script
class CommandLineParser
  def self.parse_opts
    opts = {}
    OptionParser.new do |o|
      o.on('-c', '--concurrency=', 'max concurrent users') do |c|
        opts[:concurrent_users] = c.to_i
      end
      o.on('-r', '--rampup=',
           'seconds delay between starting each concurrent user') do |r|
        opts[:rampup_per_user] = r.to_i
      end
      o.on('-i', '--interval-between-requests=',
           'seconds delay between each request made by each concurrent user') do |i|
        opts[:interval_between_requests] = i.to_i
      end
      o.on('-n', '--number-of-requests=',
           'number of requests to be made by each concurrent user') do |n|
        opts[:number_of_requests] = n.to_i
      end
      o.on('-b', '--batches=',
           'comma-separated names of pre-configured batch tests to run') do |b|
        opts[:batches] = b.to_s.split(',').compact
      end
      o.on('-u', '--url=', 'URL to hit') do |u|
        opts[:url] = u
      end
      o.on('-h') do
        puts o
        exit 0
      end
      o.parse!
    end
    opts
  end
end
