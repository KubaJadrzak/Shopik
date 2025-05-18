class AddParentRubitIdToRubits < ActiveRecord::Migration[8.0]
  def change
    add_column :rubits, :parent_rubit_id, :integer, null: true
    add_index :rubits, :parent_rubit_id
    add_foreign_key :rubits, :rubits, column: :parent_rubit_id
  end
end
