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
	@articles = []
	
	def initialize(config)
    #if you have custom configuration options, process them here!
    end
  
  listen_for /TMZ/i do |phrase|
	  tmzNews = "today"
	  tmz(tmzNews) #in the function, request_completed will be called when the thread is finished
	end
	
	def tmz(news)
	  Thread.new {
	  
	    doc = Nokogiri::HTML(open("http://www.tmz.com"))
      	entry = doc.css(".post")
      	
      	i = 0
      	
      	entry.each {
      		|article|
      		#@searched = 1
      		title = article.css("a span").first.content.strip
      		
      		if title.nil?
      			break
      		end
      		img = article.css("p img").first
      		if img.nil?
      			break
      		end
      		img_url = img['src']
      		descr = article.css(".home-post-text").first.content.strip
      		if descr.nil?
      			break
      		end
      		articles[i] = [title,img_url,descr]
      		#say title
      		#puts "[Info - TMZ] article: #{title}"
      		i = i + 1
      	}
      		 
      	if i == 0
			say "I'm sorry, I didn't see any juicy TMZ gossip. I failed you."
			#request_completed
		else
			showArticle(0)
		end
		
	  }
		
	  say "Checking to see if there is any gossip today..."
	  
	end
	
	def showArticle(art)
		
		array = []
		array = @articles[art]
		
		title = array[0]
		img_url = array[1]
		descr = array[2]
		
		say "Here is the latest from TMZ...", spoken: "Here is the latest from TMZ. " + title + "."
		
		object = SiriAddViews.new
    	object.make_root(last_ref_id)
    	answer = SiriAnswer.new(title, [
      	SiriAnswerLine.new('logo',img_url), # this just makes things looks nice, but is obviously specific to my username
      	SiriAnswerLine.new(descr)])
    	object.views << SiriAnswerSnippet.new([answer])
    	send_object object
    	
    	response = ask "Would you like to hear more gossip?" #ask the user for something
    
    	if(response =~ /yes/i)- #process their response
      		@searched = @searched + 1
      		showArticle(@searched)
    	else
      		say "OK, I'll stop with all the juicy TMZ gossip."
      			#break
      			request_completed
    	end
	
	end
	
end
