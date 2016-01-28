class AddCountToRecords < ActiveRecord::Migration
  def change
    add_column :records, :count, :integer
  end
end
