require 'cora'
require 'siri_objects'
require 'open-uri'
require 'nokogiri'

#############
# This is a plugin for SiriProxy that will allow you to check tonight's NFL scores
# Example usage: "What's the score of the Bears game?"
#############

class SiriProxy::Plugin::TMZ < SiriProxy::Plugin

	def initialize(config)
    #if you have custom configuration options, process them here!
    end
  
  listen_for /TMZ/i do |phrase|
	  tmzNews = "today"
	  tmz(tmzNews) #in the function, request_completed will be called when the thread is finished
	end
	
	def tmz(news)
	  Thread.new {
	    doc = Nokogiri::XML(open("http://www.tmz.com/rss.xml"))
      	entry = doc.css("div.entry")
      	entry.each {
      		|article|
      		title = article.css("h3 a").first.content.strip
      		say title
      		response = ask "Would you like to hear more stories?" #ask the user for something
    
    		if(response =~ /yes/i) #process their response
      			say "OK"
    		else
      			say "OK, I'll stop with all the juicy TMZ gossip."
      			break
      			request_completed
    		end
      		
      	} 
			say "I'm sorry, I didn't see any juicy TMZ gossip. I failed you."
			request_completed
	  }
		
	  say "Checking to see if there is any gossip today..."
	  
	end
	
end
