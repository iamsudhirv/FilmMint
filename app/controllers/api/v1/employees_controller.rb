module Api
  module V1
    class EmployeesController < ApplicationController
      before_action :set_employee, only: %i[show update destroy payslips]

      def index
        employees = Employee.includes(:department, :salary_structure).all

        if params[:department_id].present?
          employees = employees.where(department_id: params[:department_id])
        end

        if params[:status].present?
          employees = employees.where(status: params[:status])
        end

        if params[:query].present?
          q = "%#{params[:query].downcase}%"
          employees = employees.where(
            "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(employee_code) LIKE ? OR LOWER(designation) LIKE ?",
            q, q, q, q, q
          )
        end

        employees = employees.order(:first_name)

        render json: employees.as_json(
          include: {
            department: { only: %i[id name code] },
            salary_structure: {}
          },
          methods: %i[full_name current_gross_salary]
        )
      end

      def show
        render json: @employee.as_json(
          include: {
            department: { only: %i[id name code] },
            salary_structure: {}
          },
          methods: %i[full_name current_gross_salary]
        )
      end

      def create
        employee = Employee.new(employee_params)
        
        # If salary structure is provided in nested params or build default
        if params[:salary_structure].present?
          employee.build_salary_structure(salary_structure_params)
        end

        if employee.save
          render json: employee.as_json(
            include: {
              department: { only: %i[id name code] },
              salary_structure: {}
            },
            methods: %i[full_name current_gross_salary]
          ), status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        ActiveRecord::Base.transaction do
          @employee.update!(employee_params)

          if params[:salary_structure].present?
            if @employee.salary_structure.present?
              @employee.salary_structure.update!(salary_structure_params)
            else
              @employee.create_salary_structure!(salary_structure_params)
            end
          end
        end

        @employee.reload
        render json: @employee.as_json(
          include: {
            department: { only: %i[id name code] },
            salary_structure: {}
          },
          methods: %i[full_name current_gross_salary]
        )
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def destroy
        @employee.destroy
        head :no_content
      end

      def payslips
        slips = @employee.payslips.includes(:payroll_run, :payslip_items).order(created_at: :desc)
        render json: slips.as_json(
          include: {
            payroll_run: { only: %i[id month year status payment_date] },
            payslip_items: {}
          }
        )
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Employee not found" }, status: :not_found
      end

      def employee_params
        params.require(:employee).permit(
          :first_name, :last_name, :email, :phone, :employee_code,
          :department_id, :designation, :date_of_joining,
          :bank_name, :bank_account_number, :bank_ifsc, :tax_id,
          :status, :avatar_url
        )
      end

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
