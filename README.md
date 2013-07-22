# Dumpmon-mon Bot

A ruby bot to monitor [DumpMon](https://twitter.com/dumpmon) (or anyone elses) posts on Twitter, and analyse the urls for interesting keywords.

### Install

1. Clone the repo `git clone https://github.com/alias1/dumpmonmon.git`
2. Run bundle `bundle`
3. ???
4. Profit!

### Config

Take a look in `dumpmonmon.yml`, should be pretty straight forward.

**tl;dr**
* Configure your twitter API details
* Add some users to monitor (Default: [@dumpmon](https://twitter.com/dumpmon))
* Add some strings to monitor

### Run

```
ruby dumpmonmon.rb
```

## License

* The MIT License (MIT)
  * See LICENSE file for details
  * http://choosealicense.com/licenses/mit/

### TODO

* [ ] Save last read id so we can use since_id
  * When we do this, make sure to set count to 200 (which is maximum)
    * Make this a config option
* [x] Implement functionality to do check the found urls for keywords
  * [ ] Use regex?
  * [x] Set these in the config file
  * Options
    * ~~[Net::HTTP](http://ruby-doc.org/stdlib-2.0/libdoc/net/http/rdoc/Net/HTTP.html)~~
    * ~~open-uri (probably use Net::HTTP instead)~~
    * [x] [Mechanize](http://mechanize.rubyforge.org/) (uses Nokogiri)
      * [Tutorial](http://ruby.bastardsbook.com/chapters/mechanize/)
      * [Using a proxy](http://mechanize.rubyforge.org/EXAMPLES_rdoc.html#label-Using+a+proxy)
    * [x] [Nokogiri](http://nokogiri.org/)
      * [Tutorial](http://hunterpowers.com/data-scraping-and-more-with-ruby-nokogiri-sinatra-and-heroku/)
    * ~~[Selenium(?)](http://docs.seleniumhq.org/)~~
* [ ] Cleanup the code, put into proper functions/etc
  * [ ] Better way to pass our yaml config vars into the Twitter configure?

### Future Enhancements?

* Send email with results
  * Only if we get a hit?
* Update so that we can monitor #hashtags as well as users

### Uses

* http://sferik.github.io/twitter/
* ~~http://muffinlabs.com/chatterbot.html~~
