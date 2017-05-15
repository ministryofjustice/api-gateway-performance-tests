
class ResponsesPrinter

  def self.print_heading
    puts 'total_time, code, appserver_time, db_time'
  end

  def self.print(response, prefix = nil)
    puts [prefix,
          response[:total_time].to_s,
          response[:code].to_s,
          response[:appserver_time].to_s,
          response[:db_time].to_s].compact.join(', ')
  end

  def self.print_statistics(all_responses=[])
    sums = totals(all_responses)
    averages(sums, all_responses.size).each do |sym, value|
      puts "Average #{sym.to_s.gsub('_', ' ')}: #{value}"
    end

    puts 'Status code counts: '
    puts count_status_codes(all_responses).join("\n- ")
    puts "(total #{all_responses.count})"
  end

  def self.totals(all_responses)
    totals = {}
    [:total_time, :app_server_time, :db_time].each do |sym|
      totals[sym] = all_responses.inject(0){ |sum, l| l[sym] ? sum + l[sym] : nil }
    end
    totals
  end

  def self.averages(totals, size)
    averages = {}
    totals.each do |sym, value|
      averages[sym] = (totals[sym] && size) ? totals[sym] / size : nil
    end
    averages
  end

  def self.count_status_codes(all_responses)
    responses_by_code = all_responses.group_by { |r| r[:code] }
    counts = {}
    responses_by_code.each do |code, responses|
      counts[code] = { count: responses.count,
                       pct: responses.count * 100.0 / all_responses.size.to_f }
    end
    
    counts.map { |code, count| "#{code}: #{count[:count]} (#{sprintf('%.1f', count[:pct])}%)" }
  end
end