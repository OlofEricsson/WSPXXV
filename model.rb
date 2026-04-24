require 'sqlite3'
require 'BCrypt'

module Model
  def get_user_info_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    data = db.execute("SELECT * FROM aktiva WHERE id = ?", id).first
    return data
  end

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

  def aktiviteter_info()

    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true

    db.execute("SELECT * FROM aktiviteter")
  end

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

  def get_activity_info_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM aktiviteter WHERE id = ?", id).first
  end

  def get_active_info_by_name(username)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM aktiva WHERE name = ?", username).first
  end

  def change_password(hashed_password, username)
    db.execute("UPDATE aktiva SET password =? WHERE name =?",[hashed_password, username])
  end

  def create_user(username, hashed_password, trainer)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("INSERT INTO aktiva (name, password, trainer) VALUES (?,?,?)",[username, hashed_password, trainer])
  end

  def get_actvity_ids()
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT id FROM aktiviteter")
  end

  def update_relation(active_id, activity_id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true

    db.execute(
      "INSERT INTO relation (aktiv_id, aktivitet_id) VALUES (?,?)",
      [active_id, activity_id]
    )
  end

  def update_activity_by_id(name,description,id)

    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("UPDATE aktiviteter SET name=?, description=? WHERE id=?",[name,description,id])
  end

  def delete_activity_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("DELETE FROM aktiviteter WHERE id = ?", id)
  end

  def create_activity(name, description)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("INSERT INTO aktiviteter (name, description) VALUES (?,?)", [name, description])
  end

  def get_ids_from_actives()
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT id FROM aktiva")
  end

  def change_attendence(status, active_id, activity_id)
    db = SQLite3::Database.new('db/databas.db' )
    db.results_as_hash = true
    db.execute(
      "UPDATE relation SET status = ? WHERE aktiv_id = ? AND aktivitet_id = ?",
      [status, active_id, activity_id]
    )
  end

end
