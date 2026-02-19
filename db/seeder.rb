require 'sqlite3'

db = SQLite3::Database.new("databas.db")


def seed!(db)
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS exempel')
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
  db.execute('CREATE TABLE aktiva_aktiviteter_rel (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              aktiv_id INTEGER,
              aktivitet_id INTEGER)')
end

def populate_tables(db)
  db.execute('INSERT INTO aktiviteter (name, description) VALUES ("Cykelträning", "Samling eklanda parkering 13:50")')
  db.execute('INSERT INTO aktiva (name, password, trainer) VALUES ("Admin Admin", "admin",true)')
  db.execute('INSERT INTO aktiva_aktiviteter_rel (aktiv_id, aktivitet-id) VALUES (1, 1)')
end


seed!(db)





