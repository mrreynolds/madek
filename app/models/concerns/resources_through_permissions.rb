module Concerns
  module ResourcesThroughPermissions
    extend ActiveSupport::Concern

    module ClassMethods

      def userpermission_query(user,action)
        Userpermission \
          .where("userpermissions.media_resource_id = media_resources.id") \
          .where(action => true).where(user_id: user)
      end

      def applicationpermission_query(api_application,action)
        API::Applicationpermission \
          .where("applicationpermissions.media_resource_id = media_resources.id") \
          .where(action => true).where(application_id: api_application.id)
      end

      def grouppermission_by_user_query(user,action)
        Grouppermission.joins(group: :users) \
          .where("grouppermissions.media_resource_id = media_resources.id") \
          .where(action => true).where("users.id = ?", user.id)
      end

      def grouppermission_by_group_query(group,action)
        Grouppermission \
          .where("grouppermissions.media_resource_id = media_resources.id") \
          .where(action => true).where(group_id: group)
      end

      def grouppermission_by_group_query_with_permissions(group, permissions)
        Grouppermission \
          .where("grouppermissions.media_resource_id = media_resources.id") \
          .where(:view => permissions[0], :download => permissions[1], \
                 :edit => permissions[2], :manage => permissions[3]) \
          .where(group_id: group)
      end

      def accessible_to_public(action)
          if [:manage, :delete].include?(action.to_sym)
            where('FALSE') 
          else
            where("media_resources.#{action.to_s} = true")
          end
      end

      def accessible_by_user(user,action)
        if user.nil? or user.is_guest?
          accessible_to_public(action)
        elsif user.act_as_uberadmin  
          where("TRUE")
        else
          accessible_by_signedin_user(user,action)
        end
      end

      def accessible_by_api_application(api_application,action)
        where %[ media_resources.#{action.to_s} = true
                 OR
                 EXISTS ( #{applicationpermission_query(api_application,action).select("'true'").to_sql} ) 
              ]

      end

      def accessible_by_signedin_user(user,action)
        case action
        when :transfer, :delete
          where("media_resources.user_id = ?", user.id)
        else
          where %[
                  media_resources.user_id = ?
                  OR
                  media_resources.#{action.to_s} = true
                  OR
                  EXISTS ( #{userpermission_query(user,action).select("'true'").to_sql} ) 
                  OR
                  EXISTS ( #{grouppermission_by_user_query(user,action).select("'true'").to_sql} ) 
                  ], user.id
        end
      end


      def accessible_by_group(group, action)
        where(" EXISTS ( #{grouppermission_by_group_query(group,action).to_sql } ) ")
      end

      def accessible_by_group_with_permissions(group, permissions)
        where(" EXISTS ( #{grouppermission_by_group_query_with_permissions(group, permissions).to_sql } ) ")
      end

      # not the owner but has userpermission or grouppermission
      def entrusted_to_user(user, action)
        where("media_resources.user_id <> ?",user)\
        .where <<-SQL 
                EXISTS ( #{userpermission_query(user,action).select("'true'").to_sql} ) 
                OR
                EXISTS ( #{grouppermission_by_user_query(user,action).select("'true'").to_sql} ) 
                SQL
      end

    end
  end
end
