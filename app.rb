require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions
@loginfail = false

before('/user/*') do
  if (session[:user_id] ==  nil)
   session[:error] = "You need to log in to see this"
   redirect('/error')
 end
end

get('/') do
  @loginfail = false
  slim(:home)
end

get('/login') do
  @loginfail = session[:loginfail]
  session[:loginfail] = nil
  slim(:login)
end

post('/login') do
  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true

  username = params[:username]
  password = params[:password]
  p username
  p password

  @user = db.execute("SELECT * FROM aktiva WHERE name = ?", username).first
  begin
    if @user && BCrypt::Password.new(@user["password"]) == password
      p "Inloggad!"
      session[:loginfail] = false
      session[:user_id] = @user["id"]
      redirect('/user/aktiviteter')
    else #lägg till cooldown för inloggning
      p "Wrong username or password"
      session[:loginfail] = true
      p @loginfail
      redirect('/login')
    end
  rescue BCrypt::Errors::InvalidHash
    session[:loginfail] = true
    redirect('/login')
  end
end


get('/user/aktiviteter') do

  db = SQLite3::Database.new('db/databas.db')

  db.results_as_hash = true

  @aktiviteter = db.execute("SELECT * FROM aktiviteter")

  p @aktiviteter

  if db.execute("SELECT name FROM aktiva WHERE id = ?", session[:user_id]).first != nil
    @current_user = db.execute("SELECT name FROM aktiva WHERE id = ?", session[:user_id]).first["name"]
  else
    @current_user = 'no user is logged in'
  end

  slim(:aktiviteter)

end

get('/user/createaktivitet') do
  slim(:skapa)
end

get("/user/aktiviteter/:id/edit") do

  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true
  id = params[:id].to_i
  @special_aktivitet = db.execute("SELECT * FROM aktiviteter WHERE id = ?", id).first

  slim(:edit)

end

get('/error') do
  @error = session[:error]
  session[:error] = 'nil'
  p @error
  slim(:error)
end

post("/userskapa") do 

  username = params[:username]
  password = params[:password]
  if params[:trainer] == "on"
    trainer = 1
  else
    trainer = 0
  end

  hashed_password = BCrypt::Password.create(password)

  db = SQLite3::Database.new('db/databas.db')
  db.execute("INSERT INTO aktiva (name, password, trainer) VALUES (?,?,?)",[username, hashed_password, trainer])

  redirect("/user/aktiviteter")

end

post("/user/aktiviteter/:id/update") do

  id = params[:id].to_i
  name = params[:name]
  description = params[:description]

  db = SQLite3::Database.new('db/databas.db')
  db.execute("UPDATE aktiviteter SET name=?, description=? WHERE id=?",[name,description,id])

  redirect("/user/aktiviteter")

end

post("/user/aktiviteter/:id/delete") do

  id = params[:id].to_i
  db = SQLite3::Database.new('db/databas.db')

  db.execute("DELETE FROM aktiviteter WHERE id = ?", id)

  redirect("/user/aktiviteter")
end