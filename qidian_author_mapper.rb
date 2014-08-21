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

    puts "#{author[:name]} - #{author[:url]}"
  end
end

def lv_for(browser, url, times = 0)
  begin
    browser.goto url
    lv = browser.div(:class => "title").img.title

    return lv
  rescue Exception => e
    puts e.message
    puts "#{url} retrying"
    if times < 2
      return lv_for(browser, url, times + 1)
    else
      puts "#{url} give up"
      File.open("authors.given_up.txt", "a") do |file|
        file.puts url
      end
      return nil
    end
  end
end

puts "#{authors.size} authors found"

lvs = {}
current_authors = []
File.open("qidian_top_5000.csv", "r:utf-8") do |file|
  file.each_line do |line|
    phrases = line.split ","
    author = {
      name: phrases[4].strip,
      url: phrases[7].strip,
      lv: phrases[6].strip
    }
    current_authors.push author
    lvs[author[:name]] = author[:lv]
  end
end

puts "#{current_authors.size} authors exists"

File.open("qidian.author.lv.txt", "w") do |file|
  authors.each do |name, url|
    unless lvs.has_key? name
      browser = Watir::Browser.new :phantomjs
      lvs[name] = lv_for browser, url
      browser.close
    end
    puts "#{name} #{lvs[name]}"
    file.puts "#{name} $$ #{lvs[name]}"
  end
end

File.open("qidian.month.txt", "r:utf-8") do |file|
  file.open("qidian.month.all.txt", "w") do |output|
    file.each_line do |line|
      author = from_line line
      output.puts "#{line} $$ #{lvs[author[:name]]}"
    end
  end
end
