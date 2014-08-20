require_relative 'qidian_month.rb'

mapper = QidianMonthMapper.new
mapper.max_per_month = 50

puts mapper.browser

mapper.map_range(Date.new(2014, 8), Date.new(2014, 9))

File.open("qidian.month.txt", "w") do |file|
  mapper.books.each do |book|
    file.puts "#{book[:month]} $$ #{book[:rank]} $$ #{book[:category]} $$ #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ #{book[:update_time]} $$ #{book[:url]}"
  end
end

mapper.gen_lvs

File.open("qidian.month.all.txt", "w") do |file|
  mapper.books.each do |book|
    file.puts "#{book[:month].strftime "%Y%m"} $$ #{book[:rank]} $$ #{book[:category]} $$ #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ #{book[:update_time]} $$ #{book[:lv]} $$ #{book[:url]}"
  end
end

mapper.browser.close
