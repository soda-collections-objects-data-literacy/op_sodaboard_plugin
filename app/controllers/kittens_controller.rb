class KittensController < ApplicationController
  # Check for the permissions of the user
  # as defined in the engine.rb permissions block
  before_action :find_project_by_project_id
  before_action :authorize

  def index
    @kittens = []#Kitten.all
    cat_event = @project.categories.find_by name: "Event"
    cat_contrib = @project.categories.find_by name: "Beitrag zu Veranstaltung (extern)"
    @wps = @project.work_packages.where(category_id: [cat_event.id,cat_contrib.id]).order(:subject)#.where(is_closed: false,)
    @roadmap_hashes = []
    
    start_date = Date.new(2025, 1, 1)
    end_date = Date.new(2026, 12, 1)
    
    number_of_months = (end_date.year*12+end_date.month)-(start_date.year*12+start_date.month)
    
    (0..number_of_months).each do |month|
      m_date = start_date + month.months
      m_hash = {
        label: m_date.strftime("%b %Y"),
        workshops: [],
        forum: [],
        sonst_event: [],
        contrib_extern: [],
        
      }
      @roadmap_hashes << m_hash
    end
    @table_rows = [:workshops,:forum,:sonst_event,:contrib_extern]

    render layout: true
  end

  def new
    @kitten = Kitten.new
  end

  def create
    @kitten = Kitten.new(kitten_params)
    if @kitten.save
      # notify_changed_kittens(:created, @kitten)
      flash[:notice] = 'Created new kitten'
      redirect_to action: 'index'
    else
      flash[:error] = 'Cannot create new kitten'
      render action: 'new'
    end
  end

  private

  def kitten_params
    params.require(:kitten).permit(:name)
  end

  # def notify_changed_kittens(action, changed_kitten)
  #   OpenProject::Notifications.send(:kittens_changed, action: action, kitten: changed_kitten)
  # end
end
