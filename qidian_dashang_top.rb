require 'watir-webdriver'
require 'date'

filename = "qidian.dashang.#{DateTime.now.strftime('%s')}.txt"

def from_line(line)
  parts = line.split ","
  return {
    rank: parts[0].strip,
    name: parts[2].strip,
    url: parts[7].strip,
  }
end

def open_browser(times = 0, &p)
  browser = Watir::Browser.new :phantomjs
  browser.driver.manage.timeouts.implicit_wait = 3
  begin
    p.call browser
  rescue Exception => e
    puts e.message

    if times < 1
      times += 1
      puts "retry for #{times} times"
      open_browser times do
        p.call browser
      end
    else
      puts "give up"
    end
  end
  browser.close
end

def map_page(book)
  open_browser do |br|
    br.goto book[:url]
    br.link(:id => 'hdtabs02').hover
    br.div(:id => 'award').when_present do
      t = br.div(:id => 'award').div(:class => "ballot_data").text
      puts t
      parts = t.split '  '

      book[:ds_time] = DateTime.now
      book[:ds_week] = parts[0]
      book[:ds_day] = parts[1]
    end
  end
  yield book
end

mod = ARGV[0].to_i
rem = ARGV[1].to_i

puts "mod: #{mod} rem: #{rem}"

File.open "qidian_top5000.csv", 'r:utf-8' do |in_file|
  puts "qidian_top5000.csv opened"
  File.open filename, 'w' do |out_file|
    in_file.each_line do |line|
      book = from_line line
      if book[:rank].to_i % mod == rem
        puts "processing line: #{line}"
        map_page book do |b|
          result = "#{b[:rank]},#{b[:name]},#{b[:url]},#{b[:ds_time].to_s},#{b[:ds_week]},#{b[:ds_day]}"
          out_file.puts line
          puts result
        end
      end
    end
  end
end
