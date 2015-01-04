class Projects::MembersController < Projects::ItemsController

  def index
    @members = @project.project_members.by_name.page(params[:page])
    @member = ProjectMember.new
    add_project_breadcrumb
    add_breadcrumb "Members", :project_members_path
    init_new_options
  end

  def new
    return render_404 unless can?(current_user, :create_project_member, @project)

    add_new_breadcrumb
    init_new_options
    @errors = []
  end

  def create
    return render_404 unless can?(current_user, :create_project_member, @project)

    ids = params['user-search'].split(',').map { |s| s.to_i } 
    @errors = []
    if ids.empty?
      @errors << "You must select at least one user"
    else
      ids.each do |id|
        if @project.users.exists?(id)
          user = User.find(id)
          @errors << "User #{user.name} is already a member of this project" 
        end
      end
    end

    unless can?(current_user, :create_project_member_admin, @project)
      if params[:role] == 'admin'
        @errors << "You are not allowed to give admin role"
      end
    end

    if @errors.any?
      add_new_breadcrumb
      init_new_options
      return render "new" 
    end

    ids.each do |id|
      member = ProjectMember.new
      member.user = User.find(id)
      member.project = @project
      member.role = params[:role]
      member.save
    end
    flash[:notice] = "Members was successfully added"

    redirect_to project_members_path
  end

  def update
    return render_404 unless can?(current_user, :update_project_member, @project)
    member = ProjectMember.find(params[:id])


    project = member.project
    canUpdate = false
    project.project_members.each do |current|
      if current.id != member.id && current.role == "admin"
        canUpdate = true
      end
    end

    if canUpdate
      if member.update_attributes(member_params)
        flash[:notice] = "Member role was successfully updated"
      end
    else
      flash[:alert] = "Member role was not updated. A project must have at least one admin"
    end
    redirect_to project_members_path
  end


  def destroy
    return render_404 unless can?(current_user, :delete_project_member, @project)
    member = ProjectMember.find(params[:id])
    if member.assigned_tasks.count == 0
      if member.destroy
        flash[:notice] = "Member was successfully removed"
      end
    else
      flash[:alert] = "Can't delete member with assigned tasks"
    end
    redirect_to project_members_path
  end

  private

  def init_new_options
    @new_options = [:guest, :developer, :master]
    @new_options << :admin if can?(current_user, :create_project_member_admin, @project)
  end

  def add_new_breadcrumb
    add_project_breadcrumb
    add_breadcrumb "Members", :project_members_path
    add_breadcrumb "New", :new_project_member_path
  end


  def member_params
    params.require(:project_member).permit(:role)
  end
end
