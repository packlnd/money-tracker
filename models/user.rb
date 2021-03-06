require 'sequel'

DB = Sequel.connect('sqlite://database.db')
DB.create_table? :users do
  primary_key :id
  String :username, null: false, :unique=>true
  String :password, null: false
end

class User < Sequel::Model
end
