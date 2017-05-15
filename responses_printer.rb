require 'descriptive_statistics/safe'

# encapsulates the faff of printing out statistics
module ResponsesPrinter
  module_function

  def print_heading
    puts 'total_time, code, appserver_time, db_time'
  end

  def print(response, prefix = nil)
    puts [prefix,
          response[:total_time].to_s,
          response[:code].to_s,
          response[:appserver_time].to_s,
          response[:db_time].to_s].compact.join(', ')
  end

  def print_statistics(all_responses = [])
    figures = [:total_time, :app_server_time, :db_time]
    max_len = figures.map(&:to_s).sort_by(&:length).last.length

    figures.each do |figure|
      line = ["mean: #{format('%.1f', mean(all_responses, figure))}ms",
              "95th percentile: #{format('%.1f', percentile(all_responses, figure, 95))}ms",
              "std deviation: #{format('%.1f', std_dev(all_responses, figure))}ms"]
      puts format("%-#{max_len}s", figure.to_s.tr('_', ' ')) + "\t" + line.join(', ')
    end
  end

  def print_status_code_counts(all_responses = [])
    puts 'Status codes: '
    puts count_status_codes(all_responses).join("\n")
    puts "(total #{all_responses.count})"
  end

  def mean(all_responses, sym)
    DescriptiveStatistics.mean(all_responses) { |r| r[sym] }
  end

  def percentile(all_responses, sym, pct)
    DescriptiveStatistics.percentile(pct, all_responses) { |r| r[sym] }
  end

  def std_dev(all_responses, sym)
    DescriptiveStatistics.standard_deviation(all_responses) { |r| r[sym] }
  end

  def count_status_codes(all_responses)
    responses_by_code = all_responses.group_by { |r| r[:code] }
    counts = {}
    responses_by_code.each do |code, responses|
      counts[code] = { count: responses.count,
                       pct: responses.count * 100.0 / all_responses.size.to_f }
    end
    
    counts.map do |code, count|
      "#{code}: #{count[:count]} (#{format('%.1f', count[:pct])}%)"
    end
  end
end