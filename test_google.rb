require 'watir-webdriver'

browser = Watir::Browser.new :chrome
browser.goto "http://www.appannie.com/apps/ios/top/china/games/?device=iphone"
# browser.tbody(:id => "storestats-top-table").trs.each do |tr|
#   app = tr.td(:class => "app paid").div(:class => "main-info")
#   puts "name: #{app.span(:class => "title-info").text} - corp: #{app.span(:class => "add-info").text}"
# end

apps = browser.tbody(:id => "storestats-top-table").trs.map.with_index do |tr, i|
  app = tr.td(:class => "app paid").div(:class => "main-info")
  {
    :index => i,
    :title => app.span(:class => "title-info").text,
    :corp => app.span(:class => "add-info").text
  }
end

apps.each do |app|
  puts "#{app[:index]} #{app[:title]} #{app[:corp]}"
end
