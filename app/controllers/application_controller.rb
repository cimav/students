class ApplicationController < ActionController::Base
  protect_from_forgery
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  $CICLO  = "2018-1"   #ciclo escolar anterior
  $NCICLO = "2018-2"  #nuevo ciclo

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def authenticated?
    if session[:user_email].blank?
      return false
    end

    if session[:user_auth].blank?
      user = Student.where("(email = ? OR email_cimav = ?) AND status in (1,6)",session[:user_email], session[:user_email]).first
      session[:user_auth] = user && ( user.email == session[:user_email] || user.email_cimav == session[:user_email])
      if session[:user_auth]
        session[:user_id] = user.id
      end
    else
      session[:user_auth]
    end
  end
  helper_method :authenticated?

  def auth_required
    store_location
    redirect_to '/login' unless authenticated?
  end

  helper_method :current_user

  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def news(option)
    @student  = Student.find(current_user.id)
    
    j_hash0   = {:term_course=>:term_course_students}
    joins0    = "INNER JOIN term_students ON term_students.id=term_course_students.term_student_id"
    joins1    = "INNER JOIN courses ON courses.id= term_courses.course_id"
    joins2    = "INNER JOIN terms ON terms.id= term_courses.term_id"
    joins3    = "LEFT JOIN student_teacher_evaluations ON student_teacher_evaluations.staff_id=term_course_schedules.staff_id AND student_teacher_evaluations.term_course_id= term_course_schedules.term_course_id AND student_teacher_evaluations.student_id=term_students.student_id"
    ## juntamos todos los joins con un gsub para no andarnos preocupando por los espacios antes o despues
    j         = joins0.gsub(/^/," ")+joins1.gsub(/^/," ")+joins2.gsub(/^/," ")+joins3.gsub(/^/," ")
    where0    = "term_students.student_id=?"
    where1    = "AND (courses.notes not like '%[AI]%' OR courses.notes is null)"
    where2    = "AND terms.name like '%#{$CICLO}%'"
    where3    = "AND student_teacher_evaluations.id is null"
    ## juntamos todos los where con un gsub para no andarnos preocupando por los espacios antes o despues
    w_all     = where0.gsub(/^/," ")+where1.gsub(/^/," ")+where2.gsub(/^/," ")+where3.gsub(/^/," ")
    values    = current_user.id
  
    if option.eql? 1  ## solo cuenta
      @TCS = TermCourseSchedule.select("distinct term_course_schedules.staff_id").joins(j_hash0).joins(j).where(w_all,values)
    elsif option.eql? 2  ## se trae los datos
      @TCS = TermCourseSchedule.joins(j_hash0).joins(j).where(w_all,values)
    end

    $TEACHER_EVALUATIONS   = @TCS.size
  end

private
  def current_user
    @current_user ||= Student.find(session[:user_id]) if session[:user_id]
  end

end
