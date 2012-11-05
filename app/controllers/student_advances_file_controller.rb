class StudentAdvancesFileController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json
  
  def index
    @include_js =  "jquery"
    @student = Student.includes(:program).find(session[:user_id])
    @term_student = TermStudent.joins(:term).where("student_id=? and start_date<=? and end_date>=?",@student.id,Date.today,Date.today)
    render :layout=>false   
  end

  def destroy
    @saf = StudentAdvancesFile.find(params[:id])
    @saf.destroy
    flash[:notice] = "Archivo Eliminado."
    redirect_to :action => 'index'
  end
  
  def upload_file 
    file = params[:student_advances_file]['file']

    logger.info "FILEEEEEEEEEEEEEEE: #{file.nil?} #{file.class}"    

    if file.nil?
      flash[:error] = "Debes elegir un archivo"
      return redirect_to :action => 'index'
    end

    file.each do |f|
      @student_advances_file = StudentAdvancesFile.new
      @student_advances_file.term_student_id = params[:student_advances_file]['term_student_id']
      @student_advances_file.student_advance_type = params[:student_advances_file]['student_advance_type']
      @student_advances_file.file = f
      @student_advances_file.description = f.original_filename
      if @student_advances_file.save
        flash[:notice] = "Archivo subido exitosamente."
      else
        flash[:error] = "Error al subir archivo. #{@student_advances_file.errors.full_messages}"
      end
    end
    redirect_to :action => 'index'
  end
  
  def file
    sf = StudentAdvancesFile.find(params[:id]).file
    send_file sf.to_s, :x_sendfile=>true
  end
end
