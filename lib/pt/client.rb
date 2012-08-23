require 'pivotal-tracker'
require 'pt/switch_ssl'

class PT::Client

  def self.get_api_token(email, password)
    PivotalTracker::Client.token(email, password)
  rescue RestClient::Unauthorized
    raise PT::InputError.new("Bad email/password combination.")
  end

  def initialize(api_number)
    PivotalTracker::Client.token = api_number
    @project = nil
  end

  def get_project(project_id)
    get_projects
    project = PivotalTracker::Project.find(project_id)
    PivotalTracker::Client.use_ssl = project.use_https
    project
  end

  def get_projects
    PivotalTracker::Project.all
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

  def get_my_work(project, user_name)
    project.stories.all :mywork => user_name
  end

  def get_task_by_id(id)
    get_projects.map {|project| project.stories.all(:id => id)}.flatten.first
  end

  def get_my_open_tasks(project, user_name)
    project.stories.all :owner => user_name
  end

  def get_my_tasks_to_estimate(project, user_name)
    project.stories.all(:owner => user_name, :story_type => 'feature').select{ |t| t.estimate == -1 }
  end

  def get_my_tasks_to_start(project, user_name)
    tasks = project.stories.all(:owner => user_name, :current_state => 'unscheduled,rejected,unstarted')
    tasks.reject{ |t| (t.story_type == 'feature') && (t.estimate == -1) }
  end

  def get_my_tasks_to_finish(project, user_name)
    project.stories.all(:owner => user_name, :current_state => 'started')
  end

  def get_my_tasks_to_deliver(project, user_name)
    project.stories.all(:owner => user_name, :current_state => 'finished')
  end

  def get_my_tasks_to_accept(project, user_name)
    project.stories.all(:owner => user_name, :current_state => 'delivered')
  end

  def get_my_tasks_to_reject(project, user_name)
    project.stories.all(:owner => user_name, :current_state => 'delivered')
  end

  def get_tasks_to_assign(project, user_name)
    project.stories.all.select{ |t| t.owned_by == nil }
  end

  def get_member(project, query)
    member = project.memberships.all.select{ |m| m.name.downcase == query.downcase || m.initials.downcase == query.downcase }
    member.empty? ? nil : member.first
  end

  def get_members(project)
    project.memberships.all
  end

  def mark_task_as(project, task, state)
    task = PivotalTracker::Story.find(task.id, project.id)
    task.update(:current_state => state)
  end

  def estimate_task(project, task, points)
    task = PivotalTracker::Story.find(task.id, project.id)
    task.update(:estimate => points)
  end

  def assign_task(project, task, owner)
    task = PivotalTracker::Story.find(task.id, project.id)
    task.update(:owned_by => owner)
  end

  def comment_task(project, task, comment)
    task = PivotalTracker::Story.find(task.id, project.id)
    task.notes.create(:text => comment)
  end

  def create_task(project, name, owner, requester, task_type)
    project.stories.create(:name => name, :owned_by => owner, :requested_by => requester, :story_type => task_type)
  end

end
