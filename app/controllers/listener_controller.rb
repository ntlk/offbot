class ListenerController < ApplicationController
	skip_before_filter :verify_authenticity_token
	skip_before_filter :authenticate_person!
	
	def receive_email
		# do i need this? *scratches head*
		@params = params
		
		sent_to = params["to"].split('@')
		message_id = sent_to[0].split('.')[1]
		@email_message = EmailMessage.find_by_message_id(message_id)
		puts @email_message.id
		person = @email_message.person
		project = @email_message.project
		reply = extract_reply(params["text"], "offbott.#{@email_message.message_id}@offbott.com")
		@update = Update.new(:body => reply, :person_id => person.id, :project_id => project.id)
													
		respond_to do |format|
			if @update.save
				add_association_with_email_message
				flash[:notice] = 'Sucessful Post.'
				format.html
				format.xml { render :xml => @update.xml, :status => :ok  }
				format.json { render :json => @update.json, :status => :ok  }
			else
				flash[:error] = 'There was an error with saving the post'
				format.xml { render :xml => @update.errors, :status => :unprocessable_entry }
				format.json { render :json => @update.errors, :status => :unprocessable_entry }
			end
		end
	
	end
	
	protected
	# useful
	def clean_field(input_string)
		input_string.gsub(/\n/, '') if input_string
	end

	def add_association_with_email_message
		@email_message.update = @update
		@email_message.save
	end

	def extract_reply(text, address)
		# What would one do without stack overflow
		# http://stackoverflow.com/a/7376064/376704
    regex_arr = [
      Regexp.new("From:\s*" + Regexp.escape(address), Regexp::IGNORECASE),
      Regexp.new("<" + Regexp.escape(address) + ">", Regexp::IGNORECASE),
      Regexp.new(Regexp.escape(address) + "\s+wrote:", Regexp::IGNORECASE),
      Regexp.new("\S*On\s\w*.\s.*@offbott.com\swrote:.*", Regexp::IGNORECASE),
      Regexp.new("-+original\s+message-+\s*$", Regexp::IGNORECASE),
      Regexp.new("from:\s*$", Regexp::IGNORECASE)
    ]

    text_length = text.length
    #calculates the matching regex closest to top of page
    index = regex_arr.inject(text_length) do |min, regex|
        [(text.index(regex) || text_length), min].min
    end

    text[0, index].strip
	end

end
