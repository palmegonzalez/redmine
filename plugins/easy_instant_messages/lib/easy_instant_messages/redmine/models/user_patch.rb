module EasyInstantMessages
  module UserPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do

        has_many :send_easy_instant_messages, :foreign_key => 'sender_id', :class_name => 'EasyInstantMessage', :dependent => :destroy
        has_many :recieve_easy_instant_messages, :foreign_key => 'recipient_id', :class_name => 'EasyInstantMessage', :dependent => :destroy

      end
    end

    module InstanceMethods
      def is_online?
        last_seen_at > 5.minutes.ago unless last_seen_at.nil?
      end
    end

    module ClassMethods

    end

  end

end
RedmineExtensions::PatchManager.register_model_patch 'User', 'EasyInstantMessages::UserPatch'
