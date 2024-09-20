class StudentsController < ApplicationController
  require 'csv'
  before_action :authenticate_user!
  def index
    @students = current_user.students
  end


  def create
    if current_user
      @student = current_user.students.find_or_initialize_by(name: student_params[:name], subject: student_params[:subject])
      @student.marks = student_params[:marks].to_i
  
      if @student.save
        render json: { success: true, message: "Student successfully created or updated!" }, status: :ok
      else
        render json: { success: false, errors: @student.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { success: false, message: "Not authenticated" }, status: :unauthorized
    end 
  end   

  def update
    if current_user
      @student = current_user.students.find(params[:id])
      if @student.update(student_params)
        render json: { success: true, message: "Student successfully updated!" }, status: :ok
      else
        render json: { success: false, errors: @student.errors.full_messages }, status: :unprocessable_entity
      end
    else
      redirect_to root_path
    end
  end  

  def delete_student
    if current_user
      ids = params[:ids]
      @students = current_user.students.where(id: ids)
  
      if @students.exists?
        @students.destroy_all
        render json: { message: 'Success' }
      else
        render json: { message: 'Students not found' }, status: :not_found
      end
    else
      redirect_to root_path
    end
  end  

  def get_all_student_list
    if current_user
      students = Student.where(user_id: current_user.id)
      if params[:search].present?
        filter = "%#{params[:search].upcase}%"
        students = students.where("students.name LIKE :filter OR students.subject LIKE :filter OR CAST(students.marks AS TEXT) LIKE :filter", filter: filter)
      end
      students_data = students.map do |student|
        { id: student.id, name: student.name, subject: student.subject, marks: student.marks }
      end
      render json: students_data
    else
      redirect_to root_path
    end
  end   

  def get_student_data
    data = Student.find(params[:id])
    render :json => data
  end

  def save_mass_data_upload
    if current_user
      csv_file = params[:csv_file]
      file_extension = File.extname(csv_file.original_filename)
      @error_msg = ""
  
      if file_extension == ".csv"
        total_count = 0
        directory = File.join(Rails.root, 'public', 'uploads')
        FileUtils.mkdir_p(directory, mode: 0777) unless File.directory?(directory)
        time = Time.now.strftime("%m_%d_%Y_%I_%M_%S%p")
        file_name = csv_file.original_filename.gsub(file_extension, "").gsub(" ", "_")
        target_file_name = "#{file_name}_#{time}#{file_extension}"
        target_file_name_path = File.join(directory, target_file_name)
  
        File.open(target_file_name_path, "wb") do |f|
          f.write(csv_file.read)
        end
  
        CSV.foreach(target_file_name_path, headers: true) do |row|
          Rails.logger.info("Processing row: #{row.inspect}")
          begin
            student_record = Student.find_or_initialize_by(name: row['Name'].upcase, subject: row['Subject'].upcase, user_id: current_user.id)
            student_record.marks = row['Marks'].to_i
            if student_record.changed?
              if student_record.save
                total_count += 1
              else
                Rails.logger.error("Failed to save student record: #{student_record.errors.full_messages.join(', ')}")
              end
            end
          rescue StandardError => e
            Rails.logger.error("Error processing CSV row: #{e.message}")
          end
        end
  
        @error_msg = total_count > 0 ? "File Processed Successfully: #{total_count} records updated." : "No new records were added."
      else
        @error_msg = "Format of file is not supported"
      end
      render plain: @error_msg
    else
      redirect_to root_path
    end
  end  

  private

  def student_params
    params.require(:student).permit(:name, :subject, :marks)
  end
end