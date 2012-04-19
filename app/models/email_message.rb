class EmailMessage < ActiveRecord::Base
  attr_accessible :message_id, :person_id, :project_id, :response_timestap, :update_id
  has_one :update
  belongs_to :person
  belongs_to :project

  before_create :generate_message_id
  after_create :send_email_message

  scope :today, lambda { where('created_at >= ? AND created_at <= ?', Date.today.beginning_of_day, Date.today.end_of_day) }

  def self.on_project(project)
	  where("project_id", project.id)
	end

  private 

  def generate_message_id
  	uuid = UUID.new
  	self.message_id = uuid.generate.to_s
  end

  def send_email_message
  	RequestUpdate.request_update(self).deliver
  end

end
