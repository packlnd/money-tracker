require 'sequel'

DB.create_table? :users do
  primary_key :id
  String :username, null: false, :unique=>true
  String :password, null: false
  Boolean :set_all_categories, default: true
end

class User < Sequel::Model
end
