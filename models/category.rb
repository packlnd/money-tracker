require 'sequel'

DB.create_table? :categories do
  primary_key :id
  String :name, null: false
  String :color, null: false
end
if DB[:categories].count == 0
  DB[:categories].insert(:name => "UTGIFT", :color => "#999999")
  DB[:categories].insert(:name => "INKOMST", :color => "#468847")
  DB[:categories].insert(:name => "MAT OCH DRYCK", :color => "#F89406")
  DB[:categories].insert(:name => "FRITID", :color => "#3986AC")
  DB[:categories].insert(:name => "BANKOMAT", :color => "#323232")
  DB[:categories].insert(:name => "TRANSPORT", :color => "#B84947")
end

class Category < Sequel::Model
  one_to_many :transaction

  def get_color
    return self.color.split(",").map {|s| s.to_i}
  end
end
