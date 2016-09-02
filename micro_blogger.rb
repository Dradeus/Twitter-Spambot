require 'jumpstart_auth'
require 'klout'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
		Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else
			puts "Your message is more than 140 characters long"
		end
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message:"
		puts message
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		
		if screen_names.include? target 
			message = "d @#{target} #{message}"
			self.tweet(message)
		else 
			puts "You can only DM people who follow you"
		end
	end
	
	def followers_list
		screen_names = []
		@client.followers.each do |follower|
			screen_names << follower.screen_name
		end
		
		return screen_names
	end
	
	def spam_my_followers(message)
		followers = self.followers_list
		followers.each do |f|
			self.dm(f, message)
		end
	end

	def everyones_last_tweet
		friends = @client.friends
		friends.sort_by { |friend| friend.screen_name.downcase }
		friends.each do |friend|
			timestamp = friend.status.created_at	
			msg = (friend.status.text)
			puts "#{friend.screen_name} said this on #{timestamp.strftime("%A, %b %d")}..."
			puts "#{friend.status.text}"
			puts ""
		end
	end

	def shorten(original_url)
		puts "Shortening this URL: #{original_url}"
		return @bitly.shorten(original_url)
	end
	
	def klout_score
		friends = @client.friends.collect{ |f| f.screen_name }
		friends.each do |friend|
			printf "#{friend}: "
			name = Klout::Identity.find_by_screen_name(friend)
			user = Klout::User.new(name.id)
			puts "#{user.score.score}"
			puts ""
		end
	end
	
	def run
		command = ""
		while command != "q"
			printf "Enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command
				when 'q' then puts "Goodbye!"
				when 't' then self.tweet(parts[1..-1].join(" "))
				when 'dm' then self.dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then self.spam_my_followers(parts[1..-1].join(" "))
				when 'elt' then self.everyones_last_tweet
				when 's' then self.shorten(parts[1..-1].join(" "))
				when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end

end

blogger = MicroBlogger.new
blogger.run
blogger.klout_score