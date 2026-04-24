require_relative 'BaseModel.rb'

class Aktivitet < BaseModel

  table :aktiviteter
  property :id
  property :name
  property :description

  def self.activities_info()

    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true

    db.execute("SELECT * FROM aktiviteter")
  end

  def self.get_called_names_by_id(id)
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

  def self.get_abscents_names_by_id(id)
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

  def self.get_coming_names_by_id(id)
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

  def self.get_info_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM aktiviteter WHERE id = ?", id).first
  end

  def self.get_all_ids()
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("SELECT id FROM aktiviteter")
  end

  def self.update_by_id(name,description,id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("UPDATE aktiviteter SET name=?, description=? WHERE id=?",[name,description,id])
  end

  def self.delete_by_id(id)
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.execute("DELETE FROM aktiviteter WHERE id = ?", id)
  end



end

aktivitet = Aktivitet.get(3)

p aktivitet