module Api
  module V1
    class SalaryStructuresController < ApplicationController
      def show
        employee = Employee.find(params[:employee_id])
        structure = employee.salary_structure || employee.build_salary_structure
        render json: structure.as_json(methods: %i[total_allowances gross_monthly annual_ctc])
      end

      def update
        employee = Employee.find(params[:employee_id])
        structure = employee.salary_structure || employee.build_salary_structure

        if structure.update(salary_structure_params)
          render json: structure.as_json(methods: %i[total_allowances gross_monthly annual_ctc])
        else
          render json: { errors: structure.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def salary_structure_params
        params.require(:salary_structure).permit(
          :base_salary, :hra, :special_allowance, :conveyance_allowance,
          :medical_allowance, :pf_deduction_rate, :esi_deduction_rate,
          :professional_tax, :tds_tax_rate
        )
      end
    end
  end
end
