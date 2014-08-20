#encoding=UTF-8

require_relative 'qidian_all'

mapper = QidianAllMapper.new

mapper.parse_books

File.open("qidian.all.all.txt", "a") do |file|
  mapper.gen_details do |book|
    file.puts "#{book[:rank]} $$ #{book[:category]} $$ \
    #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ \
    #{book[:update_time]} $$ #{book[:lv]} $$ #{book[:url]} $$ \
    #{book[:detail][:quality]} $$ #{book[:detail][:total_hit]} $$ #{book[:detail][:month_hit]} $$ \
    #{book[:detail][:week_hit]} $$ #{book[:detail][:total_recommand]} $$ #{book[:detail][:month_recommand]} $$ \
    #{book[:detail][:week_recommand]} $$ #{book[:detail][:word_completed]}"
  end
end

mapper.browser.close
