require 'yaml'
require 'colored'
require 'highline'
require 'tempfile'
require 'uri'
module PT
  class UI
    include PT::Action

    GLOBAL_CONFIG_PATH = ENV['HOME'] + "/.pt"
    LOCAL_CONFIG_PATH = Dir.pwd + '/.pt'

    attr_reader :project

    def initialize(args)
      require 'pt/debugger' if ARGV.delete('--debug')
      @io = HighLine.new
      @global_config = load_global_config
      @local_config = load_local_config
      @client = Client.new(@global_config[:api_number], @local_config)
      @project = @client.project
      command = args[0].to_sym rescue :my_work
      @params = args[1..-1]
      commands.include?(command.to_sym) ? send(command.to_sym) : help
    end

    def my_work
      title("My Work for #{user_s} in #{project_to_s}")
      stories = @client.get_my_work
      TasksTable.new(stories).print @global_config
    end

    def todo
      title("My Work for #{user_s} in #{project_to_s}")
      stories = @client.get_my_work
      stories = stories.select { |story| story.current_state == "unscheduled" }
      TasksTable.new(stories).print @global_config
    end

    %w[unscheduled started finished delivered accepted rejected].each do |state|
      define_method(state.to_sym) do
        if @params[0]
          stories = project.stories(filter: "owner:#{@params[0]} state:#{state}")
          TasksTable.new(stories).print @global_config
        else
          # otherwise show them all
          title("Stories #{state} for #{project_to_s}")
          stories = project.stories(filter:"state:#{state}")
          TasksTable.new(stories).print @global_config
        end
      end
    end

    %w[show tasks open assign comments label estimate start finish deliver accept reject done].each do |action|
      define_method(action.to_sym) do
        story = get_task_from_params action
        unless story
          message("No matches found for '#{@params[0]}', please use a valid pivotal story Id")
          return
        end
        title("#{action} '#{story.name}'")
        send("#{action}_story", story)
      end
    end

    def list
      if @params[0]
        if @params[0] == "all"
          stories = @client.get_work
          TasksTable.new(stories).print @global_config
        else
          stories = @client.get_my_work(@params[0])
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

    def recent
      title("Your recent stories from #{project_to_s}")
      stories = @project.stories( ids: @local_config[:recent_tasks].join(',') )
      MultiUserTasksTable.new(stories).print @global_config
    end

    def create
      if @params[0]
        name = @params[0]
        owner = @params[1] || @local_config[:user_name]
        requester = @local_config[:user_name]
        task_type = task_type_or_nil(@params[1]) || task_type_or_nil(@params[2]) || 'feature'
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
        task_type = ask('Type? (c)hore, (b)ug, anything else for feature)')
      end

      task_type = case task_type
                  when 'c', 'chore'
                    'chore'
                  when 'b', 'bug'
                    'bug'
                  else
                    'feature'
                  end
      result = nil

      owner_ids = [owner]
      # did you do a -m so you can add a description?
      if ARGV.include? "-m" or ARGV.include? "--m"
        editor = ENV.fetch('EDITOR') { 'vi' }
        temp_path = "/tmp/editor-#{ Process.pid }.txt"
        system "#{ editor } #{ temp_path }"

        description = File.read(temp_path)
        story = @client.create_task_with_description(name, owner_ids, task_type, description)
      else
        story = @client.create_task(name, owner_ids, task_type)
      end
      # TODO need result
      congrats("#{task_type} for #{owner} open #{story.url}")
    end

    def find
      if (story_id = @params[0].to_i).nonzero?
        if task = task_by_id_or_pt_id(@params[0].to_i)
          return show_story(task)
        else
          message("Task not found by id (#{story_id}), falling back to text search")
        end
      end

      if @params[0]
        tasks = @client.search_for_story(@params[0])
        tasks.each do |story_task|
          title("--- [#{(tasks.index story_task) + 1 }] -----------------")
          show_story(story_task)
        end
        message("No matches found for '#{@params[0]}'") if tasks.empty?
      else
        message("You need to provide a substring for a tasks title.")
      end
    end

    def updates
      activities = @client.get_activities(@params[0])
      tasks = @client.get_my_work
      title("Recent Activity on #{project_to_s}")
      activities.each do |activity|
        show_activity(activity, tasks)
      end
    end

    def help
      if ARGV[0] && ARGV[0] != 'help'
        message("Command #{ARGV[0]} not recognized. Showing help.")
      end

      title("Command line usage for pt #{VERSION}")
      help = <<-HELP
      pt                                                                      # show all available stories

      pt todo      <owner>                                                    # show all unscheduled stories

      pt (unscheduled,started,finished,delivered, accepted, rejected) <owner> # show all (unscheduled,started,finished,delivered, accepted, rejected) stories

      pt create    [title] <owner> <type> -m                                  # create a new story (and include description ala git commit)

      pt show      [id]                                                       # shows detailed info about a story

      pt tasks     [id]                                                       # manage tasks of story

      pt open      [id]                                                       # open a story in the browser

      pt assign    [id] <owner>                                               # assign owner

      pt comment   [id] [comment]                                             # add a comment

      pt label     [id] [label]                                               # add a label

      pt estimate  [id] [0-3]                                                 # estimate a story in points scale

      pt (start,finish,deliver,accept)     [id]                               # mark a story as started

      pt reject    [id] [reason]                                              # mark a story as rejected, explaining why

      pt done      [id]  <0-3> <comment>                                      # lazy mans finish story, opens, assigns to you, estimates, finish & delivers

      pt find      [query]                                                    # looks in your stories by title and presents it

      pt list      [owner]                                                    # list all stories for another pt user

      pt list      all                                                        # list all stories for all users

      pt updates                                                              # shows number recent activity from your current project

      pt recent                                                               # shows stories you've recently shown or commented on with pt

      All commands can be run entirely without arguments for a wizard based UI. Otherwise [required] <optional>.
      Anything that takes an id will also take the num (index) from the pt command.
      HELP
      puts(help)
    end

    protected

    def commands
      (public_methods - Object.public_methods).map{ |c| c.to_sym}
    end

    # Config

    def load_global_config

      # skip global config if env vars are set
      if ENV['PIVOTAL_EMAIL'] and ENV['PIVOTAL_API_KEY']
        config = {
          :email => ENV['PIVOTAL_EMAIL'],
          :api_number => ENV['PIVOTAL_API_KEY']
        }
        return config
      end

      config = YAML.load(File.read(GLOBAL_CONFIG_PATH)) rescue {}
      if config.empty?
        message "I can't find info about your Pivotal Tracker account in #{GLOBAL_CONFIG_PATH}."
        while !config[:api_number] do
          config[:api_number] = ask "What is your token?"
        end
        congrats "Thanks!",
          "Your API id is " + config[:api_number],
          "I'm saving it in #{GLOBAL_CONFIG_PATH} so you don't have to log in again."
        save_config(config, GLOBAL_CONFIG_PATH)
      end
      config
    end

    def get_local_config_path
      # If the local config path does not exist, check to see if we're in a git repo
      # And if so, try the top level of the checkout
      if (!File.exist?(LOCAL_CONFIG_PATH) && system('git rev-parse 2> /dev/null'))
        return `git rev-parse --show-toplevel`.chomp() + '/.pt'
      else
        return LOCAL_CONFIG_PATH
      end
    end

    def load_local_config
      check_local_config_path
      config = YAML.load(File.read(get_local_config_path())) rescue {}

      if ENV['PIVOTAL_PROJECT_ID']

        config[:project_id] = ENV['PIVOTAL_PROJECT_ID']

        project = @client.get_project(config[:project_id])
        config[:project_name] = project.name

        membership = @client.get_my_info
        config[:user_name], config[:user_id], config[:user_initials] = membership.name, membership.id, membership.initials
        save_config(config, get_local_config_path())

      end

      if config.empty?
        message "I can't find info about this project in #{get_local_config_path()}"
        projects = ProjectTable.new(@client.get_projects)
        project = select("Please select the project for the current directory", projects)
        config[:project_id], config[:project_name] = project.id, project.name
        project = @client.get_project(project.id)
        membership = @client.get_my_info
        config[:user_name], config[:user_id], config[:user_initials] = membership.name, membership.id, membership.initials
        congrats "Thanks! I'm saving this project's info",
          "in #{get_local_config_path()}: remember to .gitignore it!"
        save_config(config, get_local_config_path())
      end
      config
    end

    def check_local_config_path
      if GLOBAL_CONFIG_PATH == get_local_config_path()
        error("Please execute .pt inside your project directory and not in your home.")
        exit
      end
    end

    def save_config(config, path)
      File.new(path, 'w') unless File.exists?(path)
      File.open(path, 'w') {|f| f.write(config.to_yaml) }
    end

    # I/O

    def split_lines(text)
      text.respond_to?(:join) ? text.join("\n") : text
    end

    def title(*msg)
      puts "\n#{split_lines(msg)}".bold
    end

    def congrats(*msg)
      puts "\n#{split_lines(msg).green.bold}"
    end

    def message(*msg)
      puts "\n#{split_lines(msg)}"
    end

    def compact_message(*msg)
      puts "#{split_lines(msg)}"
    end

    def error(*msg)
      puts "\n#{split_lines(msg).red.bold}"
    end

    def select(msg, table)
      if table.length > 0
        begin
          table.print @global_config
          row = ask "#{msg} (1-#{table.length}, 'n' to fetch next data, 'p' to fetch previous data, 'q' to exit)"
          case row
          when 'q'
            quit
          when 'n'
            return 'n'
          when 'p'
            return 'p'
          end
          selected = table[row]
          error "Invalid selection, try again:" unless selected
        end until selected
        selected
      else
        table.print @global_config
        message "Sorry, there are no options to select."
        quit
      end
    end

    def quit
      message "bye!"
      exit
    end

    def ask(msg)
      @io.ask("#{msg.bold}")
    end

    def ask_secret(msg)
      @io.ask("#{msg.bold}"){ |q| q.echo = '*' }
    end

    def user_s
      "#{@local_config[:user_name]} (#{@local_config[:user_initials]})"
    end

    def project_to_s
      "Project #{@local_config[:project_name].upcase}"
    end

    def task_type_or_nil query
      if (["feature", "bug", "chore"].index query)
        return query
      end
      nil
    end

    def task_by_id_or_pt_id id
      if id < 1000
        tasks = @client.get_my_work(@local_config[:user_name])
        table = TasksTable.new(tasks)
        table[id]
      else
        @client.get_task_by_id id
      end
    end

    def find_task query
      members = @client.get_members
      members.each do | member |
        if member.name.downcase.index query
          return member.name
        end
      end
      nil
    end

    def find_owner query
      if query
        member = @client.get_member(query)
        return member ? member.person : nil
      end
      nil
    end


    def show_activity(activity, tasks)
      message("#{activity.message}")
    end

    def get_open_story_task_from_params(task)
      title "Pending tasks for '#{task.name}'"
      task_struct = Struct.new(:description, :position)

      pending_tasks = [
        task_struct.new('<< Add new task >>', -1)
      ]

      task.tasks.each{ |t| pending_tasks << t unless t.complete }
      table = TodoTaskTable.new(pending_tasks)
      select("Pick task to edit, 1 to add new task", table)
    end

    def get_task_from_params(action='show')
      prompt = "Please select a story to #{action}"
      if @params[0]
        task = task_by_id_or_pt_id(@params[0].to_i)
      else
        page = 0
        begin
          tasks = if %w[start finish deliver accept reject estimate].include?(action)
            @client.send("get_my_tasks_to_#{action}", page: page)
          else
            @client.get_stories(page: page)
          end
          table = TasksTable.new(tasks)
          task = select(prompt, table)
          if task == 'n'
            page+=1
          elsif task == 'p'
            page-=1
          end
        end while task.kind_of?(String)
        return task
      end
    end

    def edit_story_task(task)
      action_class = Struct.new(:action, :key)

      table = ActionTable.new([
        action_class.new('Complete', :complete),
        # action_class.new('Delete', :delete),
        action_class.new('Edit', :edit)
        # Move?
      ])
      action_to_execute = select('What to do with todo?', table)

      task.project_id = project.id
      task.client = project.client
      case action_to_execute.key
      when :complete then
        task.complete = true
        congrats('Todo task completed!')
      # when :delete then
      #   task.delete
      #   congrats('Todo task removed')
      when :edit then
        new_description = ask('New task description')
        task.description = new_description
        congrats("Todo task changed to: \"#{task.description}\"")
      end
      task.save
    end

    def save_recent_task( task_id )
      # save list of recently accessed tasks
      unless (@local_config[:recent_tasks])
        @local_config[:recent_tasks] = Array.new();
      end
      @local_config[:recent_tasks].unshift( task_id )
      @local_config[:recent_tasks] = @local_config[:recent_tasks].uniq()
      if @local_config[:recent_tasks].length > 10
        @local_config[:recent_tasks].pop()
      end
      save_config( @local_config, get_local_config_path() )
    end

  end
end
