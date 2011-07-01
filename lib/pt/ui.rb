require 'yaml'
require 'colored'
require 'highline'

class PT::UI

  GLOBAL_CONFIG_PATH = ENV['HOME'] + "/.pt"
  LOCAL_CONFIG_PATH = Dir.pwd + '/.pt'

  def initialize(args)
    require 'pt/debugger' if ARGV.delete('--debug')
    @io = HighLine.new
    @global_config = load_global_config
    @client = PT::Client.new(@global_config[:api_number])
    @local_config = load_local_config
    @project = @client.get_project(@local_config[:project_id])
    command = args[0].to_sym rescue :my_work
    params = args[1..-1]
    commands.include?(command.to_sym) ? send(command.to_sym) : help(command)
  end

  def my_work
    title("My Work for #{user_s} in #{project_to_s}")
    stories = @client.get_my_work(@project, @local_config[:user_name])
    PT::TasksTable.new(stories).print
  end

  def create
    title("Let's create a new task:")
    name = ask("Name for the new task:")
    if ask('Do you want to assign it now? (y/n)').downcase == 'y'
      members = @client.get_members(@project)
      table = PT::MembersTable.new(members)
      owner = select("Please select a member to assign him the task", table).name
    else
      owner = nil
    end
    requester = @local_config[:user_name]
    task_type = ask('Type? (c)hore, (b)ug, anything else for feature)')
    task_type = case task_type
    when 'c', 'chore'
      'chore'
    when 'b', 'bug'
      'bug'
    else
      'feature'
    end
    result = @client.create_task(@project, name, owner, requester, task_type)
    if result.errors.any?
      error(result.errors.errors)
    else
      congrats("Task created, yay!")
    end
  end

  def open
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_my_open_tasks(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a story to open it in the browser", table)
    `open #{task.url}`
  end

  def comment
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_my_work(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a story to comment it", table)
    comment = ask("Write your comment")
    if @client.comment_task(@project, task, comment)
      congrats("Comment sent, thanks!")
    else
      error("Ummm, something went wrong.")
    end
  end

  def assign
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_tasks_to_assign(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a task to assign it an owner", table)
    members = @client.get_members(@project)
    table = PT::MembersTable.new(members)
    owner = select("Please select a member to assign him the task", table).name
    result = @client.assign_task(@project, task, owner)
    if result.errors.any?
      error(result.errors.errors)
    else
      congrats("Task assigned, thanks!")
    end

  end

  def estimate
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_my_tasks_to_estimate(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a story to estimate it", table)
    estimation = ask("How many points you estimate for it? (#{@project.point_scale})")
    result = @client.estimate_task(@project, task, estimation)
    if result.errors.any?
      error(result.errors.errors)
    else
      congrats("Task estimated, thanks!")
    end
  end

  def start
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_my_tasks_to_start(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a story to mark it as started", table)
    result = @client.mark_task_as(@project, task, 'started')
    if result.errors.any?
      error(result.errors.errors)
    else
      congrats("Task started, go for it!")
    end
  end

  def finish
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_my_tasks_to_finish(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a story to mark it as finished", table)
    if task.story_type == 'chore'
      result = @client.mark_task_as(@project, task, 'accepted')
    else
      result = @client.mark_task_as(@project, task, 'finished')
    end
    if result.errors.any?
      error(result.errors.errors)
    else
      congrats("Another task bites the dust, yeah!")
    end
  end

  def deliver
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_my_tasks_to_deliver(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a story to mark it as delivered", table)
    result = @client.mark_task_as(@project, task, 'delivered')
    error(result.errors.errors) if result.errors.any?
    if result.errors.any?
      error(result.errors.errors)
    else
      congrats("Task delivered, congrats!")
    end
  end

  def accept
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_my_tasks_to_accept(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a story to mark it as accepted", table)
    result = @client.mark_task_as(@project, task, 'accepted')
    if result.errors.any?
      error(result.errors.errors)
    else
      congrats("Task accepted, hooray!")
    end
  end

  def show
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_my_work(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a story to show", table)
    result = show_task(task)
  end

  def reject
    title("Tasks for #{user_s} in #{project_to_s}")
    tasks = @client.get_my_tasks_to_reject(@project, @local_config[:user_name])
    table = PT::TasksTable.new(tasks)
    task = select("Please select a story to mark it as rejected", table)
    comment = ask("Please explain why are you rejecting the task")
    if @client.comment_task(@project, task, comment)
      result = @client.mark_task_as(@project, task, 'rejected')
      congrats("Task rejected, thanks!")
    else
      error("Ummm, something went wrong.")
    end
  end

  protected

  def commands
    (public_methods - Object.public_methods).sort.map{ |c| c.to_sym}
  end

  # Config

  def load_global_config
    config = YAML.load(File.read(GLOBAL_CONFIG_PATH)) rescue {}
    if config.empty?
      message "I can't find info about your Pivotal Tracker account in #{GLOBAL_CONFIG_PATH}"
      while !config[:api_number] do
        config[:email] = ask "What is your email?"
        password = ask_secret "And your password? (won't be displayed on screen)"
        begin
          config[:api_number] = PT::Client.get_api_token(config[:email], password)
        rescue PT::InputError => e
          error e.message + " Please try again."
        end
      end
      congrats "Thanks!",
               "Your API id is " + config[:api_number],
               "I'm saving it in #{GLOBAL_CONFIG_PATH} to don't ask you again."
      save_config(config, GLOBAL_CONFIG_PATH)
    end
    config
  end

  def load_local_config
    check_local_config_path
    config = YAML.load(File.read(LOCAL_CONFIG_PATH)) rescue {}
    if config.empty?
      message "I can't find info about this project in #{LOCAL_CONFIG_PATH}"
      projects = PT::ProjectTable.new(@client.get_projects)
      project = select("Please select the project for the current directory", projects)
      config[:project_id], config[:project_name] = project.id, project.name
      membership = @client.get_membership(project, @global_config[:email])
      config[:user_name], config[:user_id], config[:user_initials] = membership.name, membership.id, membership.initials
      congrats "Thanks! I'm saving this project's info",
               "in #{LOCAL_CONFIG_PATH}: remember to .gitignore it!"
      save_config(config, LOCAL_CONFIG_PATH)
    end
    config
  end

  def check_local_config_path
    if GLOBAL_CONFIG_PATH == LOCAL_CONFIG_PATH
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

  def error(*msg)
    puts "\n#{split_lines(msg).red.bold}"
  end

  def select(msg, table)
    if table.length > 0
      begin
        table.print
        row = ask "#{msg} (1-#{table.length}, 'q' to exit)"
        quit if row == 'q'
        selected = table[row]
        error "Invalid selection, try again:" unless selected
      end until selected
      selected
    else
      table.print
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

  def help(command)
    error "Command <#{command}> unknown.", "Available commands:" + commands.map{ |c| "\n- #{c}" }.join
  end

  def user_s
    "#{@local_config[:user_name]} (#{@local_config[:user_initials]})"
  end

  def project_to_s
    "Project #{@local_config[:project_name].upcase}"
  end
 
  def show_task(task)
    message task.name.white.bold
    message <<-TASK
#{"Type".cyan}:         #{task.story_type}
#{"Estimate".cyan}:     #{task.estimate == -1 ? "Unestimated" : task.estimate}
#{"Label(s)".cyan}:     #{task.labels && task.labels.gsub(/,([^ ])/, ', \1')}
#{"State".cyan}:        #{task.current_state}
#{"Requested By".cyan}: #{task.requested_by.yellow} on #{task.created_at.strftime("%d %b %Y")}
#{"Owned By".cyan}:     #{task.owned_by.yellow}
#{"Story Id".cyan}:     #{task.id}
#{"Url".cyan}:          #{task.url}

#{"Description".cyan}:  #{task.description}
TASK

    tasks = task.tasks.all
    message "Tasks (#{tasks.length})".cyan + ":"
    tasks.each do |t|
      message "#{t.complete ? "X".green : " "} #{t.description}"
    end

    notes = task.notes.all
    message "Comments (#{notes.length})".cyan + ":"
    notes.each do |note|
      message <<-NOTE
#{note.author.yellow} #{note.noted_at.strftime("%d %b %Y, %I:%M%p")}
#{note.text}
NOTE
    end
    message ""
  end

end
