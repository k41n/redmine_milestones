class MilestonesController < ApplicationController
  unloadable

  before_filter :find_project, :only => [:index, :new, :create]

  def new
    @milestone = Milestone.new
    session[:version_id] = @project.versions.first.id
  end

  def edit
    @milestone = Milestone.find(params[:id])
    @project = @milestone.project
    session[:version_id] = @milestone.version.id if @milestone.version
  end

  def update
    @milestone = Milestone.find(params[:id])
    @project = @milestone.project
    if params[:milestone]
      attributes = params[:milestone].dup
      attributes.delete('sharing') unless attributes.nil? || @milestone.allowed_sharings.include?(attributes['sharing'])
      @milestone.safe_attributes = attributes
    end
    if @milestone.save
      flash[:notice] = l(:notice_successful_create)
      redirect_back_or_default :controller => 'projects', :action => 'settings', :tab => 'versions', :id => @project
    else
      render :action => :edit
    end
  end

  def create
    @milestone = Milestone.new(:project => @project)
    if params[:milestone]
      attributes = params[:milestone].dup
      attributes.delete('sharing') unless attributes.nil? || @milestone.allowed_sharings.include?(attributes['sharing'])
      @milestone.safe_attributes = attributes
    end

    if request.post?
      if @milestone.save
        respond_to do |format|
          format.html do
            flash[:notice] = l(:notice_successful_create)
            redirect_back_or_default :controller => 'projects', :action => 'settings', :tab => 'versions', :id => @project
          end
          format.js do
            render(:update) {|page|
              page << 'hideModal();'
            }
          end
        end
      else
        respond_to do |format|
          format.html { render :action => 'new' }
        end
      end
    end
  end

  def recalculate_planned_end_date
    @reference_milestone = Milestone.find(params[:from])
    @calculated_date = @reference_milestone.planned_end_date.present? ? params[:offset].to_i.days.since(@reference_milestone.planned_end_date) : nil
  end

  def recalculate_start_date
    @reference_milestone = Milestone.find(params[:from])
    @calculated_date = @reference_milestone.planned_end_date.present? ? params[:offset].to_i.days.since(@reference_milestone.planned_end_date) : nil
  end

  def recalculate_actual_date
    @calculated_date = Milestone.find(params[:id]).actual_date
  end

  def parent_project_changed
    @project = Project.find(params[:id])
    session[:version] = @project.versions.first
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def subproject_changed
    @subproject = Project.find(params[:id])
    session[:version] = @subproject.versions.first
  rescue ActiveRecord::RecordNotFound
    @subproject = nil
  end

  def show
    @milestone = Milestone.find(params[:id])
    @issues = @milestone.issues
    @project = @milestone.project
  end

  def status_by
    @milestone = Milestone.find(params[:id])
    @issues = @milestone.issues
    @project = @milestone.project
    render :action => 'show'
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end



end
