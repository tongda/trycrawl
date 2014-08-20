require_relative 'hongxiu_month.rb'
require 'date'

mapper = HongxiuMonthMapper.new
file_name = "hongxiu.month.#{DateTime.now.strftime('%s')}.txt"

mapper.page_handler = Proc.new do |books|
  books.each do |book|
    mapper.detail_for book
    File.open(file_name, 'a') do |file|
      if book[:detail]
        file.puts "#{book[:rank]} $$ \
        #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ \
        #{book[:update_time]} $$ #{book[:url]} $$ \
        #{book[:detail][:words]} $$ #{book[:detail][:reads]} $$ #{book[:detail][:favourites]}"
      else
        file.puts "#{book[:rank]} $$ \
        #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ \
        #{book[:update_time]} $$ #{book[:url]} $$"
      end
    end
  end
end

mapper.map_range(Date.new(2014, 1), Date.new(2014, 3))

mapper.browser.close
