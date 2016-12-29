require 'pivotal-tracker-api'
require 'pt/switch_ssl'
require 'uri'

class PT::Client

  def self.get_api_token(email, password)
    PivotalAPI::Me.retrieve(email, password)
  rescue RestClient::Unauthorized
    raise PT::InputError.new("Bad email/password combination.")
  end

  def initialize(api_number)
    PivotalAPI::Service.set_token(api_number)
    @project = nil
  end

  def get_project(project_id)
    project = PivotalAPI::Project.retrieve(project_id)
    project
  end

  def get_projects
    PivotalAPI::Projects.retrieve()
  end

  def get_membership(project, email)
    PivotalTracker::Membership.all(project).select{ |m| m.email == email }.first
  end

  def get_current_iteration(project)
    PivotalTracker::Iteration.current(project)
  end

  def get_activities(project, limit)
    if limit
      project.activities.all :limit => limit
    else
      project.activities.all
    end
  end

  def get_work(project)
    project.stories.all(:current_state => 'unscheduled,unstarted,started')
  end

  def get_my_work(project, user_name)
    project.stories parameters: {filter: "owner:#{user_name} -state:accepted", limit: 50}
  end

  def get_task_by_id(id)
    stories = get_projects.map do |project| 
      begin
        project.story(id)
      rescue RestClient::ResourceNotFound
        puts 'task not found on this project'
      end
    end
    stories.flatten.first
  end

  def get_my_open_tasks(project, user_name)
    project.stories.all :owner => user_name
  end

  def get_my_tasks_to_estimate(project, user_name)
    project.stories.all(:owner => user_name, :story_type => 'feature').select{ |t| t.estimate == -1 }
  end

  def get_my_tasks_to_start(project, user_name)
    tasks = project.stories parameters: {filter: "owner:#{user_name} state:unscheduled,rejected,unstarted", limit: 50}
    tasks.reject{ |t| (t.story_type == 'feature') && (t.estimate == -1) }
  end

  def get_my_tasks_to_finish(project, user_name)
    project.stories parameters: {filter: "owner:#{user_name} state:started", limit: 50}
  end

  def get_my_tasks_to_deliver(project, user_name)
    project.stories parameters: {filter: "owner:#{user_name} state:finished", limit: 50}
  end

  def get_my_tasks_to_accept(project, user_name)
    project.stories parameters: {filter: "owner:#{user_name} state:finished", limit: 50}
  end

  def get_my_tasks_to_reject(project, user_name)
    project.stories parameters: {filter: "owner:#{user_name} state:delivered", limit: 50}
  end

  def get_tasks_to_assign(project, user_name)
    project.stories parameters: {filter: "no:owner -state:accepted", limit: 50}
  end

  def get_member(project, query)
    member = project.memberships.all.select{ |m| m.name.downcase.start_with? query.downcase || m.initials.downcase == query.downcase }
    member.empty? ? nil : member.first
  end

  def get_members(project)
    project.memberships.all
  end

  def get_story(story, project)
    project.story(story.id, project.id)
  end

  def mark_task_as(project, task, state)
    task = get_story(task.id, project.id)
    task.update(:current_state => state)
  end

  def estimate_task(project, task, points)
    task = get_story(task.id, project.id)
    task.update(:estimate => points)
  end

  def assign_task(project, task, owner)
    task = get_story(task.id, project.id)
    task.update(:owned_by => owner)
  end

  def add_label(project, task, label)
    task = get_story(task.id, project.id)
    if task.labels
      task.labels += "," + label;
      task.update(:labels => task.labels)
    else
      task.update(:labels => label)
    end
  end

  def comment_task(project, task, comment)
    task = get_story(task.id, project.id)
    task.notes.create(:text => comment)
  end

  def create_task(project, name, owner, requester, task_type)
    project.stories.create(:name => name, :owned_by => owner, :requested_by => requester, :story_type => task_type)
  end

  def create_task_with_description(project, name, owner, requester, task_type, description)
    project.stories.create(:name => name, :owned_by => owner, :requested_by => requester, :story_type => task_type, :description => description)
  end


end
