require_relative 'hongxiu_mapper'
require 'date'

class HongxiuMonthMapper < HongxiuMapper
  def map_range(from, to)
    puts from
    puts to
    while from < to do
      url = "http://top.hongxiu.com/his#{from.strftime '%Y%m'}.html"

      books = map_page url
      books.each do |book|
        book[:month] = from
      end

      puts "month #{from} has finished, #{books.size} found"
      from = from.next_month
    end
  end

  def detail_for(book, times = 0)
    begin
      @browser.goto book[:url]

      puts book[:url]

      book[:detail] = {
        words: @browser.span(:id => 'ajZiShu').text,
        reads: @browser.span(:id => 'ajYueDu').text,
        favourites: @browser.span(:id => 'ajShouCang').text,
      }
    rescue Exception => e
      puts e.message
      puts "retrying"
      if times < 5
        detail_for book, times + 1
      else
        File.open("hongxiu.given_up.txt", "a") do |file|
          file.puts "#{book[:name]} $$ #{book[:url]}"
        end
        puts "#{book[:url]} has been tried 5 times, give up."
      end
    end
  end
end
