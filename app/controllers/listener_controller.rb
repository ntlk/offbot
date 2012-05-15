class ListenerController < ApplicationController
	skip_before_filter :verify_authenticity_token
	skip_before_filter :authenticate_person!
	
	def receive_email
		# do i need this? *scratches head*
		@params = params
		
		sent_to = params["to"].split('@')
		message_id = sent_to[0].split('.')[1]
		sent_by = params["from"].split('<')[1].chop
		body = remove_previous_updates(params["text"])

		puts "Message id: #{message_id}"
		puts "Sent by: #{sent_by}"
		puts "Headers:"
		puts params["headers"]

		if Person.find_by_email_key(message_id)
			# this means that it's unprompted, needs to be processed slightly differently
			puts "---Unprompted---"
			person = Person.find_by_email_key(message_id)
			project_slug = sent_to[0].split('.')[0]
			puts "Project slug: #{project_slug}"
			person.projects.each do |project|
				if project.to_slug == project_slug
					unless Update.find_by_body(body)
						@update = Update.new(:body => body, :person_id => person.id, :project_id => project.id)
					end
				end
			end
		else
			# this is a response to an update request
			puts "---Prompted---"
			@email_message = EmailMessage.find_by_message_id(message_id)
			person = @email_message.person
			project = @email_message.project
			puts "Message id: #{@email_message.id}, sent by: #{sent_by}, #{person.email}"
			# people use email aliases. not sure what to do.
			#if sent_by == person.email
				unless Update.find_by_body(body)
					@update = Update.new(:body => body, :person_id => person.id, :project_id => project.id)
				end
			#else 
				# @update = Update.new
			#end										
		end

		respond_to do |format|
			if @update.save
				unless Person.find_by_email_key(message_id)
					add_association_with_email_message
				end
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
		if @email_message
			@email_message.update = @update
			@email_message.save
		end
	end

	def remove_previous_updates(text)
    regex_arr = [
      Regexp.new("(What have you been up to?).*", Regexp::MULTILINE)
    ]

    text_length = text.length
    #calculates the matching regex closest to top of page
    index = regex_arr.inject(text_length) do |min, regex|
      puts min
        [(text.index(regex) || text_length), min].min
    end

    text[0, index].strip
  end



end
