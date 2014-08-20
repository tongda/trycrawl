require_relative 'base_mapper'

class HongxiuMapper < BaseMapper
  attr_accessor :page_handler

  def map_row(row)
    {
      rank: row.lis[0].text,
      name: row.lis[1].text,
      author: row.lis[2].text,
      month_votes: row.lis[4].text,
      update_time: row.lis[5].text,
      url: row.lis[1].link.href,
      # auth_url: row.lis[2].link.href
    }
  end

  def map_page(url)
    mapped_books = []
    begin
      @browser.goto url
      if @browser.div(:id => 'lbox').present?
        @browser.div(:id => 'lbox').uls.each do |row|
          mapped_books.push map_row(row)
        end
      end
      puts "get #{mapped_books.size} items"
    rescue Exception => e
      puts e.message
      puts "retrying"
      mapped_books = map_page(url)
    end

    mapped_books.each do |book|
      yield book
    end

    if @page_handler
      puts "going to process page"
      @page_handler.call mapped_books
      puts "page processed"
    end

    mapped_books
  end
end
