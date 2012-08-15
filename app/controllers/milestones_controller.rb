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

  def update_settings
    @project = Project.find(params[:project_id])
    @default_show_milestones = MilestonesSettings.find_by_key_and_project_id("default_show_milestones", @project.id)
    if params[:default_show_milestones]
      @default_show_milestones.update_attribute(:value, "true")
    else
      @default_show_milestones.update_attribute(:value, "false")
    end
    @default_show_closed_milestones = MilestonesSettings.find_by_key_and_project_id("default_show_closed_milestones", @project.id)
    if params[:default_show_closed_milestones]
      @default_show_closed_milestones.update_attribute(:value, "true")
    else
      @default_show_closed_milestones.update_attribute(:value, "false")
    end
    @default_show_sub_milestones = MilestonesSettings.find_by_key_and_project_id("default_show_sub_milestones", @project.id)
    if params[:default_show_sub_milestones]
      @default_show_sub_milestones.update_attribute(:value, "true")
    else
      @default_show_sub_milestones.update_attribute(:value, "false")
    end
    redirect_to :controller => 'projects', :action => 'settings', :tab => 'milestones', :id => @project
  end

  def update
    @milestone = Milestone.find(params[:id])
    params[:milestone][:observers] ||= []
    if params[:milestone].present? and params[:milestone][:assigned_milestones].nil?
      params[:milestone][:assigned_milestones] = []
    end
    @project = @milestone.project
    if params[:milestone]
      attributes = params[:milestone].dup
      attributes.delete('sharing') unless attributes.nil? || @milestone.allowed_sharings.include?(attributes['sharing'])
      @milestone.safe_attributes = attributes
    end
    if @milestone.save
      flash[:notice] = l(:notice_successful_update)
      if params[:back_url]
        uri = URI.parse(CGI.unescape(params[:back_url].to_s))
        if /\/projects\/[^\/]+\/settings/.match uri.path
          redirect_to :controller => 'projects', :action => 'settings', :tab => 'milestones', :id => @project
        else
          redirect_back_or_default(nil)
        end
      else
        redirect_to :controller => 'projects', :action => 'settings', :tab => 'milestones', :id => @project
      end
    else
      render :action => :edit
    end
  end

  def destroy
    @milestone = Milestone.find(params[:id])
    @milestone.destroy
    if request.xhr?
    else
      if params[:back_url]
        redirect_to params[:back_url]
      else
        redirect_to settings_project_path(@milestone.project, :tab => :milestones)
      end
    end
  end

  def create
    params[:milestone][:observers] ||= []
    @milestone = Milestone.new(:project => @project)
    if params[:milestone]
      attributes = params[:milestone].dup
      attributes.delete('sharing') unless attributes.nil? || @milestone.allowed_sharings.include?(attributes['sharing'])
      @milestone.safe_attributes = attributes
    end

    if request.post?
      if @milestone.save
        flash[:notice] = l(:notice_successful_create)
        if params[:back_url]
          uri = URI.parse(CGI.unescape(params[:back_url].to_s))
          if /\/projects\/[^\/]+\/settings/.match uri.path
            redirect_to :controller => 'projects', :action => 'settings', :tab => 'milestones', :id => @project
          else
            redirect_back_or_default(nil)
          end
        else
          redirect_to :controller => 'projects', :action => 'settings', :tab => 'milestones', :id => @project
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
    @calculated_date = @reference_milestone.start_date.present? ? params[:offset].to_i.days.since(@reference_milestone.start_date) : nil
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

  def issue_version_changed
    @project = Project.find(params[:project_id])
    @version = Version.find(params[:id])
    @milestones = @version.milestones + @project.milestones.versionless
  rescue
    @milestones = @project.milestones.versionless
  end

  def milestone_version_changed
    @project = Project.find(params[:project_id])
    @version = Version.find(params[:id]) unless params[:id].to_i.zero? or params[:id].nil?
  end

  def report_for_version
    @version = Version.find(params[:version_id])
    @project = @version.project
    @data = {}
    @data["percentage"] = @version.milestones.collect{|x| x.completed_pourcent}
    @data["legend"] = @version.milestones.collect{|x| "%%.%% #{x.name}"}
    @data["href"] = @version.milestones.collect{|x| milestone_path(x)}
  end

  def report
    @milestone = Milestone.find(params[:id])
    @project = @milestone.project
    @data = {}
    @data["percentage"] = @milestone.children.collect{|x| x.completed_pourcent}
    @data["legend"] = @milestone.children.collect{|x| "%%.%% #{x.name}"}
    @data["href"] = @milestone.children.collect{|x| milestone_path(x)}
  end

  def planned_end_date_changed
    @milestone = Milestone.find(params[:id]) unless params[:id].to_i == -1
    @version = Version.find(params[:version_id])
    @newval = Date.parse(params[:newval])
    @oob_warning = I18n.t(:planned_oob_warning)
    @confirmations = ''
    if @milestone.present?
      @confirmations = @milestone.depending_from_this_start_date.collect do |milestone|
        "Milestone ##{milestone.id} #{milestone.name}, start date will be changed from #{milestone.start_date.strftime('%d-%m-%Y')} to #{milestone.start_date_offset.days.since(@newval).strftime('%d-%m-%Y')}"
      end.join("\n")
      @confirmations += "\n"+@milestone.depending_from_this_planned_end_date.reject{|x| x.planned_end_date_offset.nil?}.collect do |milestone|
        "Milestone ##{milestone.id} #{milestone.name}, planned end date will be changed from #{milestone.planned_end_date.strftime('%d-%m-%Y')} to #{milestone.planned_end_date_offset.days.since(@newval).strftime('%d-%m-%Y')}"
      end.join("\n")
    end
  end

  def start_date_changed
    @milestone = Milestone.find(params[:id]) unless params[:id].nil? or params[:id].to_i == -1
    @version = Version.find(params[:version_id])
    @newval = Date.parse(params[:newval])
    @oob_warning = I18n.t(:start_oob_warning)
  end

  def set_planned_to_actual
    @assigned_milestones = params[:assigned_milestones_ids].split("|").reject{|x| x.empty?}.map{|x| Milestone.find(x)}
    @actual = @assigned_milestones.reject{|x| x.actual_date.nil?}.max{|a,b| a.actual_date <=> b.actual_date}.actual_date unless params[:assigned_milestones_ids].nil? or params[:assigned_milestones_ids].empty?
    if params[:id] != 'undefined'
      @milestone = Milestone.find(params[:id])
      @actual = @milestone.actual_date
    end
  end

  def confirm_delete
    @milestone = Milestone.find(params[:id])
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end



end
