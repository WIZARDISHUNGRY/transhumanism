require 'readability'
require 'open-uri'

class Logic

  def initialize
    @used = []
    load
  end

  def myopen(url)
    open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
  end

  def load
    @content = process('https://en.wikipedia.org/wiki/Transhumanism')
  end

  def process(url='https://en.wikipedia.org/wiki/Special:Random')
    resp = myopen(url)
    url = resp.base_uri.to_s
    source = resp.read
    content = Readability::Document.new(source,
      tags: %w[],
      blacklist: '.references, .reference, .infobox, .mw-editsection, #External_links, #See_also, #Further_reading, #persondata, .mw-headline',
    ).content.strip
    title = Nokogiri::HTML(source).css('h1')[0].text.strip
    length = content.length
    ratio = nil
    if @content
      ratio = length.to_f / @content['length']
    end

    {
      'url' => url,
      'length' => length,
      'title' => title,
      'ratio' => ratio,
      'content' => content,
    }
  end

  def metaseek(url="https://en.wikipedia.org/wiki/Special:RandomInCategory/Main%20topic%20classifications")
    resp = myopen(url)
    url = resp.base_uri.to_s
    slug = url.gsub /.*\//, ''
    return "https://en.wikipedia.org/wiki/Special:RandomInCategory/#{slug}"
  end

  def seek 
    target = nil
    until target and target['length'] < @content['length'] and !target['url'].match /:\/\/.*\/.*:.*/ and !@used.include? target['url']
      if target
        sleep 1
      end
      target = process #removed metaseek here
    end
    return target
  end

  def generate(target=nil)
    if target == nil
      target = seek
    else
      target = process target
    end

    text = ""
    url = target["url"]
    title = target["title"]
    ratio = target["ratio"]

    @used.push url

    strings = [
      "The Wikipedia page for \"#{title}\" is shorter than the article on Transhumanism",
      "\"#{title}\" is shorter than the Wikipedia for Transhumanism ",
      "shorter then transhumanism: #{title}",
      "The wiki for \"#{title}\" is shorter than that of Transhumanism",
      "The wiki for transhumanism is #{(1/ratio).round 2} times longer than that of \"#{title}\"",
    ]
    if ratio >= 0.01
      strings.concat [
        "On Wikipedia, \"#{title}\" is #{(ratio*100).round 2}% the length of \"Transhumanism\"",
        "Wiki for \"#{title}\" is #{ratio.round 2}x the length of \"Transhumanism\"",
      ]
    end

    until text != "" and text.length <= 125
      text = strings.sample
    end
    return "#{text} #{url}"
  end
end
