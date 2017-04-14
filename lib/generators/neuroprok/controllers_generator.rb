require 'rails/generators/base'

module Neuroprok
  module Generators
    class ControllerGenerator < Rails::Generators::Base
      CONTROLLERS = %w(learn projects).freeze

      desc <<-DESC.strip_heredoc
        Create inherited Neuroprok controllers in your app/controllers folder.
        Use -c to specify which controller you want to overwrite.
        If you do no specify a controller, all controllers will be created.
        For example:
          rails generate neuroprok:controllers users -c=projects
        This will create a controller class at app/controllers/users/projects_controller.rb like this:
          class Users::ProjectsController < Neuroprok::ProkectsController
            content...
          end
      DESC

      source_root File.expand_path("../../templates/controllers", __FILE__)
      argument :scope, required: true,
        desc: "The scope to create controllers in, e.g. users, admins"
      class_option :controllers, aliases: "-c", type: :array,
        desc: "Select specific controllers to generate (#{CONTROLLERS.join(', ')})"

      def create_controllers
        @scope_prefix = scope.blank? ? '' : (scope.camelize + '::')
        controllers = options[:controllers] || CONTROLLERS
        controllers.each do |name|
          template "#{name}_controller.rb",
                   "app/controllers/#{scope}/#{name}_controller.rb"
        end
      end

      def show_readme
        readme "README" if behavior == :invoke
      end

    end
  end
end
