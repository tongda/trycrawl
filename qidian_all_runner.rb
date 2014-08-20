#encoding=UTF-8

require_relative 'qidian_all.rb'
require 'date'

file_name = "qidian.all.#{DateTime.now.strftime('%s')}.txt"

mapper = QidianAllMapper.new
mapper.top = 100
mapper.page_handler = Proc.new do |books|
  File.open(file_name, "a") do |file|
    books.each do |book|
      mapper.detail_for book
      if book[:detail]
        file.puts "#{book[:rank]} $$ #{book[:category]} $$ \
        #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ \
        #{book[:update_time]} $$ #{book[:lv]} $$ #{book[:url]} $$ \
        #{book[:detail][:quality]} $$ #{book[:detail][:total_hit]} $$ #{book[:detail][:month_hit]} $$ \
        #{book[:detail][:week_hit]} $$ #{book[:detail][:total_recommand]} $$ #{book[:detail][:month_recommand]} $$ \
        #{book[:detail][:week_recommand]} $$ #{book[:detail][:word_completed]}"
      else
        file.puts "#{book[:rank]} $$ #{book[:category]} $$ \
        #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ \
        #{book[:update_time]} $$ #{book[:lv]} $$ #{book[:url]}"
      end
    end
  end
end

mapper.map_all

# File.open("qidian.all.txt", "w") do |file|
#   mapper.books.each do |book|
#     file.puts "#{book[:rank]} $$ #{book[:category]} $$ #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ #{book[:update_time]} $$ #{book[:url]}"
#   end
# end

# mapper.gen_details

# File.open("qidian.all.all.txt", "w") do |file|
#   mapper.books.each do |book|
#     file.puts "#{book[:rank]} $$ #{book[:category]} $$ \
#     #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ \
#     #{book[:update_time]} $$ #{book[:lv]} $$ #{book[:url]} $$ \
#     #{book[:detail][:quality]} $$ #{book[:detail][:total_hit]} $$ #{book[:detail][:month_hit]} $$ \
#     #{book[:detail][:week_hit]} $$ #{book[:detail][:total_recommand]} $$ #{book[:detail][:month_recommand]} $$ \
#     #{book[:detail][:week_recommand]} $$ #{book[:detail][:word_completed]}"
#   end
# end

mapper.browser.close
