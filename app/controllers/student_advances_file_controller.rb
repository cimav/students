class StudentAdvancesFileController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json
  
  def index
    @student      = Student.includes(:program).find(session[:user_id])
    where = "term_students.student_id=? and terms.start_date<=? and terms.end_date>=? and terms.status in (?)"
    @term_student = TermStudent.joins(:term).where(where,@student.id,Date.today,Date.today,[1,2,3])
    render :layout=>false   
  end

  def destroy
    @saf = StudentAdvancesFile.find(params[:id])
    @saf.student_advances_file_message.destroy_all
    @saf.destroy
    flash[:notice] = "Archivo Eliminado."
    redirect_to :action => 'index'
  end
  
  def upload_file 
    file = params[:student_advances_file]['file']

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
        send_email(@student_advances_file)

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
 
  def send_email(student_advances_file)
    @student = Student.includes(:program).find(session[:user_id])

    if student_advances_file.student_advance_type.to_i.eql? 3
      @student.advance.where(:advance_type=>2).each do |adv|
        send_email_helper(@student,adv.tutor1,2)
        send_email_helper(@student,adv.tutor2,2)
      end
    else
      send_email_helper(@student,@student.supervisor,1)
      send_email_helper(@student,@student.co_supervisor,1)
      @student.advance.each do |adv|
        if adv.advance_date>=Date.today - 300.days
          send_email_helper(@student,adv.tutor1,1)
          send_email_helper(@student,adv.tutor2,1)
          send_email_helper(@student,adv.tutor3,1)
          send_email_helper(@student,adv.tutor4,1)
          send_email_helper(@student,adv.tutor5,1)
        end # if
      end # each
    end #else
  end 

  def send_email_helper(student,staff_id,type)
    if staff_id.nil?
      logger.info "Error al buscar el staff #{staff_id}" 
    else
      @staff   = Staff.find(staff_id)
      if @staff.institution_id.eql? 1
        if !@staff.email.blank?
          if type.to_i.eql? 1
            content = "{:full_name=>\"#{@student.full_name}\",:email=>\"#{@student.email}\"}"
            @mail = Email.new({:from=>"atencion.posgrado@cimav.edu.mx",:to=>@staff.email,:subject=>"Se ha subido un archivo de avance",:content=>content,:status=>0})
          elsif type.to_i.eql? 2
            content = "{:full_name=>\"#{@student.full_name}\",:email=>\"#{@student.email}\",:view=>9}"
            @mail = Email.new({:from=>"atencion.posgrado@cimav.edu.mx",:to=>@staff.email,:subject=>"Se ha subido un archivo de protocolo",:content=>content,:status=>0})
          end
          @mail.save
        end
      end
    end
  end
end

