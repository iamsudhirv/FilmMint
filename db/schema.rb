# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_09_15_072712) do
  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "employee_code", null: false
    t.integer "department_id", null: false
    t.string "designation", null: false
    t.date "date_of_joining", null: false
    t.string "bank_name"
    t.string "bank_account_number"
    t.string "bank_ifsc"
    t.string "tax_id"
    t.string "status", default: "active", null: false
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["employee_code"], name: "index_employees_on_employee_code", unique: true
  end

  create_table "payroll_runs", force: :cascade do |t|
    t.integer "month", null: false
    t.integer "year", null: false
    t.string "status", default: "draft", null: false
    t.decimal "total_gross", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "total_deductions", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "total_net_pay", precision: 14, scale: 2, default: "0.0", null: false
    t.integer "employees_count", default: 0, null: false
    t.datetime "processed_at"
    t.date "payment_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year", "month"], name: "index_payroll_runs_on_year_and_month", unique: true
  end

  create_table "payslip_items", force: :cascade do |t|
    t.integer "payslip_id", null: false
    t.string "name", null: false
    t.string "category", null: false
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payslip_id"], name: "index_payslip_items_on_payslip_id"
  end

  create_table "payslips", force: :cascade do |t|
    t.integer "payroll_run_id", null: false
    t.integer "employee_id", null: false
    t.string "payslip_number", null: false
    t.integer "working_days", default: 30, null: false
    t.decimal "days_worked", precision: 4, scale: 1, default: "30.0", null: false
    t.decimal "leave_days", precision: 4, scale: 1, default: "0.0", null: false
    t.decimal "unpaid_leave_days", precision: 4, scale: 1, default: "0.0", null: false
    t.decimal "base_salary", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "gross_earnings", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_deductions", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "net_pay", precision: 12, scale: 2, default: "0.0", null: false
    t.string "payment_status", default: "pending", null: false
    t.string "status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_payslips_on_employee_id"
    t.index ["payroll_run_id", "employee_id"], name: "index_payslips_on_payroll_run_id_and_employee_id", unique: true
    t.index ["payroll_run_id"], name: "index_payslips_on_payroll_run_id"
    t.index ["payslip_number"], name: "index_payslips_on_payslip_number", unique: true
  end

  create_table "salary_structures", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.decimal "base_salary", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "hra", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "special_allowance", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "conveyance_allowance", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "medical_allowance", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "pf_deduction_rate", precision: 5, scale: 2, default: "12.0", null: false
    t.decimal "esi_deduction_rate", precision: 5, scale: 2, default: "0.75", null: false
    t.decimal "professional_tax", precision: 10, scale: 2, default: "200.0", null: false
    t.decimal "tds_tax_rate", precision: 5, scale: 2, default: "5.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_salary_structures_on_employee_id", unique: true
  end

  add_foreign_key "employees", "departments"
  add_foreign_key "payslip_items", "payslips"
  add_foreign_key "payslips", "employees"
  add_foreign_key "payslips", "payroll_runs"
  add_foreign_key "salary_structures", "employees"
end
