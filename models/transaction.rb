require 'sequel'

DB.create_table? :transactions do
	primary_key :id
	String :name, null: false
	Integer :category, null: false, default: 0
	Time :timestamp, null: false
end

class Transaction < Sequel::Model
	many_to_one :users
end