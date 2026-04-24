require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require_relative 'model.rb'

include Model


enable :sessions
@loginfail = false

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

get('/user/createaktivitet') do
  slim(:skapa)
end

get("/user/aktiviteter/:id/edit") do

  id = params[:id].to_i
  @special_aktivitet = get_activity_info_by_id(id)

  slim(:edit)

end

get('/user/profil') do
  username = session[:username]['name']
  @user_info = get_active_info_by_name(username)

  slim(:profil)

end

get('/user/login/passwordchange') do
  @loginfail = session[:loginfail]
  session[:loginfail] = nil
  slim(:passwordchange)
end

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

  change_password(hashed_password, session[:username])

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

  create_user(username, hashed_password, trainer)

  aktiv_id = db.last_insert_row_id

  aktiviteter = get_actvity_ids()

  aktiviteter.each do |aktivitet|
    update_relation(aktiv_id, aktivitet["id"])
  end

  redirect("/user/aktiviteter")

end

post("/user/aktiviteter/:id/update") do

  id = params[:id].to_i
  name = params[:name]
  description = params[:description]

  update_activity_by_id(name,description,id)

  redirect("/user/aktiviteter")

end

post("/user/aktiviteter/:id/delete") do

  id = params[:id].to_i

  delete_activity_by_id(id)

  redirect("/user/aktiviteter")
end

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

post("/user/aktiviteter/:id/changenärvaro") do

  id = params[:id].to_i
  status = params[:status]
  aktiv_id = session[:user_id]
  p aktiv_id

  change_attendence(status, aktiv_id, id)

  redirect("/user/aktiviteter")

end