module Api
  module V1
    class PeopleController < ApplicationController
      def index
        people = Person.bookable.order(:name)
        people = people.search(params[:q]) if params[:q].present?
        people = people.where(kind: params[:kind]) if params[:kind].present?
        people = people.where(industry: params[:industry]) if params[:industry].present?
        people = people.where(source: params[:source]) if params[:source].present?
        render json: people.map { |p| summary(p) }
      end

      def show
        person = Person.find(params[:id])
        render json: card(person)
      end

      private

      def summary(p)
        p.as_json(only: %i[id name kind industry nationality fee_usd source])
      end

      # The "card" a producer sees: persona info plus where this person's films have sold.
      def card(person)
        value = PersonValue.new(person)
        names = Territory.pluck(:id, :name).to_h
        strengths = value.by_territory.map { |tid, v| { territory: names[tid], attributed_gross_usd: v } }
                         .sort_by { |r| -r[:attributed_gross_usd] }
        summary(person).merge(
          person.as_json(only: %i[bio politics_lean social_followers controversy_level persona_notes]),
          social_engagement_pct: person.social_engagement_pct&.to_f,
          film_count: value.film_count,
          territory_strengths: strengths,
          credits: person.credits.includes(:film).order("films.year DESC").map do |c|
            { film: c.film.title, year: c.film.year, genre: c.film.genre, industry: c.film.industry,
              language: c.film.language, worldwide_gross_usd: c.film.worldwide_gross_usd, source: c.film.source, role: c.role, billing_order: c.billing_order }
          end
        )
      end
    end
  end
end
