class ChangeIsPrivateDefaultToIssues < ActiveRecord::Migration
  def change
    change_column_default(:issues, :is_private, true)
  end
end
