require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require_relative 'model.rb'

include Model


enable :sessions
@loginfail = false

# Körs före varje request.
#
# Hämtar användarinformation om användaren är inloggad
# och sparar information i sessionen samt sätter tränarstatus.
before() do

  if (session[:user_id] !=  nil)
    session[:user_info] = get_user_info_by_id(session[:user_id])
    session[:username] = session[:user_info]['name']
    
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

# Skyddar alla routes under /user/.
#
# Om användaren inte är inloggad skickas användaren vidare till errorsidan.
before('/user/*') do
  if (session[:user_id] ==  nil)
    session[:error] = "You need to log in to see this"
    redirect('/error')
  end
end

# Startsida.
#
# @return [Slim Template] Renderar startsidan.
get('/') do
  @loginfail = false
  slim(:home)
end

# Visar login-sidan.
#
# @return [Slim Template] Renderar login-formuläret.
get('/login') do
  @loginfail = session[:loginfail]
  session[:loginfail] = nil
  slim(:login)
end

# Hanterar inloggning.
#
# Kontrollerar användarnamn och lösenord.
# Vid lyckad inloggning sparas användar-ID i sessionen.
#
# @return [Redirect] Redirectar till aktiviteter eller tillbaka till login.
post('/login') do
  username = params[:username]
  password = params[:password]

  user = authenticate_user(username, password)

  if user
    p "Inloggad!"
    session[:loginfail] = false
    session[:user_id] = user["id"]
    redirect('/user/aktiviteter')
  else
    p "Wrong username or password"
    session[:loginfail] = true
    redirect('/login')
  end
end

# Visar alla aktiviteter för användaren.
#
# Hämtar även vilka som är kallade, frånvarande och kommer.
#
# @return [Slim Template] Renderar aktivitetsvyn.
get('/user/aktiviteter') do

  @aktiviteter = aktiviteter_info()

  @trainer_status = session[:user_info]['trainer']

  @kallade_per_aktivitet = {}
  @frånvarande_per_aktivitet = {}
  @kommer_per_aktivitet = {}

  @aktiviteter.each do |aktivitet|
    id = aktivitet["id"]

    @kallade_per_aktivitet[id] = get_called_names_by_id(id)
    @frånvarande_per_aktivitet[id] = get_abscents_names_by_id(id)
    @kommer_per_aktivitet[id] = get_coming_names_by_id(id)
  end

  slim(:aktiviteter)

end

# Visar formuläret för att skapa aktivitet.
#
# @return [Slim Template] Renderar skapa-sidan.
get('/user/createaktivitet') do
  slim(:skapa)
end

# Visar formuläret för att redigera en aktivitet.
#
# @param id [Integer] Aktivitetens ID.
# @return [Slim Template] Renderar edit-sidan.
get("/user/aktiviteter/:id/edit") do

  id = params[:id].to_i
  @special_aktivitet = get_activity_info_by_id(id)

  slim(:edit)

end

# Visar användarens profil.
#
# @return [Slim Template] Renderar profilsidan.
get('/user/profil') do
  username = session[:username]['name']
  @user_info = get_active_info_by_name(username)

  slim(:profil)

end


# Visar sidan för verifiering innan lösenordsbyte.
#
# @return [Slim Template] Renderar passwordchange-sidan.
get('/user/login/passwordchange') do
  @loginfail = session[:loginfail]
  session[:loginfail] = nil
  slim(:passwordchange)
end

# Verifierar användaren innan lösenordsbyte.
#
# @return [Redirect] Redirectar vidare till lösenordsändring eller tillbaka
post('/user/login/passwordchange') do
  username = params[:username]
  password = params[:password]

  user = authenticate_user(username, password)

  if user
    p "Inloggad!"
    session[:loginfail] = false
    redirect('/user/changepassword')
  else
    p "Wrong username or password"
    session[:loginfail] = true
    redirect('/user/login/passwordchange')
  end
end

# Visar formuläret för att byta lösenord.
#
# @return [Slim Template] Renderar changepassword-sidan.
get('/user/changepassword') do
  @confirmfail = session[:confirmnotsame]
  session[:confirmnotsame] = nil
  slim(:changepassword)
end

# Byter användarens lösenord.
#
# Kontrollerar att lösenordsbekräftelsen matchar.
#
# @return [Redirect] Redirectar till profilsidan.
post('/user/changepassword') do
  password = params[:password]

  if password != params[:passwordconfirmation]
    session[:confirmnotsame] = true
  elsif password == params[:passwordconfirmation]
    session[session[:confirmnotsame] = false]
  end
  hashed_password = BCrypt::Password.create(password)

  change_password(hashed_password, session[:username])

  redirect("/user/profil")
end

# Loggar ut användaren.
#
# Tömmer sessionen och skickar tillbaka till startsidan.
#
# @return [Redirect]
get('/logout') do
  session.clear
  redirect('/')
end

# Visar errorsidan.
#
# @return [Slim Template] Renderar error-sidan.
get('/error') do
  @error = session[:error]
  session[:error] = 'nil'
  p @error
  slim(:error)
end

# Skapar en ny användare.
#
# Skapar även relationer mellan användaren och alla aktiviteter.
#
# @return [Redirect] Redirectar till aktivitetslistan.
post("/userskapa") do 

  username = params[:username]
  password = params[:password]
  if params[:trainer] == "on"
    trainer = 1
  else
    trainer = 0
  end

  hashed_password = BCrypt::Password.create(password)

  create_user(username, hashed_password, trainer)

  aktiv_id = db.last_insert_row_id

  aktiviteter = get_actvity_ids()

  aktiviteter.each do |aktivitet|
    update_relation(aktiv_id, aktivitet["id"])
  end

  redirect("/user/aktiviteter")

end

# Uppdaterar en aktivitet.
#
# @param id [Integer] Aktivitetens ID.
# @return [Redirect] Redirectar tillbaka till aktiviteter.
post("/user/aktiviteter/:id/update") do

  id = params[:id].to_i
  name = params[:name]
  description = params[:description]

  update_activity_by_id(name,description,id)

  redirect("/user/aktiviteter")

end

# Tar bort en aktivitet.
#
# @param id [Integer] Aktivitetens ID.
# @return [Redirect] Redirectar tillbaka till aktiviteter.
post("/user/aktiviteter/:id/delete") do

  id = params[:id].to_i

  delete_activity_by_id(id)

  redirect("/user/aktiviteter")
end

# Skapar en ny aktivitet.
#
# Skapar även relationer mellan aktiviteten och alla användare.
#
# @return [Redirect] Redirectar tillbaka till aktiviteter.
post('/user/createaktivitet') do

  name = params[:new_aktivitet]
  description = params[:description]

  create_activity()

  aktivitet_id = db.last_insert_row_id

  aktiva = get_ids_from_actives()

  aktiva.each do |aktiv|
    update_relation(aktiv["id"], aktivitet_id)
  end

  @kallade = get_called_names_by_id(aktivitet_id)

  redirect("/user/aktiviteter")

end

# Uppdaterar användarens närvarostatus för en aktivitet.
#
# @param id [Integer] Aktivitetens ID.
# @return [Redirect] Redirectar tillbaka till aktiviteter.
post("/user/aktiviteter/:id/changenärvaro") do

  id = params[:id].to_i
  status = params[:status]
  aktiv_id = session[:user_id]
  p aktiv_id

  change_attendence(status, aktiv_id, id)

  redirect("/user/aktiviteter")

end