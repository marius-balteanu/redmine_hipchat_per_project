class HipchatController < ApplicationController
  unloadable

  before_action :find_project, :authorize
  before_action :get_settings, only: :index

  def index; end

  def save
    val = @settings.value ||= {}
    val[@project.id] = { auth_token: params[:settings][:auth_token],
      room_id: params[:settings][:room_id], notify: params[:settings][:notify],
      message_color: params[:settings][:message_color] }
    @settings.update_attribute :value, val
    get_settings
    flash[:notice] = l :notice_successful_update
    redirect_to action: :index
  end

  private

  def find_project
    @project = Project.where(identifier: params[:identifier]).first or
      render_404
    @settings = Setting.where(name: 'plugin_redmine_hipchat_per_project')
      .first_or_initialize(value: {})
  end

  def get_settings
    project_settings = @settings.value[@project.id]
    @auth_token = project_settings ? project_settings[:auth_token] : nil
    @room_id = project_settings ? project_settings[:room_id] : nil
    @notify = project_settings ? project_settings[:notify] : nil
    @selected_color = project_settings ? project_settings[:message_color] : nil
    @colors = [ l(:hipchat_settings_color_yellow),
      l(:hipchat_settings_color_red), l(:hipchat_settings_color_green),
      l(:hipchat_settings_color_purple), l(:hipchat_settings_color_random)]
  end
end
