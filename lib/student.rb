require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id 
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save 
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    new_student = Student.new(name, grade, id)
    new_student.save 
    new_student
  end

  def self.find_by_name(student_name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1 
    SQL
    new_student = Student.new(nil, nil)
    DB[:conn].execute(sql, student_name).each do |row|
      new_student = Student.new_from_db(row)
    end
    new_student
  end
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]


end
