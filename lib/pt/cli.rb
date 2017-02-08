require 'yaml'
require 'colored'
require 'highline'
require 'tempfile'
require 'uri'
require 'thor'
module PT
  class CLI < Thor
    include PT::Action
    include PT::Helper
    attr_reader :project

    def initialize(*args)
      super
      @io = HighLine.new
      @global_config = load_global_config
      @local_config = load_local_config
      @client = Client.new(@global_config[:api_number], @local_config)
      @project = @client.project
    end

    %w[unscheduled started finished delivered accepted rejected].each do |state|
      desc "#{state} <owner>", "show all #{state} stories"
      define_method(state.to_sym) do  |owner = nil|
        filter =  "state:#{state}"
        filter << " owner:#{owner}" if owner
        story = select_story_from_paginated_table do |page|
          @client.get_stories(filter: filter, page: page)
        end
        show_story(story)
      end
    end

    %w[show tasks open assign comments label estimate start finish deliver accept reject done].each do |action|
      desc "#{action} [id]", "#{action} story"
      define_method(action.to_sym) do |story_id = nil|
        if story_id
          story = task_by_id_or_pt_id(story_id.to_i)
          unless story
            message("No matches found for '#{story_id}', please use a valid pivotal story Id")
            return
          end
        else
          method_name = "get_stories_to_#{action}"
          story = select_story_from_paginated_table do |page|
            if @client.respond_to?(method_name.to_sym)
              @client.send("get_stories_to_#{action}", page: page)
            else
              @client.get_stories(page: page)
            end
          end
        end
        title("#{action} '#{story.name}'")
        send("#{action}_story", story)
      end
    end

    desc "list [owner]", "list all stories from owner"
    def list(owner = nil)
      if owner
        if owner == "all"
          stories = @client.get_work
          TasksTable.new(stories).print @global_config
        else
          stories = @client.get_my_work(owner)
          TasksTable.new(stories).print @global_config
        end
      else
        members = @client.get_members
        table = MembersTable.new(members)
        user = select("Please select a member to see his tasks.", table).name
        title("Work for #{user} in #{project_to_s}")
        stories = @client.get_my_work(user)
        TasksTable.new(stories).print @global_config
      end
    end

    desc "recent", "show stories you've recently shown or commented on with pt"
    def recent
      title("Your recent stories from #{project_to_s}")
      stories = @project.stories( ids: @local_config[:recent_tasks].join(',') )
      MultiUserTasksTable.new(stories).print @global_config
    end

    desc 'create [title] --owner <owner> --type <type> -m', "create a new story (and include description ala git commit)"
    long_desc <<-LONGDESC
      create story with title [title]

      --owner, -o  set owner

      --type , -t  set story type

      -m           enable add description using vim

      omit all parameters will start interactive mode
    LONGDESC
    option :type, aliases: :t
    option :owner, aliases: :o
    option :m, type: :boolean
    def create(title =nil)
      owner = options[:owner]
      type = options[:type]
      requester_id = @local_config[:user_id]
      if title
        name = title
        owner = owner || @local_config[:user_name]
        type = task_type_or_nil(owner) || task_type_or_nil(type) || 'feature'
      else
        title("Let's create a new task:")
        name = ask("Name for the new task:")
      end

      owner = @client.find_member(owner).person.id if owner.kind_of?(String)

      unless owner
        if ask('Do you want to assign it now? (y/n)').downcase == 'y'
          members = @client.get_members
          table = PersonsTable.new(members.map(&:person))
          owner = select("Please select a member to assign him the task.", table).id
        else
          owner = nil
        end
        requester = @local_config[:user_name]
        type = ask('Type? (c)hore, (b)ug, anything else for feature)')
      end

      type = case type
             when 'c', 'chore'
               'chore'
             when 'b', 'bug'
               'bug'
             else
               'feature'
             end

      owner_ids = [owner]
      # did you do a -m so you can add a description?
      if options[:m]
        editor = ENV.fetch('EDITOR') { 'vi' }
        temp_path = "/tmp/editor-#{ Process.pid }.txt"
        system "#{ editor } #{ temp_path }"

        description = File.read(temp_path)
      end

      story = @client.create_story(
        name: name,
        owner_ids: owner_ids,
        requested_by_id: requester_id,
        story_type: type,
        description: description
      )
      congrats("#{type} for #{owner} open #{story.url}")
      show_story(story)
    end

    desc "find [query] " ,"looks in your stories by title and presents it"
    def find(query)
      story = select_story_from_paginated_table do |page|
        @client.get_stories(filter: query, page: page)
      end
      show_story(story)
    end

    desc "updates","shows number recent activity from your current project"
    def updates
      activities = @client.get_activities
      tasks = @client.get_my_work
      title("Recent Activity on #{project_to_s}")
      activities.each do |activity|
        show_activity(activity, tasks)
      end
    end
  end
end
