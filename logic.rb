require 'readability'
require 'open-uri'

class Logic
  def initialize
     @content = process('http://en.wikipedia.org/wiki/Transhumanism')
  end

  def process(url='http://en.wikipedia.org/wiki/Special:Random')
    resp = open(url)
    url = resp.base_uri.to_s
    source = resp.read
    content = Readability::Document.new(source,  :tags => %w[]).content
    title = Nokogiri::HTML(source).css('h1')[0].text
    {
      'url' => url,
      'length' => content.length,
      'title' => title
    }
  end

  def seek 
    target = nil
    until target and target['length'] < @content['length']
      target = process
    end


    return target
  end

  def generate
    target = seek
    text = ""

    url = target["url"]
    title = target["title"]

    strings = [
      "The Wikipedia page for #{title} is shorter than the article on Transhumanism",
      "\"#{title}\" is shorter than the Wikipedia for Transhumanism ",
      "shorter then Transhumanism: #{title}",
      "The wiki article for #{title} is shorter than that of Transhumanism"
    ]

    until text != "" and text.length <= 120
      text = strings.sample
    end
    return "#{text} #{url}"
  end
end
