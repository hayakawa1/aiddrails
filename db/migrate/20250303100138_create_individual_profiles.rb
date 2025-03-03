class CreateIndividualProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :individual_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :display_name
      t.integer :birth_year
      t.text :bio

      t.timestamps
    end
  end
end
