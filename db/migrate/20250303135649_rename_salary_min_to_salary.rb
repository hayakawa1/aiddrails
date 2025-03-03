class RenameSalaryMinToSalary < ActiveRecord::Migration[8.0]
  def change
    rename_column :jobs, :salary_min, :salary
  end
end
