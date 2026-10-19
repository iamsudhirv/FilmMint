class CreatePayrollRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :payroll_runs do |t|
      t.integer :month, null: false
      t.integer :year, null: false
      t.string :status, default: "draft", null: false
      t.decimal :total_gross, precision: 14, scale: 2, default: 0.0, null: false
      t.decimal :total_deductions, precision: 14, scale: 2, default: 0.0, null: false
      t.decimal :total_net_pay, precision: 14, scale: 2, default: 0.0, null: false
      t.integer :employees_count, default: 0, null: false
      t.datetime :processed_at
      t.date :payment_date
      t.text :notes

      t.timestamps
    end

    add_index :payroll_runs, [:year, :month], unique: true
  end
end
