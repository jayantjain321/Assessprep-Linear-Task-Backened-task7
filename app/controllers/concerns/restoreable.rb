module Restoreable
    extend ActiveSupport::Concern
    
    included do
      before_action :set_resource, only: [:restore]
    end
  
    def restore
        Rails.logger.debug "Restoring resource: #{resource_name} with ID: #{params[:id]}"
        if @resource && @resource.deleted_at.present?
          @resource.restore
          render json: { message: "#{resource_name} successfully restored.", project: @resource }, status: :ok
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
  
  
  