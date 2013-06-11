require 'sequel'

DB.create_table? :categories do 
  primary_key :id
  String :name, null: false
  String :css, null: false
  String :color, null: false
end

if DB[:categories].count == 0
  DB[:categories].insert(:name => "UTGIFT", :css => "label", :color => "153,153,153")
  DB[:categories].insert(:name => "INKOMST", :css => "label label-success", :color => "70,136,71")
  DB[:categories].insert(:name => "MAT OCH DRYCK", :css => "label label-warning", :color => "248,148,6")
  DB[:categories].insert(:name => "FRITID", :css => "label label-info", :color => "57,134,172")
  DB[:categories].insert(:name => "BANKOMAT", :css => "label label-inverse", :color => "50,50,50")
  DB[:categories].insert(:name => "TRANSPORT", :css => "label label-important", :color => "184,73,71")
end

class Category < Sequel::Model
  one_to_many :transaction

  def get_color
    return self.color.split(",").map {|s| s.to_i}
  end
end
