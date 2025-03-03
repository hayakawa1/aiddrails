class RemoveSalaryMaxFromJobs < ActiveRecord::Migration[8.0]
  def change
    remove_column :jobs, :salary_max, :integer
  end
end
