class PayrollCalculatorService
  def self.calculate_for_employee(employee:, payroll_run:, working_days: 30, unpaid_leave_days: 0.0, leave_days: 0.0)
    structure = employee.salary_structure

    unless structure
      raise StandardError, "Employee #{employee.full_name} does not have a salary structure configured."
    end

    days_worked = [working_days - unpaid_leave_days, 0.0].max
    pay_factor = working_days.positive? ? (days_worked.to_f / working_days) : 1.0

    # Earnings calculation
    basic_pay = (structure.base_salary * pay_factor).round(2)
    hra = (structure.hra * pay_factor).round(2)
    special_allowance = (structure.special_allowance * pay_factor).round(2)
    conveyance_allowance = (structure.conveyance_allowance * pay_factor).round(2)
    medical_allowance = (structure.medical_allowance * pay_factor).round(2)

    gross_earnings = (basic_pay + hra + special_allowance + conveyance_allowance + medical_allowance).round(2)

    # Deductions calculation
    pf = ((basic_pay * (structure.pf_deduction_rate / 100.0))).round(2)
    esi = structure.esi_deduction_rate.positive? ? ((gross_earnings * (structure.esi_deduction_rate / 100.0))).round(2) : 0.0
    prof_tax = (structure.professional_tax || 0.0).round(2)
    tds = structure.tds_tax_rate.positive? ? ((gross_earnings * (structure.tds_tax_rate / 100.0))).round(2) : 0.0

    total_deductions = (pf + esi + prof_tax + tds).round(2)
    net_pay = [(gross_earnings - total_deductions).round(2), 0.0].max

    # Payslip numbering: PSL-YYYYMM-EMPCODE
    month_str = payroll_run.month.to_s.rjust(2, '0')
    payslip_num = "PSL-#{payroll_run.year}#{month_str}-#{employee.employee_code}"

    payslip = Payslip.find_or_initialize_by(payroll_run: payroll_run, employee: employee)
    payslip.assign_attributes(
      payslip_number: payslip_num,
      working_days: working_days,
      days_worked: days_worked,
      leave_days: leave_days,
      unpaid_leave_days: unpaid_leave_days,
      base_salary: structure.base_salary,
      gross_earnings: gross_earnings,
      total_deductions: total_deductions,
      net_pay: net_pay,
      payment_status: payroll_run.status == 'paid' ? 'paid' : 'pending',
      status: payroll_run.status == 'draft' ? 'draft' : 'confirmed'
    )

    ActiveRecord::Base.transaction do
      payslip.save!
      payslip.payslip_items.destroy_all

      # Create Earning Items
      payslip.payslip_items.create!(name: 'Basic Salary', category: 'earning', amount: basic_pay)
      payslip.payslip_items.create!(name: 'House Rent Allowance (HRA)', category: 'earning', amount: hra) if hra.positive?
      payslip.payslip_items.create!(name: 'Special Allowance', category: 'earning', amount: special_allowance) if special_allowance.positive?
      payslip.payslip_items.create!(name: 'Conveyance Allowance', category: 'earning', amount: conveyance_allowance) if conveyance_allowance.positive?
      payslip.payslip_items.create!(name: 'Medical Allowance', category: 'earning', amount: medical_allowance) if medical_allowance.positive?

      # Create Deduction Items
      payslip.payslip_items.create!(name: 'Provident Fund (PF)', category: 'deduction', amount: pf) if pf.positive?
      payslip.payslip_items.create!(name: 'Employee State Insurance (ESI)', category: 'deduction', amount: esi) if esi.positive?
      payslip.payslip_items.create!(name: 'Professional Tax (PT)', category: 'deduction', amount: prof_tax) if prof_tax.positive?
      payslip.payslip_items.create!(name: 'Income Tax (TDS)', category: 'deduction', amount: tds) if tds.positive?
    end

    payslip
  end

  def self.process_payroll_run(payroll_run)
    active_employees = Employee.active.includes(:salary_structure)

    ActiveRecord::Base.transaction do
      active_employees.each do |emp|
        next unless emp.salary_structure.present?
        calculate_for_employee(employee: emp, payroll_run: payroll_run)
      end

      payroll_run.recalculate_totals!
      payroll_run.update!(processed_at: Time.current)
    end

    payroll_run
  end
end
