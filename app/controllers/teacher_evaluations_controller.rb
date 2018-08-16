
class TeacherEvaluationsController < ApplicationController
  before_filter :auth_required
  before_filter :only => [:index] do |c| c.news 2 end
  before_filter :only => [:show,:new,:create] do |c| c.news 1 end

  respond_to :html, :xml, :json

  def index

  end

  def show
    
  end

  def new
    @this_tcs = TermCourseSchedule.where(:id=>params[:tcs_id])
  end

  def create
    @teacher_evaluation = TeacherEvaluation.new(params[:teacher_evaluation])
    if @teacher_evaluation.save
      ste = StudentTeacherEvaluation.new
      ste.staff_id= @teacher_evaluation.staff_id
      ste.term_course_id = @teacher_evaluation.term_course_id
      ste.student_id = current_user.id
      ste.save
      redirect_to :action=>:index
    end
  end
end
