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

    class_option "limit", aliases: :l, type: :numeric, default: 10, desc: 'change limit'
    class_option "page", aliases: :p, type: :numeric, desc: 'show n-th page'

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
        stories = @client.get_stories(filter: filter, page: options[:page], limit: options[:limit])
        print_stories_table(stories)
      end
    end

    %w[show tasks open assign comments label estimate start finish deliver accept reject done].each do |action|
      desc "#{action} [id]", "#{action} story"
      method_option "interactive", aliases: :i, type: :boolean, default: true, desc: 'enable interactive method'
      define_method(action.to_sym) do |story_id = nil|
        if story_id
          story = task_by_id_or_pt_id(story_id.to_i)
          unless story
            message("No matches found for '#{story_id}', please use a valid pivotal story Id")
            return
          end
        else
          method_name = "get_stories_to_#{action}"
          stories = if @client.respond_to?(method_name.to_sym)
            @client.send("get_stories_to_#{action}", page: options[:page], limit: options[:limit])
          else
            @client.get_stories(page: options[:page], limit: options[:limit])
          end
          story = select_story_from_paginated_table(stories)
        end
        title("#{action} '#{story.name}'")
        send("#{action}_story", story)
      end
    end

    desc 'mywork', 'list all your stories'
    def mywork
      stories = @client.get_stories(filter: "owner:#{@local_config[:user_name]} -state:accepted", page: options[:page])
      print_stories_table(stories)
    end

    desc "list [owner]", "list all stories from owner"
    def list(owner = nil)
      if owner
        if owner == "all"
          stories = @client.get_work
        else
          stories = @client.get_my_work(owner)
        end
      else
        members = @client.get_members
        table = MembersTable.new(members)
        user = select("Please select a member to see his tasks.", table).name
        title("Work for #{user} in #{project_to_s}")
        stories = @client.get_my_work(user)
      end
      print_stories_table(stories)
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
      stories = @client.get_stories(filter: query, page: options[:page])
      print_stories_table(stories)
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
