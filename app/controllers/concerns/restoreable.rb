module Restoreable
    extend ActiveSupport::Concern
    
    included do
      before_action :set_resource, only: [:restore]
    end
  
    def restore
      if @resource && @resource.deleted_at.present?
        is_creator = case resource_name
                     when 'Project'
                       @resource.project_creator_id == current_user.id
                     when 'Task', 'Comment'
                       @resource.user_id == current_user.id
                     else
                       false
                     end
    
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
  
    def set_resource
      @resource = resource_class.with_deleted.find_by(id: params[:id])
    end
  
    def resource_name
      controller_name.singularize.humanize
    end
  
    def resource_class
      controller_name.classify.constantize
    end
  end
  
  
  