require_relative "../config/environment.rb"

class Student
	attr_accessor :name, :grade 
	attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id=nil, name, grade) 
  	@name = name 
  	@grade = grade 
  	@id = id 
  end 

  def self.create_table 
  	sql = %Q(

  			CREATE TABLE students (
  				id INTEGER PRIMARY KEY,
  				name TEXT,
  				grade INTEGER
  			)  
 	)

  	DB[:conn].execute(sql)
  end 

  def self.drop_table 
  	sql = %Q(
  		DROP TABLE students 
  	)

  	DB[:conn].execute(sql)
  end  

  def save 
  	if self.id 
  		self.update 
  	else 
	  	sql = %Q(
	  		INSERT INTO students (name, grade) 
	  		VALUES (?,?)
	  	)
	  	DB[:conn].execute(sql, self.name, self.grade) 
	  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0] 
	  end 
  end 

  def self.find_by_name(name) 
  	sql = %Q(
  		SELECT * FROM students WHERE name = ?
  	)
  	result = DB[:conn].execute(sql, name)[0] 
  	Student.new(result[0], result[1], result[2])
  end 

  def self.new_from_db(row) 
  	student = Student.new(row[0], row[1], row[2])
  	#student.id = row[0] 
  	#student.name = row[1] 
  	#student.grade = row[2] 
  	student
  end 

  def self.create(name, grade) 
  	student = Student.new(name, grade) 
  	student.save 
  	student
  end 

  def update 
  	sql = %Q(
  		UPDATE students SET name = ?, grade = ? WHERE id = ?
  	)
  	DB[:conn].execute(sql, self.name, self.grade, self.id) 
  end 
end
