require 'hirb'
require 'hirb-unicode'

module PT

  class DataTable

    extend ::Hirb::Console

    def initialize(dataset)
      @rows = dataset.map{ |row| DataRow.new(row, dataset) }
    end

    def print(config={})
      if @rows.empty?
        puts "\n#{'-- empty list --'.center(36)}\n"
      else

        max_width = Hirb::Util.detect_terminal_size()[0]
        if config[:max_width] && config[:max_width] < max_width
          max_width = config[:max_width]
        end
        headers = [:num]

        headers += self.class.headers.present? ? self.class.headers : self.class.fields

        self.class.table @rows, :fields => [:num] + self.class.fields,
             :change_fields => %w{num pt_id},
             :unicode => true, :description => false,
             :max_width => max_width
      end
    end

    def [](pos)
      pos = pos.to_i
      (pos < 1 || pos > @rows.length) ? nil : @rows[pos-1].record
    end

    def length
      @rows.length
    end

    def self.fields
      []
    end

    def self.headers
      []
    end

  end


  class ProjectTable < DataTable

    def self.fields
      [:name]
    end

  end


  class TasksTable < DataTable

    def self.fields
      [:name, :owners, :story_type, :estimate, :state, :id]
    end

    def self.headers
      [:name, :owners, :type, :point, :state, :id]
    end

  end

  class MultiUserTasksTable < DataTable

    def self.fields
      [:owned_by, :name, :state, :id]
    end

  end

  class PersonsTable < DataTable

    def self.fields
      [:name]
    end

  end

  class MembersTable < DataTable

    def self.fields
      [:name]
    end

  end

  class TodoTaskTable < DataTable

    def self.fields
      [:description]
    end
  end

  class ActionTable < DataTable

    def self.fields
      [:action]
    end
  end

end
