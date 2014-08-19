#encoding=UTF-8

require 'watir-webdriver'
require 'date'

class QidianMapper

  attr_accessor :browser

  attr_reader :books

  attr_writer :max_per_month

  def initialize
    @browser = Watir::Browser.new :phantomjs
    @books = []
    @max_per_month = 2000
  end

  def map_row(row)
    book = {
      :rank => row.tds[0].text,
      :category => row.tds[1].a.text,
      :name => row.tds[2].a.text,
      :month_votes => row.tds[3].text,
      :author => row.tds[4].a.text,
      :update_time => row.tds[5].text,
      :url => row.tds[2].a.href
    }
  end

  def map_page(url)
    mapped_books = []

    begin
      @browser.goto url
      @browser.table(:id => "textlist").trs[1..-1].each do |row|
        mapped_books.push map_row(row)
        # puts map_row(row)
      end
      puts "get #{mapped_books.size} items"
    rescue Exception => e
      puts e.message
      puts "retrying"
      mapped_books = map_page(url)
    end

    mapped_books
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
      break if books_in_page.size < 50 || books_in_month.size >= @max_per_month
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

mapper = QidianMapper.new
mapper.max_per_month = 100

puts mapper.browser

mapper.map_range(Date.new(2014, 8), Date.new(2014, 9))

File.open("qidian.txt", "w") do |file|
  mapper.books.each do |book|
    file.puts "#{book[:month]} $$ #{book[:rank]} $$ #{book[:category]} $$ #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ #{book[:update_time]} $$ #{book[:url]}"
  end
end

mapper.gen_lvs

File.open("qidian.all.txt", "w") do |file|
  mapper.books.each do |book|
    file.puts "#{book[:month]} $$ #{book[:rank]} $$ #{book[:category]} $$ #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ #{book[:update_time]} $$ #{book[:lv]} $$ #{book[:url]}"
  end
end

mapper.browser.close
