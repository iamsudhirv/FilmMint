module Api
  module V1
    class FilmsController < ApplicationController
      def index
        films = Film.order(year: :desc, title: :asc)
        films = films.where(industry: params[:industry]) if params[:industry].present?
        films = films.where(source: params[:source]) if params[:source].present?
        demo_totals = TerritoryPerformance.group(:film_id).sum(:gross_usd)

        render json: films.map { |f|
          f.as_json(only: %i[id title year industry language genre budget_usd source]).merge(
            worldwide_gross_usd: f.worldwide_gross_usd || demo_totals[f.id],
            has_territory_data: demo_totals.key?(f.id),
            wikidata_url: (f.wikidata_id ? "https://www.wikidata.org/wiki/#{f.wikidata_id}" : nil)
          )
        }
      end
    end
  end
end
