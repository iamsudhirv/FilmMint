module Api
  module V1
    class DashboardController < ApplicationController
      def index
        total_employees = Employee.count
        active_employees = Employee.where(status: 'active').count
        total_departments = Department.count

        latest_run = PayrollRun.order(year: :desc, month: :desc).first
        previous_run = PayrollRun.order(year: :desc, month: :desc).second

        current_payroll_spend = latest_run ? latest_run.total_net_pay : 0.0
        previous_payroll_spend = previous_run ? previous_run.total_net_pay : 0.0
        payroll_change_pct = previous_payroll_spend.positive? ? (((current_payroll_spend - previous_payroll_spend) / previous_payroll_spend) * 100).round(1) : 0.0

        pending_runs = PayrollRun.where(status: %w[draft reviewed]).count

        # Department spend & headcounts
        dept_stats = Department.all.map do |dept|
          emps = dept.employees.where(status: 'active').includes(:salary_structure)
          total_spend = emps.sum { |e| e.salary_structure&.gross_monthly || 0.0 }
          {
            id: dept.id,
            name: dept.name,
            code: dept.code,
            employee_count: emps.count,
            total_monthly_spend: total_spend.round(2)
          }
        end

        # Last 6 payroll runs history for trend graph
        payroll_history = PayrollRun.order(year: :desc, month: :desc).limit(6).reverse.map do |run|
          {
            id: run.id,
            month: run.month,
            year: run.year,
            period_name: run.period_name,
            total_gross: run.total_gross,
            total_deductions: run.total_deductions,
            total_net_pay: run.total_net_pay,
            employees_count: run.employees_count,
            status: run.status
          }
        end

        # Recent activities / recent payroll runs
        recent_runs = PayrollRun.order(created_at: :desc).limit(5).map do |run|
          {
            id: run.id,
            period_name: run.period_name,
            status: run.status,
            total_net_pay: run.total_net_pay,
            employees_count: run.employees_count,
            payment_date: run.payment_date,
            created_at: run.created_at
          }
        end

        render json: {
          metrics: {
            total_employees: total_employees,
            active_employees: active_employees,
            total_departments: total_departments,
            current_payroll_spend: current_payroll_spend,
            previous_payroll_spend: previous_payroll_spend,
            payroll_change_pct: payroll_change_pct,
            pending_runs: pending_runs,
            latest_period: latest_run&.period_name || "N/A"
          },
          department_stats: dept_stats,
          payroll_history: payroll_history,
          recent_runs: recent_runs
        }
      end
    end
  end
end
