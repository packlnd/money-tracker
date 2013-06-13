require 'sequel'

DB.create_table? :categories do
  primary_key :id
  Integer :seq_id, null: false
  String :name, null: false
  String :color, null: false
end

if DB[:categories].count == 0
  DB[:categories].insert(:seq_id => 1, :name => "NO_CATEGORY", :color => "#FF0000")
  DB[:categories].insert(:seq_id => 2, :name => "UTGIFT", :color => "#999999")
  DB[:categories].insert(:seq_id => 3, :name => "INKOMST", :color => "#468847")
  DB[:categories].insert(:seq_id => 4, :name => "MAT OCH DRYCK", :color => "#F89406")
  DB[:categories].insert(:seq_id => 5, :name => "FRITID", :color => "#3986AC")
  DB[:categories].insert(:seq_id => 6, :name => "BANKOMAT", :color => "#323232")
  DB[:categories].insert(:seq_id => 7, :name => "TRANSPORT", :color => "#B84947")
end

class Category < Sequel::Model
  one_to_many :transaction

  def self.get_category(seq_id)
    Category.where(seq_id: seq_id).all[0]
  end
end
