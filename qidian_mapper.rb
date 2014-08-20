#encoding=UTF-8

require_relative 'base_mapper'

class QidianMapper < BaseMapper
  attr_accessor :page_handler

  def map_row(row)
    {
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
      if @browser.table(:id => "textlist").trs.size > 1
        @browser.table(:id => "textlist").trs[1..-1].each do |row|
          mapped_books.push map_row(row)
          # puts map_row(row)
        end
      end
      puts "get #{mapped_books.size} items"
    rescue Exception => e
      puts e.message
      puts "retrying"
      mapped_books = map_page(url)
    end

    if @page_handler
      puts "going to process page"
      @page_handler.call mapped_books
      puts "page processed"
    end

    reset
    
    mapped_books
  end
end
