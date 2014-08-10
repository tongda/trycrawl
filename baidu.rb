#encoding=UTF-8

require 'watir-webdriver'

#get ranks
apps = []
File::open('ranks.txt', 'r:utf-8') do |file|
  file.each_line do |line|
    puts line
    items = line.split '$$'
    app = {:rank => items[0].strip, :name => items[1].strip, :corp => items[2].strip}
    apps.push app
  end
end

browser = Watir::Browser.new :chrome
browser.goto 'http://as.baidu.com'

# search
apps.map! do |app|
  puts "trying to process #{app[:name]}..."

  browser.text_field(:id => 'word').when_present.set app[:name]
  browser.button(:id => 'rd-search_submit').click

  if browser.ul(:class => 'dataList cls').present? then
    app[:downloads] = browser.ul(:class => 'dataList cls').li.div(:class => 'right').span(:class => 'date').text
    puts "#{app[:name]} #{app[:downloads]}"
  end
end
