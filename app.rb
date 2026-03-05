require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

get('/') do
  slim(:home)
end

post('/login') do

end


get('/user/aktiviteter') do

  db = SQLite3::Database.new("databas.db")

  db.results_as_hash = true

  @aktiviteter = db.execute("SELECT * FROM aktiviteter")

  p @aktiviteter

  slim(:aktiviteter)
end

get('/user/createaktivitet') do
  slim(:skapa)
end

post("/user/skapa") do 

  new_aktivtet = params[:new_aktivitet]
  description = params[:description]

  db = SQLite3::Database.new('databas.db')
  db.execute("INSERT INTO aktiviteter (name, description) VALUES (?,?)",[new_aktivtet,description])

  redirect("/user/aktiviteter")

end

get("/user/aktiviteter/:id/edit") do

  db = SQLite3::Database.new('databas.db')
  db.results_as_hash = true
  id = params[:id].to_i
  @special_aktivitet = db.execute("SELECT * FROM aktiviteter WHERE id = ?", id).first

  slim(:edit)

end

post("/user/aktiviteter/:id/update") do

  id = params[:id].to_i
  name = params[:name]
  description = params[:description]

  db = SQLite3::Database.new('databas.db')
  db.execute("UPDATE aktiviteter SET name=?, description=? WHERE id=?",[name,description,id])

  redirect("/user/aktiviteter")

end

post("/user/aktiviteter/:id/delete") do

  id = params[:id].to_i
  db = SQLite3::Database.new('databas.db')

  db.execute("DELETE FROM aktiviteter WHERE id = ?", id)

  redirect("/user/aktiviteter")
end