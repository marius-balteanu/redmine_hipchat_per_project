module RedmineHipchatPerProject
  module Patches
    module IssuePatch
      include HipchatNotifier

      def self.included(base)
        base.class_eval do
          after_create :send_hipchat

          def send_hipchat
            return unless project.module_enabled? :redmine_hipchat_per_project
            Rails.logger.info 'Sending hipchat'
            send_issue_reported_to_hipchat self
          end
        end
      end
    end
  end
end

base = Issue
new_module = RedmineHipchatPerProject::Patches::IssuePatch
base.send :include, new_module unless base.included_modules.include? new_module
