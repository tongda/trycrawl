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

  def lv_for(book, times = 0)
    begin
      @browser.goto book[:url]
      book[:lv] = @browser.div(:class => "title").img.title
    rescue Exception => e
      puts e.message
      puts "retrying"
      if times < 5
        lv_for book, times + 1
      else
        File.open("given_up.txt", "a") do |file|
          file.puts "#{book[:name]} $$ #{book[:url]}"
        end
        puts "#{book[:url]} has been tried 5 times, give up."
      end
    end

    reset
  end

  def gen_lvs
    @books.each do |book|
      lv_for book
    end
  end

  def parse_book(line)
    phrases = line.split "$$"
    if phrases.size > 0
      return {
        month: Date.parse(phrases[0]),
        rank: phrases[1].strip,
        category: phrases[2].strip,
        name: phrases[3].strip,
        month_votes: phrases[4].strip,
        author: phrases[5].strip,
        update_time: phrases[6].strip,
        url: phrases[7].strip
      }
    end
  end

  def parse_books
    File.open("qidian.month.txt", "r:utf-8") do |file|
      file.each_line do |line|
        book = parse_book line

        @books.push book if book
      end
    end
  end
end
