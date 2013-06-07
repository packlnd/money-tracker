class Grapher
  def self.get_pie_data
    return ["{ data : [[0, " + Transaction.where(:category_id => 1).sum(:sum).to_i.abs.to_s + "]], label : 'Utgift' }",
      "{ data : [[0, " + Transaction.where(:category_id => 2).sum(:sum).to_i.abs.to_s + "]], label : 'Inkomst' }",
      "{ data : [[0, " + Transaction.where(:category_id => 3).sum(:sum).to_i.abs.to_s + "]], label : 'Mat & Dryck' }",
      "{ data : [[0, " + Transaction.where(:category_id => 4).sum(:sum).to_i.abs.to_s + "]], label : 'Fritid'}",
      "{ data : [[0, " + Transaction.where(:category_id => 5).sum(:sum).to_i.abs.to_s + "]], label : 'Bankomat'}",
      "{ data : [[0, " + Transaction.where(:category_id => 6).sum(:sum).to_i.abs.to_s + "]], label : 'Transport' }"].join(", ")
  end
end
