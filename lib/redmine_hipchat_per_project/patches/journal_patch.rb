module RedmineHipchatPerProject
  module Patches
    module JournalPatch
      include HipchatNotifier

      def self.included(base)
        base.class_eval do
          after_create :send_hipchat

          def send_hipchat
            return unless self.journalized_type.to_s == 'Issue'
            send_issue_updated_to_hipchat self
          end
        end
      end
    end
  end
end

base = Journal
new_module = RedmineHipchatPerProject::Patches::JournalPatch
base.send :include, new_module unless base.included_modules.include? new_module
