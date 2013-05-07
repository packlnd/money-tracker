require 'sequel'

DB.create_table? :categories do 
	primary_key :id
	String :name, null: false
	String :css, null: false
end

if DB[:categories].count == 0
	DB[:categories].insert(:name => "UTGIFT", :css => "label")
	DB[:categories].insert(:name => "INKOMST", :css => "label label-success")
	DB[:categories].insert(:name => "MAT OCH DRYCK", :css => "label label-warning")
	DB[:categories].insert(:name => "FRITID", :css => "label label-info")
	DB[:categories].insert(:name => "BANKOMAT", :css => "label label-inverse")
	DB[:categories].insert(:name => "TRANSPORT", :css => "label label-important")
end

class Category < Sequel::Model
	one_to_many :transaction
end