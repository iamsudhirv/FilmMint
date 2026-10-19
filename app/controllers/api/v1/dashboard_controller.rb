module Api
  module V1
    class DashboardController < ApplicationController
      def show
        projects = Project.includes(:package_members).order(updated_at: :desc).to_a
        rows = projects.map { |p| row(p) }

        render json: {
          metrics: {
            active_projects: projects.size,
            people_packaged: PackageMember.distinct.count(:person_id),
            high_risk_projects: rows.count { |r| r[:risk_level] == "high" }
          },
          pipeline: Project::STATUSES.index_with { |s| rows.select { |r| r[:status] == s } },
          recent: rows.first(5)
        }
      end

      private

      def row(project)
        risk = project.package_members.any? ? PackageValuation.new(project).call[:risk] : nil
        project.as_json(only: %i[id title genre budget_usd status updated_at]).symbolize_keys.merge(
          member_count: project.package_members.size, risk_level: risk&.dig(:level), risk_score: risk&.dig(:score)
        )
      end
    end
  end
end
