class StudentsController < ApplicationController
  before_filter :auth_required
  respond_to :html, :xml, :json

  def kardex
    @screen="kardex"
    @student  = Student.includes(:program, :thesis, :contact, :scholarship, :advance).find(params[:id])

    respond_with do |format|
      format.html do
        #render :layout => false
      end
      format.pdf do
        institution = Institution.find(1)
        @logo = institution.image_url(:medium).to_s
        @is_pdf = true
        html = render_to_string(:layout => false , :action => "kardex.html.haml")
        kit = PDFKit.new(html, :page_size => 'Letter')
        kit.stylesheets << "#{Rails.root}/public/pdf.css"
        filename = "kardex-#{@student.id}.pdf"
        send_data(kit.to_pdf, :filename => filename, :type => 'application/pdf')
        return # to avoid double render call
      end
    end
  end

  def term_grades
    @screen="term_grades"
    @is_pdf = false
    @student = Student.includes(:program, :thesis, :contact, :scholarship, :advance).find(params[:id])

    if params[:term_id].to_i == 0
      @terms = @student.term_students.collect {|i| [i.term.name, i.term.id]}
      @term_id = @terms.sort.last[1]
    else
      @term_id = params[:term_id]
    end 

    @ts = TermStudent.where(:student_id => params[:id], :term_id => @term_id).first
    @grades = TermStudent.find_by_sql(["SELECT courses.code, courses.name, grade FROM term_students INNER JOIN term_course_students ON term_students.id = term_course_students.term_student_id  INNER JOIN term_courses ON term_course_id = term_courses.id INNER JOIN courses ON courses.id = term_courses.course_id WHERE term_students.student_id = :student_id AND term_students.term_id = :term_id AND term_course_students.status = :status ORDER BY courses.name", {:student_id => params[:id], :term_id => @term_id, :status => TermCourseStudent::ACTIVE}])
    respond_with do |format|
      format.html do
        #render :layout => false
      end 
      format.pdf do
        institution = Institution.find(1)
        @logo = institution.image_url(:medium).to_s
        @is_pdf = true
        html = render_to_string(:layout => false , :action => "term_grades.html.haml")
        kit = PDFKit.new(html, :page_size => 'Letter')
        kit.stylesheets << "#{Rails.root}/public/pdf.css"
        filename = "boleta-#{@ts.student_id}-#{@ts.term_id}.pdf"
        send_data(kit.to_pdf, :filename => filename, :type => 'application/pdf')
        return # to avoid double render call
      end 
    end 
  end 

  def schedule_table
    @screen="schedule_table"
    @is_pdf = false
    @student = Student.find(params[:id])
    
    if params[:term_id].to_i == 0
      @terms = @student.term_students.collect {|i| [i.term.name, i.term.id]}
      if !@terms.blank?
        @term_id = @terms.sort.last[1]
      end
    else
      @term_id = params[:term_id]
    end 

    @ts = TermStudent.where(:student_id => params[:id], :term_id => @term_id).first
    @schedule = Hash.new
    (4..22).each do |i| 
      @schedule[i] = Array.new
      (1..7).each do |j| 
        @schedule[i][j] = Array.new
      end 
    end 
    n = 0 
    courses = Hash.new
    @min_hour = 24
    @max_hour = 1 
    @ts.term_course_student.where(:status => TermCourseStudent::ACTIVE).each do |c| 
      c.term_course.term_course_schedules.where(:status => TermCourseSchedule::ACTIVE).each do |session_item|
        hstart = session_item.start_hour.hour
        hend = session_item.end_hour.hour - 1 
        (hstart..hend).each do |h| 
           if courses[c.term_course.course.id].nil? 
             n += 1
             courses[c.term_course.course.id] = n 
           end 
           comments = ''
           if session_item.start_date != @ts.term.start_date
             comments += "Inicia: #{l session_item.start_date, :format => :long}\n"
           end 
           if session_item.end_date != @ts.term.end_date
             comments += "Finaliza: #{l session_item.end_date, :format => :long}"
           end 
    
           staff_name = session_item.staff.full_name rescue 'Sin docente'

           details = { 
             "name" => c.term_course.course.name, 
             "staff_name" => staff_name,
             "classroom"  => session_item.classroom.name,
             "comments" => comments,
             "id" => session_item.id,
             "n" => courses[c.term_course.course.id]
           }
           @schedule[h][session_item.day] << details
           @min_hour = h if h < @min_hour
           @max_hour = h if h > @max_hour
        end
      end
    end
    respond_with do |format|
      format.html do
        #render :layout => false
      end
      format.pdf do
        institution = Institution.find(1)
        @logo = institution.image_url(:medium).to_s
        @is_pdf = true
        html = render_to_string(:layout => false , :action => "schedule_table.html.haml")
        kit = PDFKit.new(html, :page_size => 'Letter')
        kit.stylesheets << "#{Rails.root}/public/pdf.css"
        filename = "horario-#{@ts.student_id}-#{@ts.term_id}.pdf"
        send_data(kit.to_pdf, :filename => filename, :type => 'application/pdf')
        return # to avoid double render call
      end
    end
  end
  
  def enrollment
    #@student  = Student.includes(:program, :thesis, :contact, :scholarship, :advance).find(session[:user_id])
    @student  = Student.where(:status=>6,:id=>current_user.id)
    @origin   = params[:origin]
    if @student.size>0
      @ts = TermStudent.where(:student_id=>@student[0].id,:status=>6)
      if @ts.size >0 
        @ts2 = @ts[0]
        @ts_id = @ts[0].id
      else
        @ts2 = nil
        @ts_id = 0
      end
    
      @tcs = TermCourseStudent.where(:term_student_id=>@ts_id,:status=>6)
      @tsp = TermStudentPayment.where(:term_student_id=>@ts_id,:status=>3)
    
      @level = @student[0].program.level
      @without_courses = false
      if @level.eql? "2" and @tcs.size.eql? 0  ## para doctorado
        adv = Advance.where(:student_id=>@student[0].id)
        if @adv.size>=6
          @without_courses = true
        end
      elsif @level.eql? "1" and @tcs.size.eql? 0  ## para maestria
        t = TermCourse.joins(:term_course_students=>:term_student).joins(:course).where(:term_students=>{:student_id=>@student[0].id}).where("term_course_students.grade>=? AND courses.notes='[AI]'",70)
        if t.size>0
          @without_courses = true
        end 
      end
    end

    if @origin.eql? "gobmx"
      @include_js =  ["gobmx/jquery-1.10.2.min","gobmx/bootstrap"]
      render :layout=>'gobmx'
    else #cimav
      @include_js =  ["gobmx/jquery-1.10.2.min","gobmx/bootstrap"]
      @screen="enrollment"
      render :layout=>'gobmx'
    end
  end

  def endrollment
    json = {}
    @errors = []
    @s_id = params[:s_id]

    @student  = Student.where(:status=>6,:id=>current_user.id)
    student   = @student[0]
    student.status=1
    if student.save
      @ts = TermStudent.where(:student_id=>@student[0].id,:status=>6)
      ts  = @ts[0] 
      ts.status = 1
      if ts.save
        @tcs = TermCourseStudent.where(:status=>6,:term_student_id=>@ts[0].id)    
        @tcs.each do |tcs|
          tcs.status=1
          if !tcs.save
            @errors << 3
          end
        end
      else
        @errors << 2
      end
    else
      @errors << 1
    end

    json[:errors]= @errors
    render :json => json
  end
end
