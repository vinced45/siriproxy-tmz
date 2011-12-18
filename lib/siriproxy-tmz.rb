require 'cora'
require 'siri_objects'
require 'open-uri'
require 'nokogiri'

#############
# This is a plugin for SiriProxy that will allow you to check tonight's NFL scores
# Example usage: "What's the score of the Bears game?"
#############

class SiriProxy::Plugin::TMZ < SiriProxy::Plugin

	#@searched = 0 
	
	def initialize(config)
    #if you have custom configuration options, process them here!
    end
  
  listen_for /TMZ/i do |phrase|
	  tmzNews = "today"
	  tmz(tmzNews) #in the function, request_completed will be called when the thread is finished
	end
	
	def tmz(news)
	  Thread.new {
	  
	    
	    doc = Nokogiri::HTML(open("http://m.tmz.com/home.ftl"))
      	entry = doc.css("div.main_art")
      	entry.each {
      		|article|
      		#@searched = 1
      		title = article.css("span").first.content.strip
      		img = article.css("a img.img_thumb").first
      		img_url = img['src']
      		descr = article.css("div").first.content.strip
      		
      		say "Here is the lastest from TMZ...", spoken: "Here is the lastest from TMZ. " + title +
      		
      		object = SiriAddViews.new
    		object.make_root(last_ref_id)
    		answer = SiriAnswer.new(title, [
      		SiriAnswerLine.new('logo',img_url), # this just makes things looks nice, but is obviously specific to my username
      		SiriAnswerLine.new(descr)])
    		object.views << SiriAnswerSnippet.new([answer])
    		send_object object
      		
      		response = ask "Would you like to hear more stories?" #ask the user for something
    
    		if(response =~ /yes/i) #process their response
      			say "OK"
    		else
      			say "OK, I'll stop with all the juicy TMZ gossip."
      			break
      			##request_completed
    		end
      		
      	} 
      		#if @searched == 0
				#say "I'm sorry, I didn't see any juicy TMZ gossip. I failed you."
			#end
			request_completed
	  }
		
	  say "Checking to see if there is any gossip today..."
	  
	end
	
end
