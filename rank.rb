#encoding=UTF-8

require 'watir-webdriver'
require 'bunny'

conn = Bunny.new
conn.start

ch = conn.create_channel
x = ch.fanout "trycrawl.apps"

browser = Watir::Browser.new :chrome
browser.goto "http://www.appannie.com/apps/ios/top/china/games/?device=iphone"

# show all
browser.link(:class => "load-all").when_present.click
Watir::Wait.until { browser.tbody(:id => "storestats-top-table").trs.size > 200 }

apps = browser.tbody(:id => "storestats-top-table").trs[0..199].map.with_index do |tr, i|
  if i < 200 then
    app = tr.td(:class => "app paid").div(:class => "main-info")
    a = {
      # :rank => i + 1,
      :name => app.span(:class => "title-info").text,
      :owner => app.span(:class => "add-info").text
    }
    x.publish a.to_json

    puts "#{a.to_json} is sent"
  end
end

browser.close

# apps.each do |app|
#   x.publish app.to_json
# end

conn.close
# File.open("ranks.txt", "w") do |file|
#   apps.each do |app|
#     file.puts "#{app[:rank]} $$ #{app[:name]} $$ #{app[:owner]}"
#
#     puts "#{app[:rand]} added to file"
#   end
# end
