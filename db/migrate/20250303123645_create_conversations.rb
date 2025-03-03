class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :target_user, null: false, foreign_key: { to_table: :users }
      t.references :job, null: false, foreign_key: true
      t.string :status, default: 'active'

      t.timestamps
    end
  end
end
