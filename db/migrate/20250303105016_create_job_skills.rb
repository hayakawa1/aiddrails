class CreateJobSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :job_skills do |t|
      t.references :job, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.integer :level

      t.timestamps
    end
  end
end
