class AddPostgresQLExtension < ActiveRecord::Migration
  def change
    enable_extension "fuzzystrmatch"
    enable_extension "pg_trgm"
    enable_extension "tablefunc"
  end
end
