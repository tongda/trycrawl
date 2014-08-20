require_relative 'xiaoshuo_mapper'

class XiaoshuoMonthMapper < XiaoshuoMapper
  attr_writer :max_per_month
  attr_accessor :month_from

  def initialize
    super
    @max_per_month = 300
  end

  def map_month(url_base)
    index = 1
    books_in_month = []
    loop do
      url = "#{url_base}#{index}.html"

      books_in_page = map_page url do |book|
        book[:month] = @month_from
      end

      books_in_month += books_in_page

      puts "page #{index} finished"

      index += 1
      break if books_in_page.size == 0 || books_in_month.size >= @max_per_month
    end
    books_in_month
  end

  def map_range(from, to)
    puts from
    @month_from = from
    puts to
    while @month_from < to do
      url_base = "http://a.readnovel.com/topall/goldmedal/#{from.strftime '%Y%m'}/"

      books = map_month url_base

      puts "month #{from} has finished, #{books.size} found"
      @month_from = @month_from.next_month
    end
  end

  def detail_for(book, times = 0)
    begin
      @browser.goto book[:url]

      puts book[:url]

      book[:detail] = {
        hit: @browser.em(:id => 'vc').text,
        recommand: @browser.em(:id => 'cc').text,
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
