# OpenProject Prototype Plugin

In this plugin we try to give you an idea on how to write an OpenProject plugin. Examples of doing the most common things a plugin may want to do are included.

To get started quickly you may just copy this plugin, remove the bits you don't need and modify/add the features you want.


## Pre-requisites

In order to be able to continue, you will first have to have a working OpenProject core development environment. Please follow these guides to set that up:

* [Development environment Ubuntu/Debian](https://www.openproject.org/docs/development/development-environment-ubuntu/)
* [Development environment Mac OS X](https://www.openproject.org/docs/development/development-environment-osx/)
* [Development environment Docker](https://www.openproject.org/docs/development/development-environment-docker/)

We are assuming that you understand how to develop Ruby on Rails applications and are familiar with controllers, views, asset management, hooks and engines.

To get started with a development environment of the OpenProject core, we recommend you follow our development guides at https://docs.openproject.org/development/ as well as the [guide for plugin development](https://www.openproject.org/docs/development/create-openproject-plugin).

The frontend can be written using plain-vanilla JavaScript, but if you choose to integrate directly with the OpenProject frontend then you will have to understand the Angular framework.


## Getting started

To include this plugin, you need to create a file called `Gemfile.plugins` in your OpenProject core directory with the following contents:

```
group :opf_plugins do
  gem "openproject-roadmap_plugin", git: "https://github.com/opf/openproject-roadmap_plugin.git", branch: "dev"
end
```

As you may want to play around with and modify the plugin locally, you may want to check it out first and use the following instead to reference a local path:

```
group :opf_plugins do
  gem "openproject-roadmap_plugin", path: "/path/to/openproject-roadmap_plugin"
end
```

If you already have a `Gemfile.plugins` just add the line "gem" line to it inside the `:opf_plugins` group.

Once you've done that, **switch to the OpenProject core directory** and run:

```bash
./bin/setup_dev
```

While you're in the root of the OpenProject core, we recommend you export the OpenProject core path as `$OPENPROJECT_ROOT`.

```bash
export OPENPROJECT_ROOT=$(pwd)
```

This will make the plugin known to the OpenProject core with bundler and optionally link a frontend directory into the core (more on that later).

Optionally, you might want to run plugin seeds, if there are any:

```bash
bundle exec rails db:seed # creates default data from the plugin's seeder (`app/seeders`)
```

You can then start the core server as described in the above guides. For example, you can then start the rails server with:

```bash
RAILS_ENV=development ./bin/rails server
```

As well as the Angular CLI in development mode with:

```bash
RAILS_ENV=development npm run serve
```

In order to verify that the plugin has been installed correctly, go to the Administration Plugins Page at http://localhost:3000/admin/plugins and you should be able to find your plugin in the list.

![](images/admin-plugins-page.png?raw=true)

In the following sections we will explain some common features that you may want to use in your own plugin. This plugin has already been setup with the basic framework to illustrate all these features.

Each section will list the relevant files you may want to look at and explain the features. Beyond that there are also code comments in the respective files which provide further details.

### Frontend linking
This proto plugin contains an Angular frontend part. The way the Angular CLI works, it needs to build the project from a common root folder. That is located at `$OPENPROJECT_ROOT/frontend`.

To make your plugin's frontend available to the OpenProject core, it is being symlinked into `$OPENPROJECT_CORE/frontend/src/app/features/plugins/linked/your-plugin-name`. This is being done by the `bin/setup_dev` script, which needs to run whenever you add or remove a plugin from your Gemfile.

Working with this symlinked frontend is a bit tricky. What we recommend is that you develop your Ruby backend in the plugin folder, while you develop the Angular frontend in the OpenProject core. This way, you will get all benefits from the CLI and language services such as auto-completion, angular generations, correct paths being looked up by Typescript, etc.

JS files in `/frontend` import other modules in the core app with the `core-app/` prefix which is an alias pointing to `<core-app-root>/frontend/src/app` defined in the `tsconfig.base.json` file, be careful to update import path when configurations change. You will get error outputs from your angular CLI however.

### Rails generators

The plugin comes with an executable `bin/rails` which you can use when calling rails generators for generating everything. You will have to define `OPENPROJECT_ROOT` in your environment for it to work unfortunately, because the plugin requires the core to load.

By `core` we mean the directory under which you originally checked out the OpenProject repository:

```
$ git clone https://github.com/opf/openproject.git ~/dev/openproject/core
$ git checkout dev
```

So for example, should the core be located under under `~/dev/openproject/core` you can set it like this, for instance in your `.bashrc`:

```
export OPENPROJECT_ROOT=~/dev/openproject/core
```

or you can just prepend the relevant rails commands like this:

```
$ OPENPROJECT_ROOT=~/dev/openproject/core rails generate ...
```

Once you've set that up you can use the rails generators as usual.

For instance this is how you could **generate a model**:

```
$ bundle exec rails generate model Kitten name:string --no-test-framework
      invoke  active_record
      create    db/migrate/20170116125942_create_kittens.rb
      create    app/models/kitten.rb
```

Finally, don't forget to run the migration from the core directory. Please note that you cannot run `db:migrate` or other commands with rails from the engine. You'll have to execute those from the core.

```
$ cd $OPENPROJECT_ROOT
$ bundle exec rails db:migrate
```

Now let's double-check that our Kittens table as been seeded:

```
$ rails c
...
[1] pry(main)> Kitten.pluck(:name)
   (0.3ms)  SELECT `kittens`.`name` FROM `kittens`
=> ["Klaus", "Herbert", "Felix"]
```

Make sure that the application is running (`bundle exec rails s`) and go to `http://localhost:3000/kittens`. You should see something like this:

![](images/kittens-main-page.png?raw=true)

Great, we're on our way.



### Specs

The relevant files for the specs are:

* `spec/controllers/kittens_controller_spec.rb`

You have to run the specs from within the core. For instance:

```
$ cd $OPENPROJECT_ROOT
$ RAILS_ENV=test bundle exec rspec `bundle show openproject-roadmap_plugin`/spec/controllers/kittens_controller_spec.rb
```



## Seeders

The relevant files for the seeders are:

* `app/seeders/kittens_seeder.rb` - Creates example records.

You can define so called "Seeders" for your plugin which get called when `rake db:seed` is run in the core. For example:

```
$ cd OPENPROJECT_ROOT
$ bundle exec rails db:seed
```

The plugin defines a `KittenSeeder` which creates a few example rows to be displayed in the `KittensController`.

A plugin's seeders have to be defined under its namespace within the `BasicData` module, for instance `BasicData::RoadmapPlugin::KittensSeeder`.
They will be discovered and invoked by the core automatically.



## Models

The relevant files for the models are:

* `app/models/kitten.rb` - the code for the model where you can add validations etc.
* `app/models/application_record.rb` - auto-generated base record
* `db/migrate/20170116125942_create_kittens.rb` - database migration

The models work as usual in Rails applications. For the sake of completeness, the model validates the name attribute:

```ruby
class Kitten < ApplicationRecord
  validates :name, uniqueness: true, length: { minimum: 5 }
end
```



## Controllers

The relevant files for the controllers are:

* `app/controllers/kittens_controller.rb` - main controller with `:index` entry point
* `app/views/kittens/index.html.erb` - main template for kittens index view

The controllers work as expected for Rails applications. In preparation for the following example, we create a basic minimal controller which only supports creation of new kittens:

```ruby
class KittensController < ApplicationController
  def index
    @kittens = Kitten.all
    render layout: true
  end

  def new
    @kitten = Kitten.new
  end

  def create
    @kitten = Kitten.new(kitten_params)
    ...
  end

  private

  def kitten_params
    params.require(:kitten).permit(:name)
  end
end
```



## Create kitten example

As a simple example, let's enable the create kitten button on the kittens homepage block so that it brings the user to a create kitten page. It's already linked to `new_kitten_path` so all we need to do now with the controller already in place is to create `views/kittens/new.html.erb` template:

```
<h1><%= t(:label_kitten_new) %></h1>

<%= render "form", kitten: @kitten %>
```

The partial `views/kittens/_form,html.erb` is a basic form for inputting the name:

```
<%= form_for(kitten) do |f| %>

    <p>
      <%= f.label :name %>
      <%= f.text_field :name %>
    </p>

    <%= f.submit %>

<% end %>
```

which should end up looking something like this.

![](images/create-new-kitten.png?raw=true)

We leave it up as an exercise for the reader to complete the CRUD with edit and delete actions. Good luck!



## I18n

OpenProject uses Rails I18n helpers as well as `I18n-js` to provide translations for the backend and frontend.

You can add your strings to `config/locales/en.yml` and `config/locales/js-en.yml` for backend and frontend translations, respectively.

The translations can then be called with:

- `I18n.t('your_namespace.your_key')` and
- `I18n.t('js.your_js_translation_key')`



## Static assets

The relevant files for the assets are:

* `lib/open_project/roadmap_plugin/engine.rb` - assets statement at the end of the engine.
* `app/assets/javascripts/roadmap_plugin/main.js` - main entry point for plain JavaScript and document ready hook.
* `app/assets/stylesheets/roadmap_plugin/main.scss` - good ol' Sass stuff.
* `app/assets/images/kitty.png` - a nice kitty image.

Any additional assets you want to use have to be registered for pre-compilation in the engine like this:

```
assets %w(kitty.png)
```

You don't technically have to put the assets into a subfolder with the same name as your plugin. But it's highly recommended to do so in order to avoid naming conflicts. For example, if the image `kitty.png` is not scoped, it might conflict with the core if it were also to include another asset named `kitty.png` too.

Please note that OpenProject no longer uses the Rails asset pipeline for JavaScript and CSS. While you could still serve both through the asset pipeline, they are not being transformed anymore (SCSS to CSS, JS minification, etc.). For those, use the Angular frontend module instead.

## Angular frontend

The plugin can create its own Angular module and also hook into parts of the core frontend. The relevant files for the frontend are:

* `frontend/app/module/main.ts`


This file defines the Angular module for this plugin that gets linked into core `frontend/app/src/modules/plugins/linked`

Any changes made to the frontend require running Angular CLI to update. To do that go to the OpenProject folder (NOT the plugin directory) and execute the following command with the plugin contained in the Gemfile.plugins.

```bash
$ ./bin/setup_dev
$ npm run serve
```

This will compile and output all changes on the fly as you change it using the Angular CLI.

### Global SASS styles

With the Angular frontend, you have the option to generate component-based styles (for example, `kitten.component.sass`) which will be available only within that component using Angular style isolation.

If you want to define global styles or override core styles, you can create or extend the file `frontend/module/global_styles.scss` for styles that will be applied locally.



### Reloading the application in development

For the backend part, Rails will autoload and reload dependencies in all `app/` folders. If you change something in your plugin under `lib/` , especially changes to the engine.rb, menu system, or plugin registration, you will probably have to restart your Rails server.

For the frontend part, automatic reloading is automatically active when you run `npm run serve` using a file watcher. If you don't see changes in your files resulting in a new compilation cycle, please ensure you're working within the linked core, as that will ensure that the symlink is modified.



## Menu Items

The relevant files for the menu items are:

* `lib/open_project/roadmap_plugin/engine.rb` - register block in the beginning
* `app/controllers/kittens_controller.rb`

Registering new user-defined menu items is easy. For instance, let's assume that you want to add a new item to the project menu. Just add the following to the `engine.rb` file:

```ruby
menu :project_menu, # Which menu to add an item to (compare the core config/initializers/menus.rb for options)
     :kittens, # The name of the new item to add
     { controller: '/kittens', action: 'index' }, # The Rails route definition or path to define
     after: :overview, # use before: or after: to move the menu item next to an existing definition
     param: :project_id, # Leave it at :project_id if you're adding a project menu item
     caption: :"roadmap_plugin_name", # The caption, use a symbol for I18n lookup, or a string for plain text
     icon: 'icon2 icon-bug', # The icon classes to add, see http://localhost:3000/styleguide for options
     html: { id: "kittens-menu-item" }, # Additional Rails tag_helper html to add
     if: ->(project) { true } # A condition, such as permissions when to show the menu
```

You are then free to enable the "Kittens module" for a given project by going to that "Project settings" page, for example `/projects/demo-project/settings/modules` and checking the checkbox.



![](images/enable-kittens-module.png?raw=true)

The menu item will now appear on the top level project page as well as all sub-levels `/projects/demo-project/*`.

![](images/kittens-menu-item.png?raw=true)

You can add nested menu items by passing a `parent` option to the following items. For instance you could add a child menu item to the menu item shown above by adding `parent: :kittens` as another option.

There are a number of menus available from which to choose:

* top_menu
* account_menu
* application_menu
* my_menu
* admin_menu
* project_menu


## Homescreen Blocks

By default the homepage contains a number of blocks (widget boxes), namely: "Projects", "Users", "My account", "OpenProject community" and "Administration".

You can easily add your own user-defined block so that it will also appears on the homepage.

The relevant files for homescreen blocks are:

* `lib/open_project/roadmap_plugin/engine.rb` - `roadmap_plugin.homescreen_blocks` initializer
* `app/views/homescreen/blocks/_homescreen_block.html.erb`

In the file `engine.rb` you can register additional blocks in OpenProject's homescreen like this:

```
initializer 'roadmap_plugin.homescreen_blocks' do
  OpenProject::Static::Homescreen.manage :blocks do |blocks|
    blocks.push(
      { partial: 'homescreen_block', if: Proc.new { true } }
    )
  end
end
```

Where the `if` option is optional.

The partial file `_homescreen_block.html.erb` provides the template from which the contents of the block will be generated. Have a look at this file to get a better idea of the possibilities.

This is what you should now see on the homepage:

![](images/kitten-homescreen-block.png?raw=true)


## OpenProject::Notification listeners

The relevant files for notification listeners are:

* `lib/open_project/roadmap_plugin/engine.rb` - `roadmap_plugin.notifications` initializer

Although OpenProject has inherited hooks (see next section) from Redmine, it also employs its own mechanism for simple event callbacks. Their return values are ignored.

For example, you can be notified whenever a user has been invited to OpenProject by subscribing to the `user_invited` event. Add the following to the `engine.rb` file:

```
initializer 'roadmap_plugin.notifications' do
  OpenProject::Notifications.subscribe 'user_invited' do |token|
    user = token.user

    Rails.logger.debug "#{user.email} invited to OpenProject"
  end
end
```


### Events

Currently the supported events (_block parameters in parenthesis_) to which you can subscribe are:

* user_invited (token)
* user_reinvited (token)
* project_updated (project)
* project_renamed (project)
* project_deletion_imminent (project)
* member_updated (member)
* member_removed (member)
* journal_created (payload)
* watcher_added (payload)


### Setting Events

Whenever a given setting changes, an event is triggered passing the previous and new values. For instance:

* `setting.host_name.changed` (value, old_value)

Where `host_name` is the name of the setting. You can find out all setting names simply by inspecting the relevant setting input field in the admin area in your browser or by listing them all on the rails console through `Setting.pluck(:name)`. Also have a look at `config/settings.yml` where all the default values for settings are defined by their name.


## Hooks

The relevant files for hooks are:

* `lib/open_project/engine.rb` - `roadmap_plugin.register_hooks` initializer
* `lib/open_project/hooks.rb`
* `app/views/hooks/roadmap_plugin/_homescreen_after_links.html.erb`
* `app/views/hooks/roadmap_plugin/_view_layouts_base_sidebar.html.erb`

Hooks can be used to extend views, controllers and models at certain predefined places. Each hook has a name for which a method has to be defined in your hook class, see `lib/open_project/roadmap_plugin/hooks.rb` for more details.

For example:

```
render_on :homescreen_after_links, partial: '/hooks/homescreen_after_links'
```

By using `render_on`, the given variables are made available as locals to the partial for that defined hook. Otherwise they will be available through the defined hook method's first and only parameter named `context`.

Additionally the following context information is put into context if available:

* project - current project
* request - Request instance
* controller - current Controller instance
* hook_caller - object that called the hook


### View Hooks

_Note: context variables placed within (parenthesis)_

Hooks in the base template:

* :view_layouts_base_html_head
* :view_layouts_base_sidebar
* :view_layouts_base_breadcrumb
* :view_layouts_base_content
* :view_layouts_base_body_bottom

More hooks:

* :view_account_login_auth_provider
* :view_account_login_top
* :view_account_login_bottom
* :view_account_register_after_basic_information (f) - f being a form helper
* :activity_index_head
* :view_admin_info_top
* :view_admin_info_bottom
* :view_common_error_details (params, project)
* :homescreen_administration_links
* :view_work_package_overview_attributes

Custom field form hooks:

* :view_custom_fields_form_upper_box (custom_field, form)
* :view_custom_fields_form_work_package_custom_field (custom_field, form)
* :view_custom_fields_form_user_custom_field (custom_field, form)
* :view_custom_fields_form_group_custom_field (custom_field, form)
* :view_custom_fields_form_project_custom_field (custom_field, form)
* :view_custom_fields_form_time_entry_activity_custom_field (custom_field, form)
* :view_custom_fields_form_version_custom_field (custom_field, form)
* :view_custom_fields_form_issue_priority_custom_field (custom_field, form)


### Controller Hooks

_Note: context variables placed within (parenthesis)_

* :controller_account_success_authentication_after (user)
* :controller_custom_fields_new_after_save (custom_field)
* :controller_custom_fields_edit_after_save (custom_field)
* :controller_messages_new_after_save (params, message)
* :controller_messages_reply_after_save (params, message)
* :controller_timelog_available_criterias (available_criterias, project)
* :controller_timelog_time_report_joins (sql)
* :controller_timelog_edit_before_save (params, time_entry)
* :controller_wiki_edit_after_save (params, page)
* :controller_work_packages_bulk_edit_before_save (params, work_package)
* :controller_work_packages_move_before_save (params, work_package, target_project, copy)


### More Hooks

_Note: context variables placed within (parenthesis)_

* :model_changeset_scan_commit_for_issue_ids_pre_issue_update (changeset, issue)
* :copy_project_add_member (new_member, member)
