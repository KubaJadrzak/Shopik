class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :espago_client, null: false, foreign_key: true

      t.date :start_date, null: false
      t.date :end_date, null: false

      t.string :status, null: false, default: 'pending'

      t.boolean :auto_renew, null: false, default: true

      t.timestamps
    end
  end
end
