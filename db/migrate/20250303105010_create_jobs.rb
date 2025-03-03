class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.references :company_profile, null: false, foreign_key: true
      t.references :employment_type, null: false, foreign_key: true
      t.references :work_style, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.integer :salary_min
      t.integer :salary_max

      t.timestamps
    end
  end
end
