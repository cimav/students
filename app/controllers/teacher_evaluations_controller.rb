
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
      redirect_to :action=>:index
    end
  end
end
