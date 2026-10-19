class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :employee_code, null: false
      t.references :department, null: false, foreign_key: true
      t.string :designation, null: false
      t.date :date_of_joining, null: false
      t.string :bank_name
      t.string :bank_account_number
      t.string :bank_ifsc
      t.string :tax_id
      t.string :status, default: "active", null: false
      t.string :avatar_url

      t.timestamps
    end

    add_index :employees, :email, unique: true
    add_index :employees, :employee_code, unique: true
  end
end
