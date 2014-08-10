#encoding=UTF-8

require 'watir-webdriver'

#get ranks
apps = []
File::open('ranks.txt', 'r:utf-8') do |file|
  file.each_line do |line|
    puts line
    items = line.split '$$'
    app = {:rank => items[0].strip, :name => items[1].strip, :corp => items[2].strip}
    app[:downloads] = {}
    apps.push app
  end
end

browser = Watir::Browser.new :chrome
browser.goto 'http://as.baidu.com'

# search
apps.each do |app|
  puts "trying to process #{app[:name]}..."

  browser.text_field(:id => 'word').when_present.set app[:name]
  browser.button(:id => 'rd-search_submit').click

  if browser.ul(:class => 'dataList cls').present? then
    app[:downloads][:baidu] = browser.ul(:class => 'dataList cls').li.div(:class => 'right').span(:class => 'date').text
  end
end

puts apps

# temp put 360 here
browser.goto 'http://www.wandoujia.com/apps'

apps.each do |app|
  browser.text_field(:id => 'j-search-input').when_present.set app[:name]
  browser.button(:value => '搜索').click

  if browser.span(:class => 'install-count').present? then
    app[:downloads][:wandoujia] = browser.span(:class => 'install-count').text
  end
end

browser.close

File.open('stats.txt', 'w') do |file|
  apps.each do |app|
    file.puts "#{app[:rank]}$$#{app[:name]}$$#{app[:corp]}$$#{app[:downloads][:baidu]}$$#{app[:downloads][:wandoujia]}"
  end
end
