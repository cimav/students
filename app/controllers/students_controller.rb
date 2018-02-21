# coding: utf-8
class StudentsController < ApplicationController
  before_filter :auth_required
  before_filter :news

  respond_to :html, :xml, :json
  $CICLO = "2017-2"
  $NCICLO = "2018-1"
  $YEAR = "2017-2"

  def kardex
    @screen="kardex"
    @student  = Student.includes(:program, :thesis, :contact, :scholarship, :advance).find(current_user.id)

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

    @student   = Student.joins(:term_students=>:term).includes(:program, :advance).find(current_user.id)
    @terms     = @student.term_students.collect {|i| [i.term.name, i.term.id]}.sort
    
    if params[:id].nil?
      params[:id]  = 0
    end
    
    if params[:term_id].nil?
      params[:term_id] = 0     
    end

    if params[:term_id].to_i == 0
      @term_id   = @terms.last[1]
    else
      @term_id = params[:term_id]
    end

    if params[:id].to_i == 0
      @p_id = @student.id
    else
      @p_id = params[:id]
    end

    @tindex     = @terms.index(@terms.rassoc(@term_id.to_i))
    @term       = Term.find(@term_id)

    if @tindex!= 0
      @p_term     = Term.find(@terms[@tindex - 1][1])
      @p_advances = Advance.where("student_id=? AND advance_date between ? AND ? AND advance_type=1",@student.id,@p_term.start_date,@p_term.end_date).last
    end

    @advances   = Advance.where("student_id=? AND advance_date between ? AND ? AND advance_type=1",@student.id,@term.start_date,@term.end_date).last
    @protocol   = Advance.where("student_id=? AND advance_date between ? AND ? AND advance_type=2",@student.id,@term.start_date,@term.end_date)
    @seminar    = Advance.where("student_id=? AND advance_date between ? AND ? AND advance_type=3",@student.id,@term.start_date,@term.end_date)

    if !@advances.nil?
      if @advances.status.eql? "C"
        @adv_avg    = get_adv_avg(@advances)
      end
    end
    @ts         = TermStudent.where(:student_id => @p_id, :term_id => @term_id).first
    @grades   = TermStudent.find_by_sql(["SELECT courses.code, courses.name, grade FROM term_students INNER JOIN term_course_students ON term_students.id = term_course_students.term_student_id  INNER JOIN term_courses ON term_course_id = term_courses.id INNER JOIN courses ON courses.id = term_courses.course_id WHERE term_students.student_id = :student_id AND term_students.term_id = :term_id AND term_course_students.status = :status ORDER BY courses.name", {:student_id => @p_id, :term_id => @term_id, :status => TermCourseStudent::ACTIVE}])
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

  def get_adv_avg(a)
    grades = 0
    sum    = 0
    if !a.tutor1.nil?
      if !a.grade1.nil?
         sum = sum + a.grade1
         grades = grades + 1
      end
    end
    if !a.tutor2.nil?
      if !a.grade2.nil?
         sum = sum + a.grade2
         grades = grades + 1
      end
    end
    if !a.tutor3.nil?
      if !a.grade3.nil?
         sum = sum + a.grade3
         grades = grades + 1
      end
    end
    if !a.tutor4.nil?
      if !a.grade4.nil?
         sum = sum + a.grade4
         grades = grades + 1
      end
    end
    if !a.tutor5.nil?
      if !a.grade5.nil?
         sum = sum + a.grade5
         grades = grades + 1
      end
    end

    if !grades.eql? 0
      return sum / grades
    else
      return nil
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
    if @TCS.size>0
      redirect_to :controller=>'home', :action=>'index' and return
    end

    #@student  = Student.includes(:program, :thesis, :contact, :scholarship, :advance).find(session[:user_id])
    #@student  = Student.where(:status=>[6,7],:id=>current_user.id)
    @student   = Student.where(:status=>[1,6,7],:id=>current_user.id)
    campus_short_name = @student[0].campus.short_name
    terms     = Term.where("name like '%#{$NCICLO}%' and name like '%#{campus_short_name}%' and program_id=?",@student[0].program_id).map{|i| i.id} rescue []
    @ts       = TermStudent.joins(:term).where(:student_id=>@student[0].id,:term_id=>terms) rescue []
    @tcs = TermCourseStudent.where(:term_student_id=>@ts[0].id,:status=>[1,6,7]) rescue []
    @tsp = TermStudentPayment.where(:term_student_id=>@ts[0].id,:status=>[3,6,7])  rescue []


    # @ts.joins(:term).where(:terms=>{:name=>'2016-1 Chihuahua'})
=begin
    if @student.size>0
      @ts_id = @ts[0].id rescue 0
      @tcs = TermCourseStudent.where(:term_student_id=>@ts_id,:status=>[1,6,7])
      @tsp = TermStudentPayment.where(:term_student_id=>@ts_id,:status=>[3,6,7])

      @level = @student[0].program.level
      @without_courses = false
      if @level.eql? "2" and @tcs.size.eql? 0  ## para doctorado
        @adv = Advance.where(:student_id=>@student[0].id)
        if @adv.size>=5
          @without_courses = true
        end
      elsif @level.eql? "1" and @tcs.size.eql? 0  ## para maestria
        t = TermCourse.joins(:term_course_students=>:term_student).joins(:course).where(:term_students=>{:student_id=>@student[0].id}).where("term_course_students.grade>=? AND courses.notes='[AI]'",70)
        if t.size>0
          @without_courses = true
        end
      end
    end
=end
    @include_js =  ["jquery","jquery-ui","jquery_ujs","enrollments"]
    @screen="enrollment"
    render :layout=>'gobmx'
  end

  def enrollment_courses
    @student   = Student.find(current_user.id)
    @hfolio    = params[:folio_field]
    if @hfolio.blank?
      render :layout=>false
      return
    end
    ## get last term tha
    campus_short_name = @student.campus.short_name

    #last_term  = Term.joins(:term_students=>:student).where(:students=>{:id=>@student.id}).order("terms.end_date desc").limit(1)[0]
    ## get enrollment term
    #@e_term    = Term.where("program_id=#{@student.program.id} AND start_date  > '#{last_term.end_date}' AND name like '%#{last_term.name.split(" ")[1]}%'").last rescue
    @e_term = Term.where("name like '%#{$NCICLO}%' and name like '%#{campus_short_name}%' and program_id=? and status=1",@student.program_id).last

    if @e_term
      ## Obtenemos las materias que ya lleva acreditadas el alumno
      @stc = TermCourse.joins(:term_course_student=>:term_student).where(:term_students=>{:student_id=>@student.id}).where("term_course_students.grade>=? AND term_course_students.status=?",70,1)
      @reprobadas = TermCourse.joins(:term_course_student=>:term_student).where(:term_students=>{:student_id=>@student.id}).where("term_course_students.grade<? AND term_course_students.status=?",70,1)
      @scourses    = @stc.map{|i| i.course_id}
      @srejected   = @reprobadas.map{|i| i.course_id}
      puts "SCOURSES1: #{@scourses}"
      ## Nos traemos el plan de estudios
      @plan_estudios        = Course.where(:program_id=>@student.program.id,:studies_plan_id=>@student.studies_plan_id).where("term not in (99,100)").order(:term)
      @optativas_requeridas = Course.where(:program_id=>@student.program.id,:studies_plan_id=>@student.studies_plan_id).where("term not in (99,100) AND courses.name like '%Optativa%'").size


      if @student.studies_plan_id.eql? 15
        @optativas_cursadas   = @stc.joins(:course).where(:term_students=>{:student_id=>@student.id}).where("term_course_students.grade>=? AND courses.program_id!=? AND courses.studies_plan_id!=?",70,2,15)
      else
        @optativas_cursadas   = @stc.joins(:course).where(:term_students=>{:student_id=>@student.id}).where("term_course_students.grade>=? AND courses.term in (?)",70,[99,100])
      end
      @alternativas_cursadas   = @stc.joins(:course).where(:term_students=>{:student_id=>@student.id}).where("term_course_students.grade>=? AND courses.term not in (?) AND courses.program_id!=?",70,[99,100],@student.program.id)
      @optativas_total = @optativas_cursadas.size + @alternativas_cursadas.size
      @materias_faltantes = []

      if @student.studies_plan_id.eql? 15
        @condemned = nil
        @optativas_cursadas_map = @optativas_cursadas.map{|i| [i.id,i.course.program_id]}

        @temas_selectos = @plan_estudios.where("name like '%Temas Selectos%'").order(:term)

        opc_counter = 0
        @optativas_cursadas_map.each do |oc|
          @scourses << @temas_selectos[opc_counter].id
          opc_counter = opc_counter + 1
        end# @optativas_cursadas_map
      end ## if

      puts "SCOURSES2: #{@scourses}"
      @plan_estudios.each do |c|
         logger.debug "PLAN: #{c.id} #{c.name}"
         if !@scourses.include? c.id
           if c.name.include? "Optativa"
             if @optativas_total>0
               @optativas_total = @optativas_total - 1
             else
               @materias_faltantes << c
             end
           else
             @materias_faltantes << c
           end
         end
      end

      @materias_faltantes.each do |mf|
        logger.debug "FALTAN: #{mf.id} #{mf.name} #{mf.term}"
        @maxterm = mf.term
      end

      if @materias_faltantes.size>0
        logger.debug "PRIMER REGISTRO:  #{@materias_faltantes[0].name} #{@materias_faltantes.class}"
        logger.debug "REPROBADAS: #{@srejected.size}" 
        
        @maxterm = @materias_faltantes[0].term-1
      else
        @maxterm = @plan_estudios.maximum(:term)
      end

      ## Almacenamos en un arreglo los ciclos
      @smaxterm = [@maxterm,@maxterm+1,100]
      ## Nos traemos los cursos que no han sido aprobados, es decir, que no estan en scourses y >>
      ## los que estan en el semestre al que pertence el alumno mas uno.
      @tcs = TermCourse.joins(:term=>:program).joins(:course).where(:courses=>{:studies_plan_id=>@student.studies_plan_id},:programs=>{:id=>@student.program.id},:terms=>{:status=>1})
      @tcs = @tcs.where("terms.id=? AND courses.id not in (?) AND courses.term<=?",@e_term.id,@scourses,@maxterm+1).order("courses.program_id")

      @tcs.each do |tc|
        logger.info "##########################COURSES#{tc.course.id}#### #{tc.course.name}"
      end

      # agregamos los id de los cursos en el mapa de scourses
      @scourses += @tcs.map {|i| i.course_id}
      logger.info "##########################SCOURSES3: #{@scourses}"

      ## Obtenemos todos los cursos para el resto de los programas
      if @student.program.level.to_i.eql? 2
        @levels = [1,2]
      else
        @levels = 1
      end

      #@tcs2 = TermCourse.joins(:term=>:program).joins(:course).where(:programs=>{:level=>@levels},:terms=>{:status=>1}).where("courses.id not in (?) AND courses.program_id !=?",@scourses,@student.program.id).order("courses.program_id")
      @tcs2 = TermCourse.joins(:term=>:program).joins(:course).where(:programs=>{:level=>@levels},:terms=>{:status=>1}).where("courses.id not in (?) AND courses.studies_plan_id !=?",@scourses,@student.studies_plan_id).order("courses.program_id")

      ## OPTATIVAS
      ## Obtenemos de nuevo los cursos acreditados
      @scourses = TermCourse.joins(:term_course_student=>:term_student).where(:term_students=>{:student_id=>@student.id}).where("term_course_students.grade>=?",70).map {|i| i.course_id}
      # Obtenemos las materias del plan de estudios que faltan
      @cs = Course.where("program_id=? AND term<=? AND id not in (?)",@student.program.id,@maxterm+1,@scourses)
      # obtenemos la cantidad de optativas que ya han sido aprobadas
      @optativas = TermCourse.joins(:term_course_student=>:term_student).joins(:course).where("term_students.student_id=? AND courses.program_id=? AND term_course_students.grade>=? AND courses.term in (?)",@student.id,@student.program.id,70,[99,100])
      
      logger.info "##########################OPTATIVAS#### #{@optativas.size} "
      @soptativas = @optativas.map{|i| i.course_id}
      # ahora las optativas que faltan para el programa
      @soptativas << 0
      @optativasf = TermCourse.joins(:course).where("courses.program_id=? AND courses.id not in (?) AND courses.term in (?) AND term_id=?",@student.program.id,@soptativas,[99,100],@e_term.id)

      ## asisgnando permisos para inscribir sin materias
      @without_courses = false
      if @student.program.level.to_i.eql? 2 ## los de doctorado
        @without_courses = true
      elsif @student.program.level.to_i.eql? 1 ## los de maestria con una materia de tesis calificada
        t = TermCourse.joins(:term_course_student=>:term_student).joins(:course).where(:term_students=>{:student_id=>@student.id}).where("term_course_students.grade>=? AND courses.notes='[AI]'",70)
        if t.size>0
          @without_courses = true
        end
      end
    end
    respond_to do |format|
      format.html do
        render :layout=> false
      end
    end
  end

  def assign_courses
    json = {}
    @message  = ""
    @errors   = []
    @none  = params[:chk_none]
    @student  = Student.find(current_user.id)
    terms     = Term.where("name like '%#{$NCICLO}%' and program_id=?",@student.program_id).map{|i| i.id} rescue []
    @ts       = TermStudent.where(:student_id=>@student.id,:term_id=>terms) rescue []
    @ts_access   = false
    @payment_access = false

    if @ts.size>0
      if @ts[0].status.eql? 7
        @ts[0].status     = 6
        @ts[0].save
        TermCourseStudent.where(:term_student_id=>@ts[0].id,:status=>6).delete_all
        @ts_access = true
        @ts = @ts[0]
        @payment_access = false
      #else
      #  @errors  << 8
      #  @message = "Ya existe un registro de ciclo"
      end
    else
      ## primero pre-inscribimos al alumno al ciclo
      @payment_access = true
      @ts = TermStudent.new
      @ts.term_id    = params[:eterm]
      @ts.student_id = params[:s_id]
      @ts.status     = 6
      begin
        @ts.save!
        @ts_access = true
      rescue ActiveRecord::RecordInvalid
        @ts_access = true
        logger.info "Repeticion-ts: #{@ts.student_id}"
      rescue
        @ts_access = false
        @errors  << 2
        @message= "No se pudo inscribir al ciclo"
      rescue Exception
        @ts_access = false
        @errors  << 3
        @message= "No se pudo inscribir al ciclo"
      end
    end

    @tcs_access = false

    if @ts_access
      if @none.nil?
      ## Ahora inscribimos a los cursos
        params[:tcourses].each do |tc|
          #@errors << tc.to_s
          @tcs = TermCourseStudent.new
          @tcs.term_course_id  = tc
          @tcs.term_student_id = @ts.id
          @tcs.status          = 6
          begin
            @tcs.save!
            @tcs_access = true
          rescue ActiveRecord::RecordInvalid
            @tcs_access = true
            logger.info "Repeticion-tcs: #{@ts.student_id} #{@tcs.term_course_id}"
          rescue
            @message= "No se pudo inscribir a las materias"
            @errors << 5
            @tcs_access = false
          rescue Exception
            @message= "No se pudo inscribir a las materias"
            @errors << 6
            @tcs_access = false
          end
        end#params

        if @tcs_access and @payment_access
            ## capturamos el pago
            @tsp = TermStudentPayment.new
            @tsp.term_student_id = @ts.id
            @tsp.status = 6
            @tsp.folio  = params[:hfolio]
            if @tsp.save
              ## Enviamos mail al asesor (ponemos en la cola de correos el mensaje)
              s = Student.find(params[:s_id])
              staff = Staff.find(s.supervisor)
              to = staff.email
              content = "{:full_name=>\"#{s.full_name}\",:email=>\"#{s.email_cimav}\",:view=>5}"
              subject = "Estan listas materias para inscripción de #{s.full_name}"
              mail    = Email.new({:from=>"atencion.posgrado@cimav.edu.mx",:to=>to,:subject=>subject,:content=>content,:status=>0})
              mail.save
            else
              @message= "No se pudo capturar el pago"
              @errors << 7
            end
        end
      else
        ## capturamos el pago
        @tsp = TermStudentPayment.new
        @tsp.term_student_id = @ts.id
        @tsp.status = 6
        @tsp.folio  = params[:hfolio]
        if @tsp.save
          ## Enviamos mail al asesor (ponemos en la cola de correos el mensaje)
          s = Student.find(params[:s_id])
          staff = Staff.find(s.supervisor)
          to = staff.email
          content = "{:full_name=>\"#{s.full_name}\",:email=>\"#{s.email_cimav}\",:view=>5}"
          subject = "Estan listas materias para inscripción de #{s.full_name}"
          mail    = Email.new({:from=>"atencion.posgrado@cimav.edu.mx",:to=>to,:subject=>subject,:content=>content,:status=>0})
          mail.save
        else
          @message= "No se pudo capturar el pago"
          @errors << 7
        end
      end#if none
    end#if ts_access

    respond_with do |format|
      format.html do
        if request.xhr?
          json[:message] = @message
          json[:errors]  = @errors
          json[:s_id]    = params[:s_id]
          render :json => json
        else
          render :layout => false
        end
      end
    end
  end

  def check_folio
    json = {}
    @errors = []
    @folio = params[:folio]
    @student  = Student.find(current_user.id)
    terms     = Term.where("name like '%#{$NCICLO}%' and program_id=?",@student.program_id).map{|i| i.id} rescue []
    @ts       = TermStudent.where(:student_id=>@student.id,:term_id=>terms) rescue []
    validate  = true

    if @ts.size>0
      if @ts[0].status.eql? 7
        validate = false
      end
    end

    if validate
      if !@folio.size.eql? 20
        @errors << "el folio debe ser de 20 caracteres"
      end

      if !(@folio =~ /\A[-+]?\d+\z/)
        @errors << "el folio debe ser numerico"
      end

      if @errors.size.eql? 0
        tsp = TermStudentPayment.where(:folio=>@folio)

        if !tsp.size.eql? 0
          @errors << "Ya existe un registro con ese folio"
        end
      end
    end

    json[:errors]= @errors
    render :json => json
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

  def get_protocol
    advance   = Advance.find(params[:id])
    staff_id  = params[:staff_id]
    filename  = "#{Settings.sapos_route}/private/files/students/#{advance.student.id}"
    if advance.advance_type.eql? 2
      pdf_route = "#{filename}/protocol-#{advance.id}-#{staff_id}.pdf"
    elsif advance.advance_type.eql? 3
      pdf_route = "#{filename}/seminar-#{advance.id}-#{staff_id}.pdf"
    end
    send_file pdf_route, :x_sendfile=>true
  end
end
