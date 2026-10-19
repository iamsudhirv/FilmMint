module Api
  module V1
    class ValuationsController < ApplicationController
      before_action :set_project

      def show
        render json: PackageValuation.new(@project).call
      end

      # What-if: swap (or drop) one package member and compare against the current package.
      # params: remove_person_id (optional), add_person_id (optional), role (optional)
      def what_if
        current = PackageValuation.new(@project).call
        members = @project.package_members.includes(:person).map do |pm|
          PackageValuation::Member.new(person: pm.person, role: pm.role, fee_usd: pm.effective_fee_usd)
        end
        removed = params[:remove_person_id].presence
        removed_member = members.find { |m| m.person.id == removed.to_i } if removed
        members.delete(removed_member) if removed_member
        if params[:add_person_id].present?
          person = Person.bookable.find(params[:add_person_id])
          members << PackageValuation::Member.new(
            person: person, role: params[:role].presence || removed_member&.role || person.kind,
            fee_usd: person.fee_usd.to_i
          )
        end
        scenario = PackageValuation.new(@project, members: members).call
        render json: { current: current, scenario: scenario, delta: delta(current, scenario) }
      end

      private

      def delta(a, b)
        {
          expected_presales_usd: b[:totals][:expected_presales_usd] - a[:totals][:expected_presales_usd],
          total_fees_usd: b[:totals][:total_fees_usd] - a[:totals][:total_fees_usd],
          risk_score: b[:risk][:score] - a[:risk][:score]
        }
      end

      def set_project
        @project = Project.find(params[:project_id])
      end
    end
  end
end
