module Restoreable
    extend ActiveSupport::Concern
    
    #Callback for Restore method
    included do
      before_action :set_resource, only: [:restore]
    end

    # Restores a previously deleted resource if the user is authorized.
    def restore
      if @resource && @resource.deleted_at.present?

        # Check if the current user is the creator of the resource
        is_creator = case resource_name
                     when 'Project'
                       @resource.project_creator_id == current_user.id
                     when 'Task', 'Comment'
                       @resource.user_id == current_user.id
                     else
                       false
                     end

        # Restore the resource if the user is the creator
        if is_creator
          @resource.restore
          render json: { message: "#{resource_name} successfully restored.", resource: @resource }, status: :ok
        else
          render json: { error: "Only the creator can restore this #{resource_name}." }, status: :forbidden
        end
      else
        render json: { error: "#{resource_name} not found or not deleted" }, status: :not_found
      end
    end
    
  
    private

    # Finds the resource using the ID provided in the parameters.
    def set_resource
      @resource = resource_class.with_deleted.find_by(id: params[:id])
    end

    # Returns the humanized name of the resource based on the controller's name.
    def resource_name
      controller_name.singularize.humanize
    end

    # Gets the class of the resource based on the controller's name.
    def resource_class
      controller_name.classify.constantize
    end
  end
  
  
  