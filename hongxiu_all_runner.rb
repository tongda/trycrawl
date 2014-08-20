require_relative 'hongxiu_all'
require 'date'

filename = "hongxiu.all.#{DateTime.now.strftime('%s')}.txt"

mapper = HongxiuAllMapper.new
mapper.page_handler = Proc.new do |books|
  File.open(filename, 'a') do |file|
    books.each do |book|
      mapper.detail_for book

      if book[:detail]
        file.puts "#{book[:month]} $$ #{book[:rank]} $$ \
        #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:property]} $$ #{book[:author]} $$ \
        #{book[:read]} $$ #{book[:update_time]} $$ #{book[:url]} $$ #{book[:auth_url]} $$ \
        #{book[:detail][:publish]} $$ #{book[:detail][:write]}"
      else
        file.puts "#{book[:month]} $$ #{book[:rank]} $$ \
        #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:property]} $$ #{book[:author]} $$ \
        #{book[:read]} $$ #{book[:update_time]} $$ #{book[:url]} $$ #{book[:auth_url]}"
      end
    end
  end
end

mapper.map_all
