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

  def detail_for(book)
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
      detail_for book
    end
  end

  def gen_details
    @books.each do |book|
      detail_for book
    end
  end
end

mapper = QidianAllMapper.new
mapper.top = 100

puts mapper.browser

mapper.map_all

File.open("qidian.all.txt", "w") do |file|
  mapper.books.each do |book|
    file.puts "#{book[:rank]} $$ #{book[:category]} $$ #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ #{book[:update_time]} $$ #{book[:url]}"
  end
end

mapper.gen_details

File.open("qidian.all.all.txt", "w") do |file|
  mapper.books.each do |book|
    file.puts "#{book[:rank]} $$ #{book[:category]} $$ \
    #{book[:name]} $$ #{book[:month_votes]} $$ #{book[:author]} $$ \
    #{book[:update_time]} $$ #{book[:lv]} $$ #{book[:url]} $$ \
    #{book[:detail][:quality]} $$ #{book[:detail][:total_hit]} $$ #{book[:detail][:month_hit]} $$ \
    #{book[:detail][:week_hit]} $$ #{book[:detail][:total_recommand]} $$ #{book[:detail][:month_recommand]} $$ \
    #{book[:detail][:week_recommand]} $$ #{book[:detail][:word_completed]}"
  end
end

mapper.browser.close
