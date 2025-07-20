class AllowNullOnStartAndEndDateForSubscriptions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :subscriptions, :start_date, true
    change_column_null :subscriptions, :end_date, true
  end
end
