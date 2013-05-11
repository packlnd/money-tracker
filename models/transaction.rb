# -*- encoding : utf-8 -*-
require 'sequel'
require 'pry'

DB.create_table? :transactions do
  primary_key :id
  Float :sum, null: false
  Time :timestamp, null: false, default: 0
  String :name, null: false, default: 0
  String :owner, null: false
  Integer :category_id, null: false
end

class Transaction < Sequel::Model
  many_to_one :category

  def self.get_first_entry(user)
    from = "2001-01-01"
    if Transaction.where(:owner => user).count > 0
      from = Transaction.order(Sequel.desc(:timestamp)).where(:owner => user).first.timestamp.strftime("%Y-%m-%d")
    end
    from
  end

  def self.get_last_entry(user)
    to = Time.now.strftime("%Y-%m-%d")
    if Transaction.where(:owner => user).count > 0
      to = Transaction.order(Sequel.desc(:timestamp)).where(:owner => user).last.timestamp.strftime("%Y-%m-%d")
    end
    to
  end

  def self.handle_file(file_from_user, user)
      if file_from_user
        file = File.open(file_from_user[:tempfile]).each do |line|
          data = line.delete("\r").delete("\n").split("\t")
          transaction = Transaction.new
          transaction.timestamp = data[0].chomp()
          transaction.name = data[1].chomp()
          transaction.sum = data[2].chomp().delete(" ").gsub(',','.').to_f
          transaction.determine_category
          transaction.owner = user
          transaction.save
        end
      end
  end

  def determine_sum
    if self.sum >= 0
      return "pos"
    end
    return "neg"
  end

  def determine_row
    if self.sum >= 0
      return "success"
    end
    return "error"
  end

  def determine_category
    if self.name == "MÅNADSAVG BANKKORT" or 
        self.name == "SKATT"
      self.category_id = 1
    elsif self.name == "SPINNERS" or 
        self.name.include? "SF" or 
        self.name.include? "SATS" or 
        self.name.include? "ROMME" or 
        self.name.include? "SONY" or 
        self.name.include? "STEAM"
      self.category_id = 4
    elsif self.name.include? "SL" or 
        self.name.include? "STATOIL"
      self.category_id = 6
    elsif self.name.include? "Överföring"
      self.name = "Aktiehandel"
      if sum >= 0
        self.category_id = 2
      else
        self.category_id = 1
      end
    elsif self.sum > -150
      self.category_id = 3
    elsif self.sum % 100 == 0 and self.sum >= -500 and self.sum <= -100
      self.category_id = 5
    else
      self.category_id = 1
    end
    if self.sum > 0
      self.category_id = 2
    end
  end

  def self.get_sum_year(year)
    sum = 0
    Transaction.all.each do |t|
      if t.timestamp.year == year
        sum += t.sum
      end
    end
    return sum.to_i
  end

  def self.get_sum_month(year, month)
    sum = 0
    Transaction.all.each do |t|
      if t.timestamp.year == year and t.timestamp.month == month
        sum += t.sum
      end
    end
    return sum.to_i
  end
end