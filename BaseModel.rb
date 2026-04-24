class BaseModel
  
  #def initialize(xxx)
  #end


  def self.table(tablename)
    @tablename = tablename
  end

  def self.property(column)
    if !@columns
      @columns = []
    end
    @columns << column
  end
  
  def self.create(xxx)
  end


  def self.get(id)
    "SELECT #{@columns.join(', ')} FROM #{@tablename} WHERE id = ?"#, [id])
    #kör faktiskt frågan
    #skapa ett objekt av klassen
    #returnera objektet
  end
  

  def self.all()
  end

  def self.update(content)
  end

  def self.delete
  end
  
  
  def self.last_insert_row_id
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    db.last_insert_row_id
  end
end

