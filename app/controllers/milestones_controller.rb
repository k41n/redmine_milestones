class MilestonesController < ApplicationController
  unloadable

  before_filter :find_project, :only => [:index, :new, :create]

  def new
    @milestone = Milestone.new
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
private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end



end
