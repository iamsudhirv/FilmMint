module Api
  module V1
    class DepartmentsController < ApplicationController
      before_action :set_department, only: %i[show update destroy]

      def index
        departments = Department.all.order(:name)
        render json: departments.as_json(methods: %i[total_employees active_employees_count])
      end

      def show
        employees = @department.employees.includes(:salary_structure).order(:first_name)
        render json: @department.as_json(methods: %i[total_employees active_employees_count]).merge(
          employees: employees.as_json(include: :salary_structure)
        )
      end

      def create
        department = Department.new(department_params)
        if department.save
          render json: department.as_json(methods: %i[total_employees active_employees_count]), status: :created
        else
          render json: { errors: department.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @department.update(department_params)
          render json: @department.as_json(methods: %i[total_employees active_employees_count])
        else
          render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @department.employees.exists?
          render json: { error: "Cannot delete department with assigned employees" }, status: :conflict
        else
          @department.destroy
          head :no_content
        end
      end

      private

      def set_department
        @department = Department.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Department not found" }, status: :not_found
      end

      def department_params
        params.require(:department).permit(:name, :code, :description)
      end
    end
  end
end
