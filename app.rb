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