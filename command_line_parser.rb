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
      o.on('-h') do
        puts o
        exit 0
      end
      o.parse!
    end
    opts
  end
end