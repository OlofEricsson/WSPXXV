require 'sqlite3'
require 'BCrypt'

module Model

  # Hämtar information om en användare baserat på användarens ID.
  #
  # @param id [Integer] ID för användaren som ska hämtas.
  # @return [Hash, nil] En hash med användarinformation eller nil om användaren inte finns.
  def get_user_info_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM aktiva WHERE id = ?", id).first
    db
  end

    # Autentiserar en användare genom att kontrollera användarnamn och lösenord.
    #
    # @param username [String] Användarens namn.
    # @param password [String] Lösenord i klartext.
    # @return [Hash, nil] Användarens data om inloggningen lyckas, annars nil.
  def authenticate_user(username, password)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true

    user = db.execute("SELECT * FROM aktiva WHERE name = ?", username).first

    begin
      if user && BCrypt::Password.new(user["password"]) == password
        return user
      else
        return nil
      end
    rescue BCrypt::Errors::InvalidHash
      return nil
    end
  end

  # Hämtar information om alla aktiviteter.
  #
  # @return [Array<Hash>] En array med alla aktiviteter.
  def aktiviteter_info()

    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true

    db.execute("SELECT * FROM aktiviteter")
  end

  # Hämtar namn på alla aktiva som är kallade till en aktivitet.
  #
  # @param id [Integer] Aktivitetens ID.
  # @return [Array<Hash>] Lista med namn på kallade personer.
  def get_called_names_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute('
      SELECT aktiva.name
      FROM relation
      JOIN aktiva ON relation.aktiv_id = aktiva.id
      WHERE relation.status = "kallad"
      AND relation.aktivitet_id = ?
      ', id)
  end

  # Hämtar namn på alla frånvarande personer för en aktivitet.
  #
  # @param id [Integer] Aktivitetens ID.
  # @return [Array<Hash>] Lista med namn på frånvarande personer.
  def get_abscents_names_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute('
      SELECT aktiva.name
      FROM relation
      JOIN aktiva ON relation.aktiv_id = aktiva.id
      WHERE relation.status = "frånvarande"
      AND relation.aktivitet_id = ?
      ', id)
  end

  # Hämtar namn på alla personer som kommer till en aktivitet.
  #
  # @param id [Integer] Aktivitetens ID.
  # @return [Array<Hash>] Lista med namn på deltagare som kommer.
  def get_coming_names_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute('
      SELECT aktiva.name
      FROM relation
      JOIN aktiva ON relation.aktiv_id = aktiva.id
      WHERE relation.status = "kommer"
      AND relation.aktivitet_id = ?
      ', id)
  end

  # Hämtar information om en aktivitet baserat på ID.
  #
  # @param id [Integer] Aktivitetens ID.
  # @return [Hash, nil] Aktivitetens information eller nil om aktiviteten inte finns.
  def get_activity_info_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM aktiviteter WHERE id = ?", id).first
  end

  # Hämtar information om en aktiv användare baserat på användarnamn.
  #
  # @param username [String] Användarnamnet.
  # @return [Hash, nil] Användarens information eller nil om användaren inte finns.
  def get_active_info_by_name(username)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM aktiva WHERE name = ?", username).first
  end

  # Uppdaterar lösenordet för en användare.
  #
  # @param hashed_password [String] Det hashade lösenordet.
  # @param username [String] Användarnamnet vars lösenord ska ändras.
  # @return [void]
  def change_password(hashed_password, username)
    db.execute("UPDATE aktiva SET password =? WHERE name =?",[hashed_password, username])
  end

  # Skapar en ny användare i databasen.
  #
  # @param username [String] Användarnamn för den nya användaren.
  # @param hashed_password [String] Hashat lösenord.
  # @param trainer [Boolean, Integer] Om användaren är tränare eller inte.
  # @return [void]
  def create_user(username, hashed_password, trainer)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true

    db.execute("INSERT INTO aktiva (name, password, trainer) VALUES (?,?,?)",[username, hashed_password, trainer])
  end

  # Hämtar ID för alla aktiviteter.
  #
  # @return [Array<Hash>] Lista med aktivitets-ID:n.
  def get_actvity_ids()
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true

    db.execute("SELECT id FROM aktiviteter")
  end

  # Skapar en relation mellan en aktiv och en aktivitet.
  #
  # @param active_id [Integer] ID för den aktiva personen.
  # @param activity_id [Integer] ID för aktiviteten.
  # @return [void]
  def update_relation(active_id, activity_id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true

    db.execute(
      "INSERT INTO relation (aktiv_id, aktivitet_id) VALUES (?,?)",
      [active_id, activity_id]
    )
  end

  # Uppdaterar namn och beskrivning för en aktivitet.
  #
  # @param name [String] Nytt namn för aktiviteten.
  # @param description [String] Ny beskrivning för aktiviteten.
  # @param id [Integer] ID för aktiviteten som ska uppdateras.
  # @return [void]
  def update_activity_by_id(name,description,id)

    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("UPDATE aktiviteter SET name=?, description=? WHERE id=?",[name,description,id])
  end

  # Tar bort en aktivitet från databasen.
  #
  # @param id [Integer] ID för aktiviteten som ska tas bort.
  # @return [void]
  def delete_activity_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("DELETE FROM aktiviteter WHERE id = ?", id)
  end

  # Skapar en ny aktivitet i databasen.
  #
  # @note Denna metod verkar sakna parametrarna name och description.
  #
  # @return [void]
  def create_activity()
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("INSERT INTO aktiviteter (name, description) VALUES (?,?)", [name, description])
  end

  # Hämtar ID för alla aktiva användare.
  #
  # @return [Array<Hash>] Lista med användar-ID:n.
  def get_ids_from_actives()
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT id FROM aktiva")
  end

  # Uppdaterar närvarostatus för en aktiv person i en aktivitet.
  #
  # @param status [String] Ny status, exempelvis "kommer" eller "frånvarande".
  # @param active_id [Integer] ID för den aktiva personen.
  # @param activity_id [Integer] ID för aktiviteten.
  # @return [void]
  def change_attendence(status, active_id, activity_id)
    db = SQLite3::Database.new('db/databas.db' )
    db.results_as_hash = true
    db.execute(
      "UPDATE relation SET status = ? WHERE aktiv_id = ? AND aktivitet_id = ?",
      [status, active_id, activity_id]
    )
  end

end
