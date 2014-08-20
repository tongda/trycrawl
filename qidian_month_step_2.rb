#encoding=UTF-8

require_relative 'qidian_month'

mapper = QidianMonthMapper.new

mapper.parse_books

File.open("qidian.month.all.txt", "a") do |file|
  mapper.books.each do |book|
    mapper.lv_for book
    file.puts "#{book[:rank]} $$ #{book[:category]} $$ \
    #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ \
    #{book[:update_time]} $$ #{book[:lv]} $$ #{book[:url]}"
  end
end

mapper.browser.close
