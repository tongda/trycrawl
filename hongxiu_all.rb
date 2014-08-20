require_relative 'hongxiu_mapper'

class HongxiuAllMapper < HongxiuMapper
  def map_all
    url = "http://top.hongxiu.com/rqwb.html"
    map_page url

    (2..8).each do |i|
      url = "http://top.hongxiu.com/rqwb#{i}.html"
      map_page url
    end
  end

  def detail_for(book, times = 0)
    begin
      @browser.goto book[:auth_url]

      puts book[:auth_url]

      book[:detail] = {
        publish: @browser.div(:id => "htmlpageleft").spans(:class => 'blue big bold')[0].text,
        write: @browser.div(:id => "htmlpageleft").spans(:class => 'blue big bold')[1].text,
      }
    rescue Exception => e
      puts e.message
      puts "retrying"
      reset
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
