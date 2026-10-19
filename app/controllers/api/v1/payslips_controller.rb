module Api
  module V1
    class PayslipsController < ApplicationController
      before_action :set_payslip, only: %i[show update]

      def index
        payslips = Payslip.includes(:payroll_run, :payslip_items, employee: :department).all

        if params[:payroll_run_id].present?
          payslips = payslips.where(payroll_run_id: params[:payroll_run_id])
        end

        if params[:employee_id].present?
          payslips = payslips.where(employee_id: params[:employee_id])
        end

        if params[:payment_status].present?
          payslips = payslips.where(payment_status: params[:payment_status])
        end

        if params[:query].present?
          q = "%#{params[:query].downcase}%"
          payslips = payslips.joins(:employee).where(
            "LOWER(employees.first_name) LIKE ? OR LOWER(employees.last_name) LIKE ? OR LOWER(employees.employee_code) LIKE ? OR LOWER(payslips.payslip_number) LIKE ?",
            q, q, q, q
          )
        end

        payslips = payslips.order(created_at: :desc)

        render json: payslips.as_json(
          include: {
            payroll_run: { only: %i[id month year status payment_date], methods: :period_name },
            employee: {
              only: %i[id first_name last_name email employee_code designation bank_name bank_account_number bank_ifsc tax_id],
              include: { department: { only: %i[id name code] } },
              methods: :full_name
            },
            payslip_items: {}
          }
        )
      end

      def show
        render json: @payslip.as_json(
          include: {
            payroll_run: { only: %i[id month year status payment_date notes], methods: :period_name },
            employee: {
              include: { department: { only: %i[id name code] } },
              methods: :full_name
            },
            payslip_items: {}
          }
        )
      end

      def update
        unpaid_leaves = params[:unpaid_leave_days].to_f
        leave_days = params[:leave_days].to_f
        working_days = params[:working_days].present? ? params[:working_days].to_i : @payslip.working_days

        PayrollCalculatorService.calculate_for_employee(
          employee: @payslip.employee,
          payroll_run: @payslip.payroll_run,
          working_days: working_days,
          unpaid_leave_days: unpaid_leaves,
          leave_days: leave_days
        )

        @payslip.payroll_run.recalculate_totals!
        @payslip.reload

        render json: @payslip.as_json(
          include: {
            payroll_run: { only: %i[id month year status payment_date], methods: :period_name },
            employee: {
              include: { department: { only: %i[id name code] } },
              methods: :full_name
            },
            payslip_items: {}
          }
        )
      end

      private

      def set_payslip
        @payslip = Payslip.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Payslip not found" }, status: :not_found
      end
    end
  end
end
