# Prevent load-order problems in case openproject-plugins is listed after a plugin in the Gemfile
# or not at all
require 'active_support/dependencies'
require 'open_project/plugins'

module OpenProject::ProtoPlugin
  class Engine < ::Rails::Engine
    engine_name :openproject_proto_plugin

    include OpenProject::Plugins::ActsAsOpEngine

    register(
      'openproject-proto_plugin',
      :author_url => 'https://openproject.org',
      :requires_openproject => '>= 13.1.0'
    ) do
      # We define a new project module here for our controller including a permission.
      # The permission is necessary for us to be able to add menu items to the project
      # menu. You will not need to add a permission for adding menu items to the `top_menu`
      # or `admin_menu`, however.
      #
      # You may have to enable the project module ("Kittens module") under project
      # settings before you can see the menu entry.
      project_module :kittens_module do
        permission :view_kittens,
                   {
                      kittens: %i[index],
                      angular_kittens: %i[show]
                   },
                   permissible_on: [:project]

        permission :manage_kittens,
                   {
                      kittens: %i[new create edit destroy],
                      angular_kittens: %i[show]
                   },
                   permissible_on: [:project]
      end

      menu :project_menu,
           :kittens,
           { controller: '/kittens', action: 'index' },
           after: :overview,
           param: :project_id,
           caption: "Roadmap",
           icon: :squirrel,
           html: { id: "kittens-menu-item" },
           if: ->(project) { true }

      menu :top_menu,
           :angular_kittens,
           '/angular_kittens',
           after: :kittens,
           param: :project_id,
           caption: "Roadmap Frontend"
    end

    config.to_prepare do
      ::OpenProject::ProtoPlugin::Hooks
    end

    config.after_initialize do
      OpenProject::Static::Homescreen.manage :blocks do |blocks|
        blocks.push(
          { partial: 'homescreen_block', if: Proc.new { true } }
        )
      end
    end

    config.after_initialize do
      OpenProject::Notifications.subscribe 'user_invited' do |token|
        user = token.user

        Rails.logger.debug "#{user.mail} invited to OpenProject"
      end
    end

    assets %w(kitty.png)
  end
end
