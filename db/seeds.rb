puts "🌱 Seeding TeamTally Payroll database..."

# 1. Departments
departments_data = [
  { name: "Engineering", code: "ENG", description: "Software development, architecture, DevOps, and QA." },
  { name: "Product & Design", code: "PRD", description: "Product management, UX/UI design, and user research." },
  { name: "Sales & Marketing", code: "MKT", description: "Enterprise sales, growth marketing, and branding." },
  { name: "Human Resources", code: "HR", description: "Talent acquisition, employee relations, and culture." },
  { name: "Finance & Operations", code: "FIN", description: "Corporate accounting, financial planning, and office ops." }
]

depts = {}
departments_data.each do |d|
  depts[d[:code]] = Department.find_or_create_by!(code: d[:code]) do |dept|
    dept.name = d[:name]
    dept.description = d[:description]
  end
end

puts "✅ #{Department.count} departments created."

# 2. Employees & Salary Structures
employees_data = [
  {
    first_name: "Aarav", last_name: "Sharma", email: "aarav.sharma@teamtally.com",
    phone: "+91 98765 43210", employee_code: "EMP-001", department: depts["ENG"],
    designation: "Lead Systems Architect", date_of_joining: Date.new(2023, 3, 1),
    bank_name: "HDFC Bank", bank_account_number: "50100456789123", bank_ifsc: "HDFC0001234", tax_id: "ABCPS1234A",
    salary: { base_salary: 120000, hra: 50000, special_allowance: 25000, conveyance_allowance: 5000, medical_allowance: 3000, pf_deduction_rate: 12.0, esi_deduction_rate: 0.0, professional_tax: 200, tds_tax_rate: 10.0 }
  },
  {
    first_name: "Priya", last_name: "Patel", email: "priya.patel@teamtally.com",
    phone: "+91 98111 22334", employee_code: "EMP-002", department: depts["ENG"],
    designation: "Senior Frontend Engineer", date_of_joining: Date.new(2023, 6, 15),
    bank_name: "ICICI Bank", bank_account_number: "000105001234", bank_ifsc: "ICIC0000001", tax_id: "BCCPP4567B",
    salary: { base_salary: 85000, hra: 35000, special_allowance: 15000, conveyance_allowance: 4000, medical_allowance: 2500, pf_deduction_rate: 12.0, esi_deduction_rate: 0.0, professional_tax: 200, tds_tax_rate: 7.5 }
  },
  {
    first_name: "Rohan", last_name: "Mehta", email: "rohan.mehta@teamtally.com",
    phone: "+91 98222 33445", employee_code: "EMP-003", department: depts["ENG"],
    designation: "Full Stack Developer", date_of_joining: Date.new(2024, 1, 10),
    bank_name: "Axis Bank", bank_account_number: "912010023456789", bank_ifsc: "UTIB0000123", tax_id: "CDRPM8901C",
    salary: { base_salary: 60000, hra: 25000, special_allowance: 10000, conveyance_allowance: 3000, medical_allowance: 2000, pf_deduction_rate: 12.0, esi_deduction_rate: 0.75, professional_tax: 200, tds_tax_rate: 5.0 }
  },
  {
    first_name: "Sneha", last_name: "Verma", email: "sneha.verma@teamtally.com",
    phone: "+91 98333 44556", employee_code: "EMP-004", department: depts["PRD"],
    designation: "Principal Product Designer", date_of_joining: Date.new(2023, 4, 1),
    bank_name: "State Bank of India", bank_account_number: "30291827364", bank_ifsc: "SBIN0004567", tax_id: "DEFPS3456D",
    salary: { base_salary: 95000, hra: 40000, special_allowance: 18000, conveyance_allowance: 4000, medical_allowance: 3000, pf_deduction_rate: 12.0, esi_deduction_rate: 0.0, professional_tax: 200, tds_tax_rate: 8.0 }
  },
  {
    first_name: "Vikram", last_name: "Nair", email: "vikram.nair@teamtally.com",
    phone: "+91 98444 55667", employee_code: "EMP-005", department: depts["PRD"],
    designation: "Product Manager", date_of_joining: Date.new(2023, 9, 1),
    bank_name: "HDFC Bank", bank_account_number: "50100987654321", bank_ifsc: "HDFC0001234", tax_id: "EFGVN7890E",
    salary: { base_salary: 90000, hra: 38000, special_allowance: 16000, conveyance_allowance: 4000, medical_allowance: 2500, pf_deduction_rate: 12.0, esi_deduction_rate: 0.0, professional_tax: 200, tds_tax_rate: 8.0 }
  },
  {
    first_name: "Ananya", last_name: "Deshmukh", email: "ananya.deshmukh@teamtally.com",
    phone: "+91 98555 66778", employee_code: "EMP-006", department: depts["MKT"],
    designation: "Growth Marketing Director", date_of_joining: Date.new(2023, 2, 15),
    bank_name: "Kotak Mahindra Bank", bank_account_number: "7612345678", bank_ifsc: "KKBK0000123", tax_id: "FGHDM2345F",
    salary: { base_salary: 110000, hra: 45000, special_allowance: 22000, conveyance_allowance: 5000, medical_allowance: 3000, pf_deduction_rate: 12.0, esi_deduction_rate: 0.0, professional_tax: 200, tds_tax_rate: 10.0 }
  },
  {
    first_name: "Karan", last_name: "Singhania", email: "karan.singhania@teamtally.com",
    phone: "+91 98666 77889", employee_code: "EMP-007", department: depts["MKT"],
    designation: "Enterprise Sales Manager", date_of_joining: Date.new(2024, 2, 1),
    bank_name: "ICICI Bank", bank_account_number: "000105009988", bank_ifsc: "ICIC0000001", tax_id: "GHIKS6789G",
    salary: { base_salary: 75000, hra: 30000, special_allowance: 15000, conveyance_allowance: 5000, medical_allowance: 2000, pf_deduction_rate: 12.0, esi_deduction_rate: 0.0, professional_tax: 200, tds_tax_rate: 6.0 }
  },
  {
    first_name: "Neha", last_name: "Gupta", email: "neha.gupta@teamtally.com",
    phone: "+91 98777 88990", employee_code: "EMP-008", department: depts["HR"],
    designation: "HR Business Partner", date_of_joining: Date.new(2023, 5, 1),
    bank_name: "Axis Bank", bank_account_number: "912010099887766", bank_ifsc: "UTIB0000123", tax_id: "HIJNG0123H",
    salary: { base_salary: 65000, hra: 28000, special_allowance: 12000, conveyance_allowance: 3000, medical_allowance: 2000, pf_deduction_rate: 12.0, esi_deduction_rate: 0.75, professional_tax: 200, tds_tax_rate: 5.0 }
  },
  {
    first_name: "Dev", last_name: "Malhotra", email: "dev.malhotra@teamtally.com",
    phone: "+91 98888 99001", employee_code: "EMP-009", department: depts["FIN"],
    designation: "Senior Financial Analyst", date_of_joining: Date.new(2023, 7, 1),
    bank_name: "HDFC Bank", bank_account_number: "50100112233445", bank_ifsc: "HDFC0001234", tax_id: "IJKDM4567I",
    salary: { base_salary: 80000, hra: 32000, special_allowance: 14000, conveyance_allowance: 3500, medical_allowance: 2500, pf_deduction_rate: 12.0, esi_deduction_rate: 0.0, professional_tax: 200, tds_tax_rate: 7.0 }
  },
  {
    first_name: "Tanvi", last_name: "Rao", email: "tanvi.rao@teamtally.com",
    phone: "+91 98999 00112", employee_code: "EMP-010", department: depts["ENG"],
    designation: "DevOps & Cloud Engineer", date_of_joining: Date.new(2024, 3, 1),
    bank_name: "Kotak Mahindra Bank", bank_account_number: "7611223344", bank_ifsc: "KKBK0000123", tax_id: "JKLTR8901J",
    salary: { base_salary: 78000, hra: 32000, special_allowance: 14000, conveyance_allowance: 4000, medical_allowance: 2000, pf_deduction_rate: 12.0, esi_deduction_rate: 0.0, professional_tax: 200, tds_tax_rate: 6.5 }
  }
]

created_employees = []
employees_data.each do |ed|
  sal = ed.delete(:salary)
  emp = Employee.find_or_initialize_by(employee_code: ed[:employee_code])
  emp.assign_attributes(ed)
  emp.save!

  # Create or update salary structure
  struct = emp.salary_structure || emp.build_salary_structure
  struct.assign_attributes(sal)
  struct.save!

  created_employees << emp
end

puts "✅ #{Employee.count} employees seeded with complete salary structures."

# 3. Seed Past Payroll Runs & Payslips
# July 2026 (Paid)
run_july = PayrollRun.find_or_create_by!(year: 2026, month: 7) do |r|
  r.status = 'paid'
  r.payment_date = Date.new(2026, 7, 31)
  r.notes = "Regular monthly payroll processing for July 2026."
end
PayrollCalculatorService.process_payroll_run(run_july)
run_july.payslips.update_all(payment_status: 'paid', status: 'confirmed')

# August 2026 (Paid)
run_august = PayrollRun.find_or_create_by!(year: 2026, month: 8) do |r|
  r.status = 'paid'
  r.payment_date = Date.new(2026, 8, 31)
  r.notes = "Regular monthly payroll processing for August 2026."
end
PayrollCalculatorService.process_payroll_run(run_august)
run_august.payslips.update_all(payment_status: 'paid', status: 'confirmed')

# September 2026 (Approved - Ready for Disbursement)
run_september = PayrollRun.find_or_create_by!(year: 2026, month: 9) do |r|
  r.status = 'approved'
  r.payment_date = Date.new(2026, 9, 30)
  r.notes = "September 2026 payroll approved. Ready for payout."
end
PayrollCalculatorService.process_payroll_run(run_september)
run_september.payslips.update_all(status: 'confirmed')

puts "✅ #{PayrollRun.count} payroll runs seeded with #{Payslip.count} payslips."
puts "🎉 Seeding complete successfully!"
