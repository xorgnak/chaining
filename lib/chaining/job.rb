module JOB
  @@J = Hash.new { |h,k| h[k] = Jobs.new(k) }
  class Jobs
    def initialize k
      puts %[Jobs #{k}]
      @jobs = k
      @db = JobsDB.new(k)
      @job = Hash.new { |h,k| h[k] = Job.new(%[#{@jobs}-#{k}]) }
    end
    def section
      @job
    end
    def [] k
      @db[k]
    end
    def []= k,v
      @db[k] = v
    end
    def keys
      @job.keys
    end    
    class Job
      attr_reader :job
      def initialize k
        @job = k
        @db = JobDB.new(k)
        puts %[Job #{@job.class} #{@db}]
        @task = Hash.new { |h,k| h[k] = Task.new(%[#{@job}-#{k}]) }
      end
      def task
        @task
      end
      def [] k
        @db[k]
      end
      def []= k,v
        @db[k] = v
      end
      def keys
        @task.keys
      end
      class Task
        def initialize k
          @key = k
          @db = TaskDB.new(k)
        end
        def []= k,v
          @db[k] = v
        end
        def [] k
          @db[k]
        end
        class TaskDB
          def initialize k
            @db = PStore.new("db/task-#{k}.pstore")
          end
          def keys
            @db.transaction { |db| db.keys }
          end
          def has_key? k
            @db.transaction { |db| db.key?(k) ? true : false }
          end
          def [] k
            @db.transaction { |db| db[k] }
          end
          def []= k,v
            @db.transaction { |db| db[k] = v }
          end
        end
        def to_task
          a = []
          if @db.has_key?(:crit) && @db[:crit] == true
            a << %[crit]
          end
          if @db.has_key?(:milestone) && @db[:milestone] == true
            a << %[milestone]
          end
          if @db.has_key?(:state)
            a << @db[:state]
          else
            a << %[HOLD]
          end
          if @db.has_key?(:tag)
            a << @db[:tag]
          end
          if @db.has_key?(:before)
            a << %[before #{@db[:before]}]
          end
          if @db.has_key?(:after)
            a << %[after #{@db[:after]}]
          end
          if @db.has_key?(:until)
            a << %[until #{@db[:until]}]
          end          
          if @db.has_key?(:start)
            a << @db[:start]
          end
          if @db.has_key?(:duration)
            a << @db[:duration]
          end          
          %[#{@db[:name] || @key} :#{a.join(", ")}]
        end
      end
      def to_tasks
        a = [%[section #{@db[:name] || @job}]]
        @task.each_pair { |k,v| puts %[task: #{k}: #{v}]; a << v.to_task }
        return a.join("\n")
      end
    end
    class JobDB
      def initialize k
        fn = %[db/job-#{k.to_s}.pstore]
        puts %[JobDB #{k} #{fn}]
        @db = PStore.new(fn) 
      end
      def keys
        @db.transaction { |db| db.keys }
      end
      def [] k
        @db.transaction { |db| db[k] }
      end
      def []= k,v
        @db.transaction { |db| db[k] = v }
      end    
    end
    def to_jobs
      a = [%[gantt\ndateFormat  YYYY-MM-DD\ntitle #{@db[:name] || @jobs}]]
      @job.each_pair { |k,v| puts %[job: #{k}: #{v}]; a << v.to_tasks }
      return a.join("\n\n") + "\n"
    end
  end
  class JobsDB
    def initialize k
      @db = PStore.new("db/job-#{k}.pstore") 
    end  
    def keys
      @db.transaction { |db| db.keys }
    end
    def [] k
      @db.transaction { |db| db[k] }
    end
    def []= k,v
      @db.transaction { |db| db[k] = v }
    end    
  end
  def self.[] k
    @@J[k]
  end
end
