# app/controllers/api/v1/renders_controller.rb
module Api
  module V1
    class RenderController < ApplicationController
      def index
        render json: { message: "Render index accessed successfully!" }  # Example response
      end
    end
  end
end
