ActionDispatch::Callbacks.to_prepare do
  paths = '/lib/redmine_hipchat_per_project/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_hipchat_per_project do
  name 'Redmine HipchatPerProject plugin'
  author 'Digital Natives'
  description 'Hipchat notifications for projects'
  version '0.2.0'
  url 'https://github.com/digitalnatives/redmine_hipchat_per_project'

  requires_redmine version_or_higher: '3.1.0'

  project_module :hipchat do
    permission :view_hipchat_settings, { hipchat: :index }
    permission :set_hipchat_settings, { hipchat: :save  }
  end
  settings default: {}
  menu :project_menu, :hipchat, { controller: 'hipchat', action: 'index' },
    caption: 'HipChat Settings', param: :identifier
end
