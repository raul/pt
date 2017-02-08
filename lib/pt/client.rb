require 'pt/switch_ssl'
require 'uri'
require 'tracker_api'

module PT
  class Client

    STORY_FIELDS=':default,requested_by,owners,tasks,comments(:default,person,file_attachments)'


    def self.get_api_token(email, password)
      PivotalAPI::Me.retrieve(email, password)
    rescue RestClient::Unauthorized
      raise PT::InputError.new("Bad email/password combination.")
    end

    def initialize(token)
      @client = TrackerApi::Client.new(token: token)
      @project = nil
    end

    def get_project(project_id)
      project = @client.project(project_id)
      project
    end

    def get_projects
      @client.projects
    end

    def get_membership(project, email)
      PivotalTracker::Membership.all(project).select{ |m| m.email == email }.first
    end

    def get_my_info
      @client.me
    end

    def get_current_iteration(project)
      PivotalTracker::Iteration.current(project)
    end

    def get_activities(project, limit)
      project.activity
    end

    def get_work(project)
      project.stories(filter: 'state:unscheduled,unstarted,started', fields: STORY_FIELDS )
    end

    def get_my_work(project, user_name)
      project.stories(filter: "owner:#{user_name} -state:accepted", limit: 50, fields: STORY_FIELDS)
    end

    def search_for_story(project, query)
      project.stories(filter: query.to_s ,fields: STORY_FIELDS)
    end

    def get_task_by_id(project, id)
      project.story(id, fields: STORY_FIELDS)
    end
    alias :get_story :get_task_by_id

    def get_my_open_tasks(project, user_name)
      project.stories filter: "owner:#{user_name}", fields: STORY_FIELDS
    end

    def get_my_tasks_to_estimate(project, user_name)
      project.stories( filter: "owner:#{user_name} type:feature estimate:-1", fields: STORY_FIELDS)
    end

    def get_my_tasks_to_start(project, user_name)
      tasks = project.stories filter: "owner:#{user_name} state:unscheduled,rejected,unstarted", limit: 50, fields: STORY_FIELDS
      tasks.reject{ |t| (t.story_type == 'feature') && (t.estimate == -1) }
    end

    def get_my_tasks_to_finish(project, user_name)
      project.stories filter: "owner:#{user_name} -state:finished,delivered,accepted,rejected", limit: 50, fields: STORY_FIELDS
    end

    def get_my_tasks_to_deliver(project, user_name)
      project.stories filter: "owner:#{user_name} -state:delivered,accepted,rejected", limit: 50, fields: STORY_FIELDS
    end

    def get_my_tasks_to_accept(project, user_name)
      project.stories filter: "owner:#{user_name} -state:accepted", limit: 50, fields: STORY_FIELDS
    end

    def get_my_tasks_to_reject(project, user_name)
      project.stories filter: "owner:#{user_name} -state:rejected", limit: 50, fields: STORY_FIELDS
    end

    def get_tasks_to_assign(project)
      project.stories filter: "-state:accepted", limit: 50
    end

    def get_all_stories(project, config, params)
      limit = config[:limit] || 20
      offset = params[:page]*limit
      project.stories limit: limit, fields: STORY_FIELDS, auto_paginate: false, offset: offset, filter: '-state:accepted'
    end


    def get_member(project, query)
      member = project.memberships.select{ |m| m.person.name.downcase.start_with?(query.downcase) || m.person.initials.downcase == query.downcase }
      member.empty? ? nil : member.first
    end

    def find_member(project, query)
      memberships = project.memberships.detect do |m|
        m.person.name.downcase.start_with?(query.downcase) || m.person.initials.downcase == query.downcase
      end
    end

    def get_members(project)
      project.memberships fields: ':default,person'
    end


    def mark_task_as(project, task, state)
      task = get_story(project, task.id)
      task.current_state = state
      task.save
    end

    def estimate_task(project, task, points)
      task = get_story(project, task.id)
      task.estimate = points
      task.save
    end

    def assign_task(project, task, owner)
      task = get_story(project, task.id)
      task.add_owner(owner)
    end

    def add_label(project, task, label)
      task = get_story(project, task.id)
      task.add_label(label)
      task.save
    end

    def comment_task(project, task, comment)
      task = get_story(project, task.id)
      task.create_comment(text: comment)
    end

    def create_task(project, name, owner_ids, task_type)
      project.create_story(:name => name, :story_type => task_type, owner_ids: owner_ids)
    end

    def create_task_with_description(project, name, owner, task_type, description)
      project.create_story(:name => name, :story_type => task_type, :description => description)
    end


  end
end
