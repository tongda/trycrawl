#encoding=UTF-8

require 'watir-webdriver'

class BaseMapper
  attr_accessor :browser

  def initialize
    @browser = Watir::Browser.new :phantomjs
  end
end
