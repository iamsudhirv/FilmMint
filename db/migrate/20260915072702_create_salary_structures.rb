class CreateSalaryStructures < ActiveRecord::Migration[8.0]
  def change
    create_table :salary_structures do |t|
      t.references :employee, null: false, foreign_key: true, index: { unique: true }
      t.decimal :base_salary, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :hra, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :special_allowance, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :conveyance_allowance, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :medical_allowance, precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :pf_deduction_rate, precision: 5, scale: 2, default: 12.0, null: false
      t.decimal :esi_deduction_rate, precision: 5, scale: 2, default: 0.75, null: false
      t.decimal :professional_tax, precision: 10, scale: 2, default: 200.0, null: false
      t.decimal :tds_tax_rate, precision: 5, scale: 2, default: 5.0, null: false

      t.timestamps
    end
  end
end
