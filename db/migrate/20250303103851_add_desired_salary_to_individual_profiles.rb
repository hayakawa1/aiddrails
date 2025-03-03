class AddDesiredSalaryToIndividualProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :individual_profiles, :desired_salary, :integer
  end
end
