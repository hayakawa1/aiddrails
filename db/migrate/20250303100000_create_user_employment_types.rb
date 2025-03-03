class CreateUserEmploymentTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_employment_types do |t|
      t.references :user, null: false, foreign_key: true
      t.references :employment_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
