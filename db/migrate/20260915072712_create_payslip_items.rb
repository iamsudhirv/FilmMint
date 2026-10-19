class CreatePayslipItems < ActiveRecord::Migration[8.0]
  def change
    create_table :payslip_items do |t|
      t.references :payslip, null: false, foreign_key: true
      t.string :name, null: false
      t.string :category, null: false # 'earning' or 'deduction'
      t.decimal :amount, precision: 12, scale: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end
