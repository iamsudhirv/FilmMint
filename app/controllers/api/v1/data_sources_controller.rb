module Api
  module V1
    class DataSourcesController < ApplicationController
      def index
        sources = DataSource.order(:category, :name)
        sources = sources.where(category: params[:category]) if params[:category].present?
        render json: sources
      end

      def show
        render json: DataSource.find(params[:id])
      end
    end
  end
end
