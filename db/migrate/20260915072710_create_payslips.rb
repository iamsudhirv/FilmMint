class CreatePayslips < ActiveRecord::Migration[8.0]
  def change
    create_table :payslips do |t|
      t.references :payroll_run, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.string :payslip_number, null: false
      t.integer :working_days, default: 30, null: false
      t.decimal :days_worked, precision: 4, scale: 1, default: 30.0, null: false
      t.decimal :leave_days, precision: 4, scale: 1, default: 0.0, null: false
      t.decimal :unpaid_leave_days, precision: 4, scale: 1, default: 0.0, null: false
      t.decimal :base_salary, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :gross_earnings, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :total_deductions, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :net_pay, precision: 12, scale: 2, default: 0.0, null: false
      t.string :payment_status, default: "pending", null: false
      t.string :status, default: "draft", null: false

      t.timestamps
    end

    add_index :payslips, [:payroll_run_id, :employee_id], unique: true
    add_index :payslips, :payslip_number, unique: true
  end
end
