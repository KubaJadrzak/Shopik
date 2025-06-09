class CreateCharges < ActiveRecord::Migration[8.0]
  def change
    create_table :charges do |t|
      t.references :subscription, null: false, foreign_key: true

      t.string :payment_id
      t.integer :amount, null: false

      t.string :state, default: 'new', null: false
      t.string :reject_reason
      t.string :issuer_response_code
      t.string :behaviour

      t.timestamps
    end

    add_index :charges, :payment_id, unique: true
    add_index :charges, :state
  end
end
