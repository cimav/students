class HomeController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json


  def index
    @screen="index"
    @student = Student.includes(:program, :thesis, :contact, :scholarship, :advance).find(session[:user_id])

    if !@student.supervisor.nil?
      @asesor   = Staff.find(@student.supervisor).full_name
    end
    
    if !@student.supervisor.nil?
      @coasesor = Staff.find(@student.co_supervisor).full_name 
    end

    today = Date.today
    yyyy  = today.year - @student.start_date.year
    m = today.month - @student.start_date.month
    
    if m > 0
      @year  = yyyy
      @month = m
    else 
      @year  = yyyy - 1
      @month = 12 + m  
    end

    if @year == 1
      @text_year = " ano"
    else
      @text_year = " anos"
    end 
    
    if @month == 1
      @text_month = "mes"
    else  
      @text_month = "meses"
    end
  end

  def services
    @student = Student.includes(:program).find(session[:user_id])
    @screen="services"
  end
end
