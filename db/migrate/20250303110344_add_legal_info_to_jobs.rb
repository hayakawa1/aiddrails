class AddLegalInfoToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :legal_info, :text
  end
end
