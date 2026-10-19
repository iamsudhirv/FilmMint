module Api
  module V1
    class IndustriesController < ApplicationController
      def index
        render json: Industry::LABELS.map { |key, label| { key: key, label: label } }
      end
    end
  end
end
