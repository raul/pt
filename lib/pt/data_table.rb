require 'hirb'

module PT

  class DataTable

    extend ::Hirb::Console

    def initialize(dataset)
      @rows = dataset.map{ |row| DataRow.new(row, dataset) }
    end

    def print
      if @rows.empty?
        puts "\n         -- empty list --         \n"
      else
        self.class.table @rows, :fields => [:num] + self.class.fields, :unicode => true, :description => false
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

  end


  class ProjectTable < DataTable

    def self.fields
      [:name]
    end

  end


  class TasksTable < DataTable

    def self.fields
      [:name, :current_state]
    end

  end

  class MembersTable < DataTable

    def self.fields
      [:name]
    end

  end

end