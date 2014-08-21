require_relative 'base_mapper'

class XiaoxiangMapper < BaseMapper
  def map_row(rank, row)
    book = {
      rank: rank + 1,
      name: row.link.text.split('：')[0],
      hits: row.link.text.split('：')[1],
      url: row.link.href,
    }
    yield book
  end

  def map_list(list)
    month = list.div(:class => "title").text
    books = []
    list.ul.when_present.lis.each.with_index do |row, i|
      map_row i, row do |book|
        book[:month] = month
        books << book
      end
    end

    yield books
  end

  def map_tab
    tab_books = []

    Watir::Wait.until { browser.div(:id => 'main_list').divs(:class => 'orderlist').size > 0}
    browser.div(:id => 'main_list').divs(:class => 'orderlist').each do |list|
      map_list list do |books|
        tab_books += books
        puts "#{list.div(:class => "title").text} finished"
      end
    end

    yield tab_books
  end

  def goto_month_pk
    browser.goto "http://www.xxsy.net/phb.html"
    browser.div(:id => 'd_c_4').hover
    browser.link(:id => 'a_c_42').when_present.click
  end

  def map_all
    goto_month_pk

    all_books = []

    browser.div(:id => 'labbox').when_present.lis.each do |tab|
      tab.link.click
      map_tab do |books|
        all_books += books

        puts "#{tab.text} finished"
      end
    end

    yield all_books
  end

  def detail_for(book, times = 0, &p)
    reset

    begin
      browser.goto book[:url]

      book[:read] = browser.div(:id => 'detail_title').span(:id => 'b-info-click-1').text
      book[:favourite] = browser.div(:id => 'detail_title').span(:id => 'b-info-shoucang-1').text
      book[:words] = browser.div(:id => 'detail_title').span(:id => 'b-info-words-1').text

      browser.li(:id => 'i_l_t2').hover
      if browser.ul(:class => 'authorinfolist').when_present.lis.size > 2
        book[:level] = browser.ul(:class => 'authorinfolist').lis[2].text
        book[:book_count] = browser.span(:id => 'bookcount').text
      end
    rescue Exception => e
      puts e.message
      if times < 2
        puts "retrying"
        detail_for book, times + 1
      else
        puts "#{book[:url]} fails more than 2 times, give up."
      end
    end

    puts "#{book[:name]} #{book[:url]} finished"
    if p
      p.call book
    end
  end
end
