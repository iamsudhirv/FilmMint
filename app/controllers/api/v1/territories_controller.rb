module Api
  module V1
    class TerritoriesController < ApplicationController
      def index
        render json: Territory.all.as_json(only: %i[id name code kind])
      end
    end
  end
end
