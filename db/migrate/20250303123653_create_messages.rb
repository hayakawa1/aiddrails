class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.integer :sender_id, null: false
      t.text :content
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
