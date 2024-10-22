# app/controllers/api/v1/comments_controller.rb
module Api
  module V1
    class CommentsController < ApplicationController

      before_action :find_comment, only: [:update, :destroy] # Find the comment and check ownership before updating or deleting a comment

      # POST /tasks/:task_id/comments  Creates a comment for a specific task
      def create
        task = Task.find_by(id: params[:task_id])
        if task
          created_comments = []  # Array to hold the created comments
          params[:comments].each do |comment_data|
            # Create the comment with text and optional images
            @comment = task.comments.new(
              text: comment_data[:text],
              images: comment_data[:image].present? ? comment_data[:image] : nil
            )
            @comment.user_id = current_user.id
            if @comment.save!
              LogActionService.log_action(@comment.id, current_user.id, :create, 'Comment')
              created_comments << @comment  # Add the successfully created comment to the array
            end
          end
          render json: { message: 'Comments created successfully', comments: created_comments }, status: :created  # Return the created comments along with the message
        else
          raise TaskNotFoundError.new
        end
      end

      # PUT /comments/:id  Updates an existing comment
      def update
        authorize! :update, @comment  # CanCanCan authorization (will throw an AccessDenied exception if unauthorized)
        @comment.update!(comment_params)  #Update the comment
        LogActionService.log_action(@comment.id, current_user.id, :update, 'Comment')
        render json: { message: 'Comment updated successfully', comment: @comment }, status: :ok
      end

      # DELETE /comments/:id Deletes a comment
      def destroy
        authorize! :destroy, @comment   # CanCanCan authorization (will throw an AccessDenied exception if unauthorized)
        @comment.destroy!   # Destroy the comment and return a success 
        LogActionService.log_action(@comment.id, current_user.id, :destroy, 'Comment')
        render json: { message: 'Comment deleted successfully' }, status: :ok
      end

      # GET /comments
      def index
        comments = Comment.order(created_at: :desc).page(params[:page]).per(10) # Retrieves all comments with pagination (10 comments per page)
        render json: { comments: comments }, status: :ok
      end

      private

      # Finds the comment before updating or deleting and if comment raise exception
      def find_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise CommentNotFoundError.new   # Raise custom error if the comment is not found
      end

      # Strong parameters to allow only the permitted attributes
      def comment_params
        params.permit(comments: [:text, image: []])  # Permit the text and optional images
      end
    end
  end
end