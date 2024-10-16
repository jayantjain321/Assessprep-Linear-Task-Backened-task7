# app/models/concerns/loggable.rb
module Loggable
    extend ActiveSupport::Concern
  
    # Define the method for storing log messages
    def store_log_message(current_user_id, action_type)
      action_message = case action_type
                       when :create
                         'created'
                       when :update
                         'updated'
                       when :destroy
                         'deleted'
                       else
                         'performed an unknown action'
                       end
  
      # Log the message with the appropriate action and user
      log_message = "#{self.class.name} #{action_message} successfully by #{User.find(current_user_id).name} at #{Time.now}."
  
      # Update the log_message column in the model that includes this concern
      self.update_column(:log_message, log_message)
    end
end
  