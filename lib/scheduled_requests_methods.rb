module ScheduledRequestsMethods 

	def self.send_update_request(person, project)
		email = EmailMessage.new
		email.person = person
		email.project = project
		email.save
	end

	def self.create_scheduled_date(person, project, date)
		unless ScheduledRequestDate.find_by_person_id_and_project_id_and_request_date(person.id, project.id, date)
			scheduled_date = ScheduledRequestDate.new
			scheduled_date.person = person
			scheduled_date.project = project
			scheduled_date.request_date = date
			scheduled_date.save
		end
	end

	def self.regenerate_all(project)
		project.people.each do |person|
			person.generate_schedule(project)
		end
	end

	def self.generate_scheduled_dates(frequency, *sunday)
		dates = []

		# base date for generation and regeneration:
		# today (if sunday) or last sunday
		if sunday.is_a?(Array)
			if Date.today.wday == 0
				sunday = Date.today
			else
				sunday = Date.today - Date.today.wday
			end
		end

		year = sunday.year
		month = sunday.month

		if frequency == 0
			# freq. once a day
			# generate seven dates
			i = 0
			6.times  do
				day = sunday.day + i + 1
				if day > sunday.end_of_month.day
					month = month + 1
						if month == 13
							month = 1
							year = year + 1
						end
					day = 1
				end
				time = rand(9) + 9
				i = i+1
				date = DateTime.new(year,month,day,time)
				if date > DateTime.now
					dates << date
				end
			end

			dates

		elsif frequency == 1
			# twice a week
			# generate two dates

			i = 0

			2.times  do
				if i == 0
					weekday = rand(3) + 1
				elsif i == 1
					weekday = rand(2) + 4
				end
				day = sunday.day + weekday
				if day > sunday.end_of_month.day
					month = month + 1
						if month == 13
							month = 1
							year = year + 1
						end
					day = 1
				end
				time = rand(9) + 9
				i = i+1
				if DateTime.new(year,month,day,time) > DateTime.now
					dates << DateTime.new(year,month,day,time)
				end
			end

			dates

		elsif frequency == 2
			# once a week
			# generate only one date

			weekday = rand(5) + 1
			day = sunday.day + weekday
			if day > sunday.end_of_month.day
				month = month + 1
					if month == 13
						month = 1
						year = year + 1
					end
				day = 1
			end
			time = rand(9) + 9
			if DateTime.new(year,month,day,time) > DateTime.now
				dates << DateTime.new(year,month,day,time)
			end

		elsif frequency == 3
			# twice a month
			# is this the last sunday of the month? 
			#if ((sunday.end_of_month-7)..sunday.end_of_month).member?(sunday)
			# generate two dates

			i = 0

			2.times  do
				if i == 0
					day = rand(15) + 1
				elsif i == 1
					day = rand(15) - 15 + sunday.end_of_month.day
				end
				if day > sunday.end_of_month.day
					month = month + 1
						if month == 13
							month = 1
							year = year + 1
						end
					day = 1
				end
				time = rand(9) + 9
				i = i+1
				if DateTime.new(year,month,day,time) > DateTime.now
					dates << DateTime.new(year,month,day,time)
				end
			end

			dates
			#end
		elsif frequency == 4
			# once a month
			# generate one date
			last_day_of_month = sunday.end_of_month.day
			day = rand(last_day_of_month) + 1
			if day > sunday.end_of_month.day
				month = month + 1
					if month == 13
						month = 1
						year = year + 1
					end
				day = 1
			end
			time = rand(9) + 9
			if DateTime.new(year,month,day,time) > DateTime.now
				dates << DateTime.new(year,month,day,time)
			end

		end

	end
end
