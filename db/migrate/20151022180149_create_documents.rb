class CreateDocuments < ActiveRecord::Migration
  include pg_search

  def change
    create_table :documents do |t|
      t.string :text
      t.tsvector :texttsv
      

      t.timestamps null: false
    end
  end
end
