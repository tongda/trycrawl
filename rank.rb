#encoding=UTF-8

require 'watir-webdriver'

browser = Watir::Browser.new :chrome
browser.goto "http://www.appannie.com/apps/ios/top/china/games/?device=iphone"

# show all
browser.link(:class => "load-all").when_present.click
Watir::Wait.until { browser.tbody(:id => "storestats-top-table").trs.size > 200 }

apps = browser.tbody(:id => "storestats-top-table").trs[0..199].map.with_index do |tr, i|
  if i < 200 then
    app = tr.td(:class => "app paid").div(:class => "main-info")
    {
      :rank => i + 1,
      :name => app.span(:class => "title-info").text,
      :corp => app.span(:class => "add-info").text
    }
  end
end

browser.close

File.open("ranks.txt", "w") do |file|
  apps.each do |app|
    file.puts "#{app[:rank]} $$ #{app[:name]} $$ #{app[:corp]}"

    puts "#{app[:rand]} added to file"
  end
end
