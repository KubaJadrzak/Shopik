# frozen_string_literal: true

class MakePriceNullFalseOnSubscriptions < ActiveRecord::Migration[8.0]
  def change
    change_column_default :subscriptions, :price, 4.99

    change_column_null :subscriptions, :price, false
  end
end
