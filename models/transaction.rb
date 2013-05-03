require 'sequel'

DB.create_table? :transactions do
	primary_key :id
	Integer :sum, null: false
	Integer :category, null: false, default: 0
	Time :timestamp, null: false, default: 0
	String :name, null: false, default: 0
	String :owner, null: false
end

class Transaction < Sequel::Model
end