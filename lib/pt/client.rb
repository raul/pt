require 'pt/switch_ssl'
require 'uri'
require 'tracker_api'

module PT
  class Client

    STORY_FIELDS=':default,requested_by,owners,tasks,comments(:default,person,file_attachments)'

    attr_reader :config, :project

    def self.get_api_token(email, password)
      PivotalAPI::Me.retrieve(email, password)
    rescue RestClient::Unauthorized
      raise PT::InputError.new("Bad email/password combination.")
    end

    def initialize(token, local_config=nil)
      @client = TrackerApi::Client.new(token: token)
      @config = local_config
      @project = @client.project(local_config[:project_id]) if local_config
    end

    def total_page(limit=nil)
      limit ||= @config[:limit]
      @total_record = @client.last_response.env.response_headers["X-Tracker-Pagination-Total"]
      @total_record ? (@total_record.to_f/limit).ceil : 1
    end

    def current_page(limit=nil)
      limit ||= @config[:limit]
      offset = @client.last_response.env.response_headers["X-Tracker-Pagination-Offset"]
      offset ? ((offset.to_f/limit)+1).to_i.ceil : 1
    end


    def get_project(project_id)
      project = @client.project(project_id)
      project
    end

    def get_projects
      @client.projects
    end

    def get_membership(email)
      PivotalTracker::Membership.all(project).select{ |m| m.email == email }.first
    end

    def get_my_info
      @client.me
    end

    def get_current_iteration(project)
      PivotalTracker::Iteration.current(project)
    end

    def get_activities
      project.activity
    end

    def get_work
      project.stories(filter: 'state:unscheduled,unstarted,started', fields: STORY_FIELDS )
    end

    def get_my_work
      project.stories(filter: "owner:#{config[:user_name]} -state:accepted", limit: 50, fields: STORY_FIELDS)
    end

    def search_for_story(query, params={})
      params[:filter] =  "#{query}"
      get_stories(params)
    end

    def get_task_by_id(id)
      project.story(id, fields: STORY_FIELDS)
    end
    alias :get_story :get_task_by_id

    def get_my_open_tasks(params={})
      params[:filter] =  "owner:#{config[:user_name]}"
      get_stories(params)
    end

    def get_stories_to_estimate(params={})
      params[:filter] =  "owner:#{config[:user_name]} type:feature estimate:-1"
      get_stories(params)
    end

    def get_stories_to_start(params={})
      params[:filter] =  "owner:#{config[:user_name]} type:feature,bug state:unscheduled,rejected,unstarted"
      tasks = get_stories(params)
      tasks.reject{ |t| (t.story_type == 'feature') && (!t.estimate) }
    end

    def get_stories_to_finish(params={})
      params[:filter] =  "owner:#{config[:user_name]} -state:unscheduled,rejected"
      get_stories(params)
    end

    def get_stories_to_deliver(params={})
      params[:filter] =  "owner:#{config[:user_name]} -state:delivered,accepted,rejected"
      get_stories(params)
    end

    def get_stories_to_accept(params={})
      params[:filter] =  "owner:#{config[:user_name]} -state:accepted"
      get_stories(params)
    end

    def get_stories_to_reject(params={})
      params[:filter] =  "owner:#{config[:user_name]} -state:rejected"
      get_stories(params)
    end

    def get_stories_to_assign(params={})
      params[:filter] =  "-state:accepted"
      get_stories(params)
    end

    def get_stories(params={})
      limit = params[:limit] || config[:limit] || 10
      page = params[:page] || 1
      offset = (page-1)*limit
      filter = params[:filter] || '-state=accepted'
      project.stories limit: limit, fields: STORY_FIELDS, auto_paginate: false, offset: offset, filter: filter
    end


    def get_member(query)
      member = project.memberships.select{ |m| m.person.name.downcase.start_with?(query.downcase) || m.person.initials.downcase == query.downcase }
      member.empty? ? nil : member.first
    end

    def find_member(query)
      project.memberships.detect do |m|
        m.person.name.downcase.start_with?(query.downcase) || m.person.initials.downcase == query.downcase
      end
    end

    def get_members
      project.memberships fields: ':default,person'
    end


    def mark_task_as(task, state)
      task = get_story(task.id)
      task.current_state = state
      task.save
    end

    def estimate_story(task, points)
      task = get_story(task.id)
      task.estimate = points
      task.save
    end

    def assign_task(task, owner)
      task = get_story(task.id)
      task.add_owner(owner)
    end

    def add_label(task, label)
      task = get_story(task.id)
      task.add_label(label)
      task.save
    end

    def comment_task(task, comment)
      task = get_story(task.id)
      task.create_comment(text: comment)
    end

    def create_story(args)
      project.create_story(args)
    end

  end
end
