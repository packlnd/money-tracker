class Grapher

  require 'pry'

  def self.get_pie_data(from, to, categories)
    d1 = Transaction.where(:category_id => 1).sum(:sum).to_i.abs
    d2 = Transaction.where(:category_id => 2).sum(:sum).to_i.abs
    d3 = Transaction.where(:category_id => 3).sum(:sum).to_i.abs
    d4 = Transaction.where(:category_id => 4).sum(:sum).to_i.abs
    d5 = Transaction.where(:category_id => 5).sum(:sum).to_i.abs
    d6 = Transaction.where(:category_id => 6).sum(:sum).to_i.abs
    s = ["{ data : [[0, " + d1.to_s + "]], label : '" + from.to_s + "' }", 
      "{ data : [[0, " + d2.to_s + "]], label : 'Inkomst' }", 
      "{ data : [[0, " + d3.to_s + "]], label : 'Mat & Dryck' }", 
      "{ data : [[0, " + d4.to_s + "]], label : 'Fritid'}", 
      "{ data : [[0, " + d5.to_s + "]], label : 'Bankomat'}", 
      "{ data : [[0, " + d6.to_s + "]], label : 'Transport' }"].join(", ")
    return s
  end
end