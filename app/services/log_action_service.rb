class LogActionService
    def self.log_action(record_id, current_user_id, action_type, model_type)
      # Enqueue the LogActionJob to run in the background, passing the required parameters.
      LogActionJob.perform_later(record_id, current_user_id, action_type, model_type)
    end
end