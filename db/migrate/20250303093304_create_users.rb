class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :user_id
      t.string :password
      t.string :user_type

      t.timestamps
    end
  end
end
