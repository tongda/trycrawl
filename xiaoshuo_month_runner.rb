require_relative 'xiaoshuo_month.rb'
require 'date'

mapper = XiaoshuoMonthMapper.new
file_name = "xiaoshuo.month.#{DateTime.now.strftime('%s')}.txt"

mapper.page_handler = Proc.new do |books|
  books.each do |book|
    mapper.detail_for book
    File.open(file_name, 'a') do |file|
      if book[:detail]
        file.puts "#{book[:month].strftime '%Y%m'} $$ #{book[:rank]} $$ \
        #{book[:name]} $$ #{book[:author]} $$ #{book[:type]} $$ #{book[:state]} $$ \
        #{book[:month_votes]} $$ #{book[:url]} $$ #{book[:words]} $$ \
        #{book[:detail][:hit]} $$ #{book[:detail][:recommand]}"
      else
        file.puts "#{book[:month].strftime '%Y%m'} $$ #{book[:rank]} $$ \
        #{book[:name]} $$ #{book[:author]} $$ #{book[:type]} $$ #{book[:state]} $$ \
        #{book[:month_votes]} $$ #{book[:url]} $$ #{book[:words]}"
      end
    end
  end
end

mapper.map_range(Date.new(2010, 3), Date.new(2014, 9))

mapper.browser.close
