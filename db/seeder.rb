require 'sqlite3'

db = SQLite3::Database.new("db/databas.db")


def seed!(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def create_tables(db)
  db.execute('CREATE TABLE aktiviteter (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT)')
  db.execute('CREATE TABLE aktiva (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              password TEXT NOT NULL,
              trainer BOOLEAN)')
  db.execute('CREATE TABLE relation (
              aktiv_id INTEGER, 
              aktivitet_id INTEGER, 
              status TEXT DEFAULT "kallad",
              PRIMARY KEY (aktiv_id, aktivitet_id), 
              FOREIGN KEY (aktiv_id) REFERENCES aktiva(id) ON DELETE CASCADE, 
              FOREIGN KEY (aktivitet_id) REFERENCES aktiviteter(id) ON DELETE CASCADE)')
end

def populate_tables(db)
  #db.execute('INSERT INTO aktiviteter (name, description) VALUES ("Cykelträning", "Samling eklanda parkering 13:50")')
end


seed!(db)





