require 'pp'

class AssignmentsApp < Sinatra::Base
  register WillPaginate::Sinatra

  set :cache, Dalli::Client.new
  set :enable_cache, true
  set :views, Proc.new { File.join(root, "views") }
  set :erb, layout: :'../../views/layout'
  set :logging, true

  before do
    env['warden'].authenticate!
  end

  # index
  get '/?' do
    @sections = env['warden'].user.sections
    @assignments = @sections.assignments.all(order: :created_at.desc)
    erb :index
  end

  # show
  get '/:year/:id/?' do
    @assignment = Assignment.first(params[:id])
    erb :show
  end

  #############################################################################
  #
  # ADVISOR ROUTES
  #
  #############################################################################

  # edit
  get '/:year/:id/edit/?' do
    require_admin
    @sections = Section.all
    @assignment = Assignment.first(params[:id])
    erb :edit
  end

  # new
  get '/new/?' do
    require_admin
    @assignment = Assignment.new
    @sections = Section.all

    erb :new
  end

  # create
  post '/new' do
    require_admin

    @assignment = Assignment.new(params[:assignment])
    @assignment.user_id = env['warden'].user.id

    if @assignment.save
      flash.success = "Assignment saved successfully."
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}"
    else
      pp @assignment
      flash.error = "We've encountered a problem."
      redirect "/assignments/new"
    end
  end


  # update
  post '/:year/:id/update' do
    require_admin
    @assignment = Assignment.first(params[:id])

    if @assignment.update(params[:assignment])
      flash.success = "Assignment updated successfully"
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}"
    else
      flash.error "We had a problem"
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}/edit"
    end
  end

  # delete
  post '/:year/:id/destroy' do
    require_admin
    @assignment = Assignment.first(params[:id])

    if @assignment.destroy
      flash.success = "Assignment destroyed"
      redirect "/assignments"
    else
      flash.error = "Assignment could not be destroyed"
      redirect "/assignments/#{@assignment.year}/#{@assignment.id}"
    end
  end
end