module HipchatNotifier
  include Redmine::I18n
  include ActionView::Helpers::TagHelper
  include IssuesHelper
  include CustomFieldsHelper

  def send_issue_reported_to_hipchat(issue)
    Rails.logger.info 'Got hipchat issue'
    return unless @settings = get_settings(issue)
    send_message headline_for_issue issue, 'reported'
  end

  def send_issue_updated_to_hipchat(journal)
    issue = journal.issue
    return unless @settings = get_settings(issue)
    # rescue is for link_to(attachment)
    details = journal.details.map do |d|
        show_detail(d) rescue show_detail(d, :no_html)
      end.join('<br />')
    comment = CGI::escapeHTML journal.notes.to_s
    text = headline_for_issue issue, 'updated'
    text += "<br />#{ details }" unless details.blank?
    unless comment.blank?
      text += "<br /><b>Comment</b><i>#{ truncate comment }</i>"
    end
    send_message text
  end

  private

  def send_message(message)
    if @settings[:auth_token].nil? || @settings[:room_id].nil? ||
        @settings[:auth_token].blank? || @settings[:room_id].blank?
      Rails.logger.info 'Unable to send HipChat message : config missing.'
      return
    end
    Rails.logger.info "Sending message to HipChat: #{ message }."
    req = Net::HTTP::Post.new '/v1/rooms/message'
    req.set_form_data auth_token: @settings[:auth_token], from: 'Redmine',
      room_id: @settings[:room_id], message: message,
      notify: @settings[:notify] ? 1 : 0, color: @settings[:message_color]
    req['Content-Type'] = 'application/x-www-form-urlencoded'
    http = Net::HTTP.new 'api.hipchat.com', 443
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    begin
      http.start do |connection|
        connection.request req
      end
    rescue Net::HTTPBadResponse => error
      Rails.logger.error "Error hitting HipChat API: #{ error }"
    end
  end

  def headline_for_issue(issue, mode)
    project = issue.project
    author = CGI::escapeHTML(User.current.name)
    tracker = CGI::escapeHTML(issue.tracker.name.downcase)
    subject = CGI::escapeHTML(issue.subject)
    url = get_url issue
    assigned_to = issue.assigned_to
    assignee = assigned_to ? " assigned to #{ assigned_to.name }" : ''
    "#{ author } #{ mode } #{ project.name } #{ tracker } " <<
      "<a href=\"#{ url }\">##{ issue.id }</a>: #{ subject }#{ assignee }"
  end

  def get_url(object)
    host_name, protocol = Setting[:host_name], Setting[:protocol]
    url_method = if object.is_a? Issue
        :issues_url
      else
        # TODO: figure out what other classes should be supported here
        raise "HipchatNotifier: unsupported url for #{ object.class.name }"
      end
    Rails.application.routes.url_helpers.send url_method, object,
      host: host_name, protocol: protocol
  end

  def get_settings(issue)
    settings = Setting.where(name: 'plugin_redmine_hipchat_per_project')
      .first or return
    settings.value[issue.project_id]
  end

  def truncate(text, length = 20, end_string = '...')
    return unless text
    words = text.split
    words.take(length).join(' ') << (words.size > length ? end_string : '')
  end
end
