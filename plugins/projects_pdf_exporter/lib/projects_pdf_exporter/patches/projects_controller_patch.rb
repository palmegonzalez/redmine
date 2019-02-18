module ProjectsPdfExporter
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          helper Redmine::Export::PDF::ProjectsPdfHelper
          include QueriesHelper

          alias_method_chain :index, :export_to_pdf
        end
      end

      module InstanceMethods
        def index_with_export_to_pdf
          if params[:jump] && redirect_to_menu_item(params[:jump])
            return
          end

          scope = Project.visible.sorted

          respond_to do |format|
            format.html {
              unless params[:closed]
                scope = scope.active
              end
              @projects = scope.to_a
            }
            format.api  {
              @offset, @limit = api_offset_and_limit
              @project_count = scope.count
              @projects = scope.offset(@offset).limit(@limit).to_a
            }
            format.atom {
              projects = scope.reorder(:created_on => :desc).limit(Setting.feeds_limit.to_i).to_a
              render_feed(projects, :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
            }
            format.pdf {
              @projects = scope
              @query = retrieve_query
              send_file_headers! :type => 'application/pdf', :filename => 'projects.pdf'
            }
          end
        end
      end

    end
  end
end


unless ProjectsController.included_modules.include?(ProjectsPdfExporter::Patches::ProjectsControllerPatch)
  ProjectsController.send(:include, ProjectsPdfExporter::Patches::ProjectsControllerPatch  )
end