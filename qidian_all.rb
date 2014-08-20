#encoding=UTF-8

require_relative 'qidian_mapper'

class QidianAllMapper < QidianMapper
  attr_accessor :top

  attr_reader :books

  def initialize
    super
    @top = 5000
    @books = []
  end

  def map_all
    index = 1
    loop do
      url = "http://top.qidian.com/Book/TopDetail.aspx?TopType=1&PageIndex=#{index}"

      @books += map_page url
      puts "page #{index} finished, #{@books.size} mapped"

      index += 1

      break if @books.size >= @top
    end
  end

  def detail_for(book, times = 0)
    begin
      @browser.goto book[:url]
      book[:lv] = @browser.div(:class => "title").img.title

      @browser.link(:id => "booktitle").click

      info_table = browser.div(:class => "info_box").table
      book[:detail] = {
        quality: info_table.trs[0].tds[0].span.text,
        total_hit: info_table.trs[0].tds[1].span.text,
        month_hit: info_table.trs[0].tds[2].span.text,
        week_hit: info_table.trs[0].tds[3].span.text,
        total_recommand: info_table.trs[1].tds[1].span.text,
        month_recommand: info_table.trs[1].tds[1].span.text,
        week_recommand: info_table.trs[1].tds[1].span.text,
        word_completed: info_table.trs[2].tds[1].span.text
      }
    rescue Exception => e
      puts e.message
      puts "retrying"
      if times < 5
        detail_for book, times + 1
      else
        File.open("given_up.txt", "a") do |file|
          file.puts "#{book[:name]} $$ #{book[:url]}"
        end
        puts "#{book[:url]} has been tried 5 times, give up."
      end
    end
  end

  def gen_details(&block)
    @books.each do |book|
      detail_for book

      if block
        block.call book
      end
    end
  end

  def parse_book(line)
    phrases = line.split "$$"
    if phrases.size > 0
      return {
        rank: phrases[0].strip,
        category: phrases[1].strip,
        name: phrases[2].strip,
        month_votes: phrases[3].strip,
        author: phrases[4].strip,
        update_time: phrases[5].strip,
        url: phrases[6].strip
      }
    end
  end

  def parse_books
    File.open("qidian.all.txt", "r:utf-8") do |file|
      file.each_line do |line|
        book = parse_book line

        if book[:rank] % 100 == 0
          puts "#{book[:rank]} completed"
        end

        @books.push book if book
      end
    end
  end
end
