class Neuroprok::ProjectsController < NeuroprokController
  before_action :set_repo, only: [:show, :destroy]
  before_action :check_repo, only: :show

  def index
    @repos = current_user.github.repos.select { |a| a.permissions.admin }
    @selected = current_user.repos
  end

  def create
    @repo = current_user.repos.build(name: params[:id])
    @repo.save ? @repo.init_learn : @errors = @repo.errors
    render :create
  end

  def show
    @neuro = @repo.neuro
  end

  def destroy
    @repo.destroy
    redirect_to projects_path
  end

  private

  def set_repo
    @repo = current_user.repos.find_by(name: params[:id])
  end

  def check_repo
    send :create unless current_user.repos.any? { |repo| repo.name == params[:id] }
  end
end
