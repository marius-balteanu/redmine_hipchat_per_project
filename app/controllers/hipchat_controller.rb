class HipchatController < ApplicationController
  before_action :find_project, :find_settings, :authorize

  def save
    @settings[@project.id] = hipchat_params

    Setting.plugin_redmine_hipchat_per_project = @settings

    flash[:notice] = l(:notice_successful_update)

    redirect_to(
      action:     'settings',
      controller: 'projects',
      id:         params[:id],
      tab:        'hipchat'
    )
  end

  private

  def find_project
    @project = Project.where(identifier: params[:id]).first
    render_404 unless @project
  end

  def find_settings
    @settings = ActionController::Parameters.new(
      Setting.plugin_redmine_hipchat_per_project
    )
  end

  def hipchat_params
    params
      .require(:settings)
      .permit(:auth_token, :room_id, :notify, :message_color)
  end
end
