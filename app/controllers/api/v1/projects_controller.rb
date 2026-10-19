module Api
  module V1
    class ProjectsController < ApplicationController
      def index
        render json: Project.includes(:package_members).order(updated_at: :desc).map { |p| project_json(p, risk: true) }
      end

      def show
        render json: project_json(Project.find(params[:id]), members: true)
      end

      def create
        project = Project.create!(project_params)
        render json: project_json(project, members: true), status: :created
      end

      def update
        project = Project.find(params[:id])
        project.update!(project_params)
        render json: project_json(project, members: true)
      end

      def destroy
        Project.find(params[:id]).destroy!
        head :no_content
      end

      private

      def project_params
        params.require(:project).permit(:title, :genre, :logline, :budget_usd, :political_leaning, :status)
      end

      def project_json(project, members: false, risk: false)
        json = project.as_json(only: %i[id title genre logline budget_usd political_leaning status updated_at])
        json[:member_count] = project.package_members.size
        if risk && project.package_members.any?
          valuation = PackageValuation.new(project).call
          json[:risk_level] = valuation[:risk][:level]
          json[:risk_score] = valuation[:risk][:score]
          json[:expected_presales_usd] = valuation[:totals][:expected_presales_usd]
        end
        if members
          json[:members] = project.package_members.includes(:person).order(:id).map do |pm|
            { id: pm.id, person_id: pm.person_id, name: pm.person.name, kind: pm.person.kind,
              role: pm.role, fee_usd: pm.effective_fee_usd }
          end
        end
        json
      end
    end
  end
end
