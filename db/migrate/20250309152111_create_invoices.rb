class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.datetime :occurred_at
      t.references :individual_user, null: false, foreign_key: { to_table: :users }
      t.references :company_user, null: false, foreign_key: { to_table: :users }
      t.references :job, null: false, foreign_key: true
      t.integer :amount, null: false
      t.boolean :paid, default: false, null: false

      t.timestamps
    end
  end
end
