require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions
@loginfail = false

before() do
  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true

  if (session[:user_id] !=  nil)
    session[:username] = db.execute("SELECT name FROM aktiva WHERE id = ?", session[:user_id]).first #User.get(id) 
    session[:user_info] = db.execute("SELECT * FROM aktiva WHERE id = ?", session[:user_id]).first
    @trainer_status = session[:user_info]['trainer']
    p @trainer_status
    if @trainer_status == 1
      @trainer = "✅"
    else
      @trainer = ""
    end
  else
    @loginstatus = 'notloggedin'
  end
end

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

  @trainer_status = session[:user_info]['trainer']

  @kallade_per_aktivitet = {}
  @frånvarande_per_aktivitet = {}
  @kommer_per_aktivitet = {}

  @aktiviteter.each do |aktivitet|
    id = aktivitet["id"]

    @kallade_per_aktivitet[id] = db.execute('
                                            SELECT aktiva.name
                                            FROM relation
                                            JOIN aktiva ON relation.aktiv_id = aktiva.id
                                            WHERE relation.status = "kallad"
                                            AND relation.aktivitet_id = ?
                                          ', id)
    @frånvarande_per_aktivitet[id] = db.execute('
                                            SELECT aktiva.name
                                            FROM relation
                                            JOIN aktiva ON relation.aktiv_id = aktiva.id
                                            WHERE relation.status = "frånvarande"
                                            AND relation.aktivitet_id = ?
                                          ', id)
    @kommer_per_aktivitet[id] = db.execute('
                                            SELECT aktiva.name
                                            FROM relation
                                            JOIN aktiva ON relation.aktiv_id = aktiva.id
                                            WHERE relation.status = "kommer"
                                            AND relation.aktivitet_id = ?
                                          ', id)
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

get('/user/profil') do

  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true
  username = session[:username]['name']
  @user_info = db.execute("SELECT * FROM aktiva WHERE name = ?", username).first
  p (@user_info)

  slim(:profil)

end

get('/user/login/passwordchange') do
  @loginfail = session[:loginfail]
  session[:loginfail] = nil
  slim(:passwordchange)
end

post('/user/login/passwordchange') do
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
      redirect('/user/changepassword')
    else #lägg till cooldown för inloggning
      p "Wrong username or password"
      session[:loginfail] = true
      p @loginfail
      redirect('/user/login/passwordchange')
    end
  rescue BCrypt::Errors::InvalidHash
    session[:loginfail] = true
    redirect('/user/login/passwordchange')
  end
end

get('/user/changepassword') do
  @confirmfail = session[:confirmnotsame]
  session[:confirmnotsame] = nil
  slim(:changepassword)
end

post('/user/changepassword') do
  password = params[:password]

  if password != params[:passwordconfirmation]
    session[:confirmnotsame] = true
  elsif password == params[:passwordconfirmation]
    session[session[:confirmnotsame] = false]
  end
  hashed_password = BCrypt::Password.create(password)

  db = SQLite3::Database.new('db/databas.db')
  db.execute("UPDATE aktiva SET password =? WHERE name =?",[hashed_password, session[:username]['name']])

  redirect("/user/profil")
end

get('/logout') do
  session.clear
  redirect('/')
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
  db.results_as_hash = true
  db.execute("INSERT INTO aktiva (name, password, trainer) VALUES (?,?,?)",[username, hashed_password, trainer])

  aktiv_id = db.last_insert_row_id

  aktiviteter = db.execute("SELECT id FROM aktiviteter")

  aktiviteter.each do |aktivitet|
    db.execute(
      "INSERT INTO relation (aktiv_id, aktivitet_id) VALUES (?,?)",
      [aktiv_id, aktivitet["id"]]
    )
  end

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

post('/user/createaktivitet') do
  db = SQLite3::Database.new('db/databas.db')
  db.results_as_hash = true

  name = params[:new_aktivitet]
  description = params[:description]
  
  db.execute("INSERT INTO aktiviteter (name, description) VALUES (?,?)", [name, description])

  aktivitet_id = db.last_insert_row_id

  aktiva = db.execute("SELECT id FROM aktiva")

  aktiva.each do |aktiv|
    db.execute(
      "INSERT INTO relation (aktiv_id, aktivitet_id) VALUES (?,?)",
      [aktiv["id"], aktivitet_id]
    )
  end

  @kallade = db.execute('
                        SELECT aktiva.name
                        FROM relation
                        JOIN aktiva ON relation.aktiv_id = aktiva.id
                        WHERE relation.status = "kallad"
                        AND relation.aktivitet_id = ?
                      ', aktivitet_id)

  redirect("/user/aktiviteter")

end

post("/user/aktiviteter/:id/changenärvaro") do

  id = params[:id].to_i
  status = params[:status]
  aktiv_id = session[:user_id]
  p aktiv_id

  db = SQLite3::Database.new('db/databas.db' )
  db.execute(
    "UPDATE relation SET status = ? WHERE aktiv_id = ? AND aktivitet_id = ?",
    [status, aktiv_id, id]
  )

  redirect("/user/aktiviteter")

end