require_relative 'xiaoxiang_mapper'
require 'date'

mapper = XiaoxiangMapper.new

filename = "xiaoxiang.all.#{DateTime.now.strftime('%s')}.txt"
filename_detail = "xiaoxiang.detail.all.#{DateTime.now.strftime('%s')}.txt"

mapper.map_all do |books|
  File.open(filename, 'w') do |file|
    books.each do |book|
      file.puts "#{book[:month]} $$ #{book[:rank]} $$ #{book[:name]} $$ #{book[:url]} $$ #{book[:hits]}"
    end
  end

  File.open(filename_detail, 'w') do |file|
    books.each do |book|
      mapper.detail_for book do |b|
        file.puts "#{book[:month]} $$ #{book[:rank]} $$ #{book[:name]} $$ #{book[:url]} $$ #{book[:hits]} $$ \
        #{book[:read]} $$ #{book[:favourite]} $$ #{book[:words]} $$ #{book[:level]} $$ #{book[:book_count]}"
      end
    end
  end
end

mapper.browser.close
