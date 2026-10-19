module Api
  module V1
    class PackageMembersController < ApplicationController
      before_action :set_project

      def create
        person = Person.bookable.find(params.require(:person_id))
        member = @project.package_members.create!(
          person: person, role: params[:role].presence || person.kind, fee_usd: params[:fee_usd].presence
        )
        render json: member.as_json(only: %i[id person_id role fee_usd]), status: :created
      end

      def update
        member = @project.package_members.find(params[:id])
        member.update!(params.permit(:role, :fee_usd))
        render json: member.as_json(only: %i[id person_id role fee_usd])
      end

      def destroy
        @project.package_members.find(params[:id]).destroy!
        head :no_content
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end
    end
  end
end
