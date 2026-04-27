require_relative 'BaseModel.rb'

class User < BaseModel

   table :aktiva
   property :id
   property :name
   property :password
   property :trainer

  # def self.get_info_by_id(id)
  #   db = SQLite3::Database.new('db/databas.db')
  #   db.results_as_hash = true
  #   data = db.execute("SELECT * FROM aktiva WHERE id = ?", id).first
  #   return data
  # end

  # def self.authenticate(username, password)
  #   db = SQLite3::Database.new('db/databas.db')
  #   db.results_as_hash = true
  #   p "hej"

  #   user = db.execute("SELECT * FROM aktiva WHERE name = ?", username).first

  #   begin
  #     if user && BCrypt::Password.new(user["password"]) == password
  #       return user
  #     else
  #       return nil
  #     end
  #   rescue BCrypt::Errors::InvalidHash
  #     return nil
  #   end
  # end

  # def self.get_info_by_name(username)
  #   db = SQLite3::Database.new('db/databas.db')
  #   db.results_as_hash = true
  #   db.execute("SELECT * FROM aktiva WHERE name = ?", username).first
  # end

  # def self.change_password(hashed_password, username)
  #   db.execute("UPDATE aktiva SET password =? WHERE name =?",[hashed_password, username])
  # end

  # def self.create(username, hashed_password, trainer)
  #   db = SQLite3::Database.new('db/databas.db')
  #   db.results_as_hash = true
  #   db.execute("INSERT INTO aktiva (name, password, trainer) VALUES (?,?,?) RETURNING (id)",[username, hashed_password, trainer])
  # end

  # def self.get_all_ids()
  #   db = SQLite3::Database.new('db/databas.db')
  #   db.results_as_hash = true
  #   db.execute("SELECT id FROM aktiva")
  # end

end

user = User.get(3)
p user