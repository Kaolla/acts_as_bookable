module ActsAsBookable
  ##
  # Provide helper functions to manage operations and queries related to times
  # and schedules
  #
  module TimeUtils
    class << self
      ##
      # Check if time is included in a time interval. The ending time is excluded
      #
      # @param time The time to check
      # @param interval_start The beginning time of the interval to match against
      # @param interval_end The ending time of the interval to match against
      #
      def time_in_interval? (time, interval_start, interval_end)
        time >= interval_start && time < interval_end
      end

      ##
      # Check if there is an occurrence of a schedule that contains a time interval
      #
      # @param schedule The schedule
      # @param interval_start The beginning Time of the interval
      # @param interval_end The ending Time of the interval
      # @return true if the interval falls within an occurrence of the schedule, otherwise false
      #
      def interval_in_schedule?(availabilities, interval_start, interval_end)

        # Check if interval_start and interval_end falls within any occurrence
        return false if(!time_in_schedule?(availabilities,interval_start) || !time_in_schedule?(availabilities,interval_end))

        contains = false
        
        # Check if both interval_start and interval_end falls within the SAME occurrence
        availabilities.each do |availability|
          schedule = IceCube::Schedule.from_yaml(availability.schedule)
          between = schedule.occurrences_between(interval_start, interval_end, spans: true)

          between.each do |oc|
            oc_end = (oc + schedule.duration) || schedule.end_time
            contains = true if (time_in_interval?(interval_start,oc,oc_end) && time_in_interval?(interval_end,oc,oc_end))
            break if contains
          end
        end

        contains
      end

      ##
      # Check if there is an occurrence of a schedule that contains a time
      # @param schedule The schedule
      # @param time The time
      # @return true if the time falls within an occurrence of the schedule, otherwise false
      #
      def time_in_schedule?(availabilities, time)
        contains = false
        availabilities.each do |availability|
          schedule = IceCube::Schedule.from_yaml(availability.schedule)
          contains = true if schedule.occurring_at? time
          break if contains
        end
        contains
      end

      ##
      # Returns an array of sub-intervals given another array of intervals, which are the overlapping insersections of each-others.
      #
      # @param intervals an array of intervals
      # @return an array of subintervals, sorted by start_time
      #
      # An interval is defined as a hash with at least the following fields: `time_from` and `end_time`. An interval may contain more
      # fields. In that case, it's suggested to give a block with the instructions to correctly merge two intervals when needed.
      #
      # e.g: given these 7 intervals
      #   |------|    |---|       |----------|
      #      |---|          |--|
      #      |------|       |--|      |-------------|
      #   the output is an array containing these 8 intervals:
      #   |--|   |--| |---| |--|  |---|      |------|
      #      |---|                    |------|
      #   the number of subintervals may increase or decrease because some intervals may be split, while
      #   some others may be merged.
      #
      # If a block is given, it's called before merging two intervals. The block should provide instructions to merge intervals, and should return the merged fields in a hash
      def subintervals(intervals, &block)
        raise ArgumentError.new('intervals must be an array') unless intervals.is_a? Array

        steps = [] # Steps will be extracted from intervals
        subintervals = [] # The output
        last_time = nil
        last_attrs = nil
        started_count = 0 # The number of intervals opened inside the cycle

        # Extract start times and end times from intervals, and create steps
        intervals.each do |el|
          begin
            ts = el[:start_time].to_time
            te = el[:end_time].to_time
          rescue NoMethodError
            raise ArgumentError.new('intervals must define :start_time and :end_time as Time or Date')
          end
          attrs = el.clone
          attrs.delete(:start_time)
          attrs.delete(:end_time)
          steps << { opening: 1, time: el[:start_time], attrs: attrs } # Start step
          steps << { opening: -1, time: el[:end_time], attrs: attrs.clone } # End step
        end

        # Sort steps by time (and opening if time is the same)
        steps.sort! do |a,b|
          diff = a[:time] <=> b[:time]
          diff = a[:opening] <=> b[:opening] if (diff == 0)
          diff
        end

        # Iterate over steps
        steps.each do |step|
          if (started_count == 0)
            last_time = step[:time]
            last_attrs = step[:attrs]
          else
            if(step[:time] > last_time)
              subintervals << ({
                start_time: last_time,
                end_time: step[:time]
              }.merge(last_attrs))

              last_time = step[:time]
            end

            if block_given?
              last_attrs = block.call(last_attrs.clone, step[:attrs],(step[:opening] == 1 ? :open : :close))
            else
              last_attrs = step[:attrs]
            end
          end

          # Update started_count
          started_count += step[:opening]
        end

        subintervals
      end

    end
  end
end
