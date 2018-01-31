
class TeacherEvaluationsController < ApplicationController
  before_filter :auth_required
  before_filter :news

  $YEAR = "2017-2"
  
  respond_to :html, :xml, :json

  def index

  end

  def show
    redirect_to :action=>:new, :tcs_id=>params[:id]
  end

  def new
    @this_tcs = TermCourseStudent.joins(:term_student).where(:id=>params[:tcs_id],:term_students=>{:student_id=>current_user.id})
  end

  def create
    @teacher_evaluation = TeacherEvaluation.new(params[:teacher_evaluation])
    #@this_tcs = TermCourseStudent.joins(:term_student).where(:id=>params[:tcs_id],:term_students=>{:student_id=>current_user.id})

    if @teacher_evaluation.save
      my_tcs = TermCourseStudent.find(params[:tcs_id])
      my_tcs.teacher_evaluation = true
      my_tcs.save

      redirect_to :action=>:index
    end
  end
end
