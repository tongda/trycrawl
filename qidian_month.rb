#encoding=UTF-8

require_relative 'qidian_mapper'
require 'date'

class QidianMonthMapper < QidianMapper

  # attr_accessor :browser

  attr_reader :books

  attr_writer :max_per_month

  def initialize
    super
    @books = []
    @max_per_month = 2000
  end

  def map_month(url_base)
    index = 1
    books_in_month = []
    loop do
      url = "#{url_base}&PageIndex=#{index}"

      books_in_page = map_page url
      books_in_month += books_in_page

      puts "page #{index} finished"

      index += 1
      break if books_in_page.size == 0 || books_in_month.size >= @max_per_month
    end
    books_in_month
  end

  def map_range(from, to)
    while from < to do
      url_base = "http://top.qidian.com/Book/TopDetail.aspx?TopType=3&Month=#{from.strftime "%Y%m"}"
      books = map_month url_base
      books.each do |book|
        book[:month] = from
      end
      @books += books

      puts "month #{from} has finished, #{books.size} found"

      from = from.next_month
    end
  end

  def lv_for(book)
    begin
      @browser.goto book[:url]
      book[:lv] = @browser.div(:class => "title").img.title
    rescue Exception => e
      puts e.message
      puts "retrying"
      lv_for book
    end
  end

  def gen_lvs
    @books.each do |book|
      lv_for book
    end
  end
end

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
