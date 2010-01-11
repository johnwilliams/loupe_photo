class RolesController < ApplicationController

  require_role "admin"
  
  def new
    @role = Role.new
  end
  
  def index
    @user = User.find(params[:user_id])
    @all_roles = Role.find(:all)
  end

  def create
    @role = Role.new(params[:role])

    if @role.save
      flash[:notice] = 'Role was successfully created.'
      redirect_to users_path
    else
      render :action => "new"
    end
  end
 
  def update
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    unless @user.roles.include?(@role)
      @user.roles << @role
    end
    redirect_to :controller => 'users'
  end
  
  def destroy
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    if @user.roles.include?(@role)
      @user.roles.delete(@role)
    end
    redirect_to :controller => 'users'
  end
  
end