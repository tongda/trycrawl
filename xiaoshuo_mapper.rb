require_relative 'base_mapper'

class XiaoshuoMapper < BaseMapper
  def map_row(row)
    {
      rank: row.ths[0].text,
      name: row.ths[1].text,
      url: row.ths[1].link.href,
      author: row.tds[0].text,
      type: row.tds[1].text,
      state: row.tds[2].text,
      words: row.tds[3].text,
      month_votes: row.tds[4].text,
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

    if @page_handler
      puts "going to process page"
      @page_handler.call mapped_books
      puts "page processed"
    end

    mapped_books
  end

end
