require "csv"
require 'ferrum'

class KuronekoyamatoScraper
  YAMATO_URL = "https://toi.kuronekoyamato.co.jp/cgi-bin/tneko"
  DEFAULT_IMAGE_PATH = "result.png"
  DEFAULT_OUTPUT_CSV_PATH = "result.csv"
  MAX_INVOICE_NUMBER = 10

  attr_reader :invoice_numbers, :image_path, :output_csv_path

  def initialize(invoice_numbers, image_path: nil, output_csv_path: nil)
    if invoice_numbers.count > MAX_INVOICE_NUMBER
      raise ArgumentError,
        "invoice_numbers must be less than #{MAX_INVOICE_NUMBER} or less. Got: #{invoice_numbers}"
    end

    @invoice_numbers = invoice_numbers
    @image_path = image_path || DEFAULT_IMAGE_PATH
    @output_csv_path = output_csv_path || DEFAULT_OUTPUT_CSV_PATH
  end

  def scrape!
    move_to_top
    input
    submit!
    validate!
    output_to_csv!
    screenshot!
    quit
  end

  private
  def browser
    @browser ||= Ferrum::Browser.new(js_errors: true)
  end

  def move_to_top
    browser.go_to(YAMATO_URL)
  end

  def input
    invoice_numbers.each.with_index(1) do |data, i|
      input = browser.at_xpath("//input[@name='number%02d']" % i)
      input.focus.type(data)
    end
  end

  def submit!
    browser.at_xpath("//div[@class='tracking-box-submit pc-only']/button").click
  end
  
  def validate!
    # TODO
  end

  def output_to_csv!
    # TODO
  end

  def screenshot!
    browser.screenshot(path: image_path, full: true)
  end
  
  def quit
    browser.quit
  end
end

class CsvParser
  attr_reader :filepath

  class << self
    def parse(filepath)
      new(filepath).parse
    end
  end

  def initialize(filepath)
    @filepath = filepath
  end

  def parse
    [].tap do |res|
      CSV.foreach(filepath) do |row|
        res << row.first
      end
    end
  end
end


def main
  invoice_numbers = CsvParser.parse("test_data.csv")
  scraper = KuronekoyamatoScraper.new(invoice_numbers)
  scraper.scrape!
end

main if __FILE__ == $0
