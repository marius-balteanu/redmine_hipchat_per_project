module RedmineHipchatPerProject
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method :project_settings_tabs_without_hipchat, :project_settings_tabs
          alias_method :project_settings_tabs, :project_settings_tabs_with_hipchat
        end
      end

      module InstanceMethods
        def project_settings_tabs_with_hipchat
          tabs = project_settings_tabs_without_hipchat
          return tabs unless @project.module_enabled? :hipchat

          tabs.push({
            action:     'index',
            controller: 'hipchat',
            label:      :hipchat_settings_header,
            name:       'hipchat',
            partial:    'hipchat/project_settings'
          })
        end
      end
    end
  end
end

base  = ProjectsHelper
patch = RedmineHipchatPerProject::Patches::ProjectsHelperPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
