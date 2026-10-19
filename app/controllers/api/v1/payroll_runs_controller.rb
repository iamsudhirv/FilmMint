module Api
  module V1
    class PayrollRunsController < ApplicationController
      before_action :set_payroll_run, only: %i[show update destroy process_run update_status recalculate]

      def index
        runs = PayrollRun.all.order(year: :desc, month: :desc)
        render json: runs.as_json(methods: :period_name)
      end

      def show
        payslips = @payroll_run.payslips.includes(:employee, :payslip_items).order('employees.first_name')
        render json: @payroll_run.as_json(methods: :period_name).merge(
          payslips: payslips.as_json(
            include: {
              employee: {
                only: %i[id first_name last_name email employee_code designation bank_name bank_account_number],
                include: { department: { only: %i[id name code] } }
              },
              payslip_items: {}
            }
          )
        )
      end

      def create
        month = params[:month].to_i
        year = params[:year].to_i

        existing = PayrollRun.find_by(month: month, year: year)
        if existing
          return render json: { error: "Payroll run for #{Date.new(year, month, 1).strftime('%B %Y')} already exists" }, status: :conflict
        end

        payroll_run = PayrollRun.new(
          month: month,
          year: year,
          status: 'draft',
          notes: params[:notes],
          payment_date: params[:payment_date] || Date.new(year, month, -1)
        )

        if payroll_run.save
          PayrollCalculatorService.process_payroll_run(payroll_run)
          render json: payroll_run.as_json(methods: :period_name), status: :created
        else
          render json: { errors: payroll_run.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @payroll_run.update(payroll_run_params)
          render json: @payroll_run.as_json(methods: :period_name)
        else
          render json: { errors: @payroll_run.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def process_run
        PayrollCalculatorService.process_payroll_run(@payroll_run)
        render json: @payroll_run.as_json(methods: :period_name)
      end

      def update_status
        new_status = params[:status]
        unless %w[draft reviewed approved paid].include?(new_status)
          return render json: { error: "Invalid status: #{new_status}" }, status: :unprocessable_entity
        end

        @payroll_run.status = new_status
        @payroll_run.payment_date = params[:payment_date] if params[:payment_date].present?

        if new_status == 'paid'
          @payroll_run.payslips.update_all(payment_status: 'paid', status: 'confirmed')
        elsif new_status == 'approved'
          @payroll_run.payslips.update_all(status: 'confirmed')
        end

        @payroll_run.save!
        render json: @payroll_run.as_json(methods: :period_name)
      end

      def destroy
        @payroll_run.destroy
        head :no_content
      end

      private

      def set_payroll_run
        @payroll_run = PayrollRun.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Payroll run not found" }, status: :not_found
      end

      def payroll_run_params
        params.require(:payroll_run).permit(:month, :year, :status, :notes, :payment_date)
      end
    end
  end
end
