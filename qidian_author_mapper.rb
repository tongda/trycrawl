require 'watir-webdriver'

authors = {}

def from_line(line)
  phrases = line.split "$$"
  return {
    name: phrases[5].strip,
    url: phrases[7].strip
  }
end

File.open("qidian.month.txt", "r:utf-8") do |file|
  file.each_line do |line|
    author = from_line line
    authors[author[:name]] = author[:url]
  end
end

def lv_for(url, times = 0)
  browser = Watir::Browser.new :phantomjs
  begin
    browser.goto url
    lv = browser.div(:class => "title").img.title

    return lv
  rescue Exception => e
    puts e.message
    puts "retrying"
    if times < 5
      browser.close
      return lv_for(url, times + 1)
    else
      puts "give up"
      File.open("authors.given_up.txt", "a") do |file|
        file.puts url
      end
      return nil
    end
  else
    browser.close
  end
end

lvs = {}
authors.each do |name, url|
    lvs[name] = lv_for url
    puts "#{name} #{lvs[name]}"
end

File.open("qidian.month.txt", "r:utf-8") do |file|
  file.open("qidian.month.all.txt", "w") do |output|
    file.each_line do |line|
      author = from_line line
      output.puts "#{line} $$ #{lvs[author[:name]]}"
    end
  end
end
