class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :search
      t.datetime :time
      
      t.timestamps null: false
    end
  end
end
