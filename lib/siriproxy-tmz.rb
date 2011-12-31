require 'cora'
require 'siri_objects'
require 'open-uri'
require 'nokogiri'

#############
# This is a plugin for SiriProxy that will allow you to check tonight's NFL scores
# Example usage: "What's the score of the Bears game?"
#############

class SiriProxy::Plugin::TMZ < SiriProxy::Plugin

	@searched = 0 
	@entry = []
	
	def initialize(config)
    #if you have custom configuration options, process them here!
    end
  
  listen_for /TMZ/i do |phrase|
	  tmzNews = "today"
	  tmz(tmzNews) #in the function, request_completed will be called when the thread is finished
	end
	
	def tmz(news)
	  
	  	say "Checking to see if there is any gossip today..."
	  
		doc = Nokogiri::HTML(open("http://www.tmz.com"))
      	@entry = doc.css(".post")
      	
      	if @entry.nil?
      		say "I'm sorry, I didn't see any juicy TMZ gossip. I failed you."
			request_completed
		end
		
		showEntry("yes")
      	
      	request_completed
 
	end
	
	def showEntry(i)
	
		article = entry[@searched]
		
		title = article.css("a span").first.content.strip
      		
      	if title.nil?
      		title = ''
      	end
      	
      	img = article.css("p img").first
      	
      	if img.nil?
      		
      	else
      		img_url = img['src']
      	end
      	
      	descr = article.css(".home-post-text").first.content.strip
      		
      	if descr.nil?
      		descr = ""
      	end
      		
      	showArticle(title,img_url,descr)
	
	end
	
	def showArticle(title1, img, desc)
		
		say "Here is the latest from TMZ...", spoken: "Here is the latest from TMZ. " + title1 + "."
		
		object = SiriAddViews.new
    	object.make_root(last_ref_id)
    	answer = SiriAnswer.new(title1, [
      	SiriAnswerLine.new('logo',img), # this just makes things looks nice, but is obviously specific to my username
      	SiriAnswerLine.new(desc)])
    	object.views << SiriAnswerSnippet.new([answer])
    	send_object object
    	
    	@searched = @searched + 1
    	
    	response = ask "Would you like to hear more gossip?" #ask the user for something
    
    	if(response =~ /yes/i) #process their response
    	   	say "OK, looking for more gossip..."
      		showEntry(@searched)	
    	else
      		say "OK, I'll stop with all the juicy TMZ gossip."
    	end
	
	end
	
end
