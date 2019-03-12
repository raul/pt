module PT
  module Action
    def show_story(story)
      title('========================================='.red)
      title story.name.red
      title('========================================='.red)
      estimation = [-1, nil].include?(story.estimate) ? "Unestimated" : "#{story.estimate} points"
      requester = story.requested_by ? story.requested_by.initials : @local_config[:user_name]
      message "#{story.current_state.capitalize} #{story.story_type} | #{estimation} | Req: #{requester} | Owners: #{story.owners.map(&:initials).join(',')} | ID: #{story.id}"

      if story.labels.present?
        message "Labels: " + story.labels.map(&:name).join(', ')
      end
      message story.description.green unless story.description.nil? || story.description.empty?
      message "View on pivotal: #{story.url}"

      if story.tasks.present?
        title('tasks'.yellow)
        story.tasks.each{ |t| compact_message "- #{t.complete ? "[done]" : ""} #{t.description}" }
      end


      story.comments.each do |n|
        title('......................................'.blue)
        text = ">> #{n.person.initials}: #{n.text}"
        text << "[#{n.file_attachment_ids.size}F]" if n.file_attachment_ids
        message text
      end
      save_recent_task( story.id )
    end

    def tasks_story(story)
      story_task = get_open_story_task_from_params(story)
      if story_task.position == -1
        description = ask('Title for new task')
        story.create_task(:description => description)
        congrats("New todo task added to \"#{story.name}\"")
      else
        edit_story_task story_task
      end
    end

    def open_story story
      `open #{story.url}`
    end

    def assign_story story
      if (owner = find_owner @params[1])
        @client.assign_task(story, owner)
      else
        members = @client.get_members
        table = PersonsTable.new(members.map(&:person))
        owner = select("Please select a member to assign them the story", table)
      end

      congrats("story assigned to #{owner.initials}, thanks!")
    end

    def comment_story(story)
      comment = @params[1] || ask("Write your comment")
      if @client.comment_task(story, comment)
        congrats("Comment sent, thanks!")
        save_recent_task( story.id )
      else
        error("Ummm, something went wrong.")
      end
    end

    def label_story(story)
      if @params[1]
        label = @params[1]
      else
        label = ask("Which label?")
      end

      @client.add_label(story, label );
      show_story(task_by_id_or_pt_id(story.id))
    end

    def estimate_story(story)
      estimation ||= ask("How many points you estimate for it? (#{project.point_scale})")
      @client.estimate_story(story, estimation)
      congrats("Task estimated, thanks!")
    end

    def start_story story
      @client.mark_task_as(story, 'started')
      congrats("story started, go for it!")
    end

    def finish_story story
      if story.story_type == 'chore'
        @client.mark_task_as(story, 'accepted')
      else
        @client.mark_task_as(story, 'finished')
      end
      congrats("Another story bites the dust, yeah!")
    end

    def deliver_story story
      return if story.story_type == 'chore'
      @client.mark_task_as(story, 'delivered')
      congrats("story delivered, congrats!")
    end

    def accept_story story
      @client.mark_task_as(story, 'accepted')
      congrats("Accepted")
    end

    def reject_story(story)
      comment = @params[1] || ask("Please explain why are you rejecting the story.")
      if @client.comment_task(story, comment)
        @client.mark_task_as(story, 'rejected')
        congrats("story rejected, thanks!")
      else
        error("Ummm, something went wrong.")
      end
    end

    def done_story(story)
      #we need this for finding again later
      story_id = story.id

      if !@params[1] && story.estimate == -1
        error("You need to give an estimate for this task")
        return
      end

      if @params[1] && story.estimate == -1
        if [0,1,2,3].include? @params[1].to_i
          estimate_story(story, @params[1].to_i)
        end
        if @params[2]
          story = task_by_id_or_pt_id story_id
          @client.comment_task(story, @params[2])
        end
      else
        @client.comment_task(story, @params[1]) if @params[1]
      end

      start_story story

      finish_story story

      deliver_story story
    end

  end
end

