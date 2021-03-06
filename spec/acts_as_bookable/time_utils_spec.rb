require 'spec_helper'

describe 'ActsAsBookable::TimeUtils' do

  describe '#time_in_interval?' do
    before :each do
      @interval_start = Time.now
      @interval_end = Time.now + 1.hour
    end

    describe 'returns true' do
      it 'when time is the interval_start' do
        time = @interval_start
        expect(ActsAsBookable::TimeUtils.time_in_interval?(time,@interval_start,@interval_end)).to eq true
      end

      it 'when time is bewteen interval_start and interval_end' do
        time = @interval_start + 5.minutes
        expect(ActsAsBookable::TimeUtils.time_in_interval?(time,@interval_start,@interval_end)).to eq true
      end

      it 'when time is very close to interval end' do
        time = @interval_end - 1.second
        expect(ActsAsBookable::TimeUtils.time_in_interval?(time,@interval_start,@interval_end)).to eq true
      end

    end

    describe 'returns false' do
      it 'when time is before interval_start' do
        time = @interval_start - 1.second
        expect(ActsAsBookable::TimeUtils.time_in_interval?(time,@interval_start,@interval_end)).to eq false
      end

      it 'when time is after interval_end' do
        time = @interval_end + 1.second
        expect(ActsAsBookable::TimeUtils.time_in_interval?(time,@interval_start,@interval_end)).to eq false
      end

      it 'when time is interval_end' do
        time = @interval_end
        expect(ActsAsBookable::TimeUtils.time_in_interval?(time,@interval_start,@interval_end)).to eq false
      end
    end
  end

  describe '#interval_in_schedule?' do
    before :each do
      @day0 = '2016-01-05'.to_date.to_time
      @schedule = IceCube::Schedule.new(@day0,duration: 1.day)
      @schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(1,3,5,7)
    end

    describe 'returns true' do
      it 'when range starts and ends in the middle of an occurrence' do
        start_time = @day0 + 1.hour
        end_time = @day0 + 3.hours
        expect(ActsAsBookable::TimeUtils.interval_in_schedule?(@schedule,start_time,end_time)).to eq true
      end

      it 'when range starts and ends in the middle of another occurrence' do
        start_time = @day0 + 2.days + 1.hour
        end_time = @day0 + 2.days + 3.hours
        expect(ActsAsBookable::TimeUtils.interval_in_schedule?(@schedule,start_time,end_time)).to eq true
      end

      it 'when range starts at the beginning of an occurrence and ends at the end of the same occurence' do
        start_time = @day0
        end_time = @day0 + 1.day - 1.second
        expect(ActsAsBookable::TimeUtils.interval_in_schedule?(@schedule,start_time,end_time)).to eq true
      end
    end

    describe 'retuns false' do
      it 'when range starts and ends outside any occurrence' do
        start_time = '2016-01-15'.to_date
        end_time = start_time + 1.day
        expect(ActsAsBookable::TimeUtils.interval_in_schedule?(@schedule,start_time,end_time)).to eq false
      end

      it 'when range starts and ends outside any occurrence but contains an occurrence' do
        start_time = @day0 - 1.hour
        end_time = @day0 + 1.day + 1.hour
        expect(ActsAsBookable::TimeUtils.interval_in_schedule?(@schedule,start_time,end_time)).to eq false
      end

      it 'when range starts within an occurrence but ends outside it' do
        start_time = @day0 + 1.hour
        end_time = @day0 + 1.day + 1.hour
        expect(ActsAsBookable::TimeUtils.interval_in_schedule?(@schedule,start_time,end_time)).to eq false
      end

      it 'when range starts outside any occurrence but ends within an occurrence' do
        start_time = @day0 - 1.hour
        end_time = @day0 + 1.hour
        expect(ActsAsBookable::TimeUtils.interval_in_schedule?(@schedule,start_time,end_time)).to eq false
      end

      it 'when range starts within an occurrence and ends within a different occurrence' do
        start_time = @day0 + 1.hour
        end_time = @day0 + 2.days + 1.hour
        expect(ActsAsBookable::TimeUtils.interval_in_schedule?(@schedule,start_time,end_time)).to eq false
      end

      it 'when range starts within an occurrence and ends just after the end of the same occurrence' do
        start_time = @day0 + 1.hour
        end_time = @day0 + 1.day
        expect(ActsAsBookable::TimeUtils.interval_in_schedule?(@schedule,start_time,end_time)).to eq false
      end
    end
  end

  describe '#time_in_schedule?' do
    before :each do
      @day0 = '2016-01-05'.to_date
      @schedule = IceCube::Schedule.new(@day0,duration: 1.day)
      @schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(1,3,5,7)
    end

    describe 'returns true' do
      it 'when time is at the beginning of an occurrence' do
        time = @day0
        expect(ActsAsBookable::TimeUtils.time_in_schedule?(@schedule,time)).to eq true
      end

      it 'when time is in the middle of an occurrence' do
        time = @day0 + 5.hours
        expect(ActsAsBookable::TimeUtils.time_in_schedule?(@schedule,time)).to eq true
      end

      it 'when time is at the end of an occurrence' do
        time = @day0 + 1.day - 1.second
        expect(ActsAsBookable::TimeUtils.time_in_schedule?(@schedule, time)).to eq true
      end
    end

    describe 'retuns false' do
      it 'when time is outside an occurrence' do
        time = '2016-01-15'.to_date
        expect(ActsAsBookable::TimeUtils.time_in_schedule?(@schedule, time)).to eq false
      end

      it 'when time is close to the end of an occurrence, but outside it' do
        time = @day0 + 1.day
        expect(ActsAsBookable::TimeUtils.time_in_schedule?(@schedule, time)).to eq false
      end

      it 'when time is close to the beginning of an occurrence, but outside it' do
        time = @day0 + 2.days - 1.second
      end
    end
  end

  describe '#subintervals' do
    before :each do
      @time = Time.now
    end

    it 'returns ArgumentError if called without an array' do
      expect{ ActsAsBookable::TimeUtils.subintervals(1) }.to raise_error ArgumentError
    end

    it 'returns ArgumentError if an interval has no start_time or end_time' do
      intervals = [
        {start_time: @time, end_time: @time + 1.hour},
        {start_time: @time}
      ]
      expect{ ActsAsBookable::TimeUtils.subintervals(1) }.to raise_error ArgumentError
      intervals = [
        {start_time: @time, end_time: @time + 1.hour},
        {end_time: @time}
      ]
      expect{ ActsAsBookable::TimeUtils.subintervals(1) }.to raise_error ArgumentError
    end

    it 'returns ArgumentError if start_time or end_time is not a Time or Date' do
      intervals = [
        {start_time: @time, end_time: 1}
      ]
      expect{ ActsAsBookable::TimeUtils.subintervals(1) }.to raise_error ArgumentError
      intervals = [
        {start_time: 2, end_time: @time + 1.hour}
      ]
      expect{ ActsAsBookable::TimeUtils.subintervals(1) }.to raise_error ArgumentError
    end

    it 'returns empty array if input is an empty array' do
      expect(ActsAsBookable::TimeUtils.subintervals([])).to eq []
    end

    # |----|
    # =>
    # |----|
    it 'returns a copy of the same interval if input is a single interval' do
      intervals = [
        {start_time: @time, end_time: @time + 1.hour}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals)
      expect(subintervals.length).to eq 1
      expect(subintervals[0][:start_time]).to eq intervals[0][:start_time]
      expect(subintervals[0][:end_time]).to eq intervals[0][:end_time]
    end

    # |----| |----| |----|
    # =>
    # |----| |----| |----|
    it 'returns a copy of the same intervals if they are all separated' do
      intervals = [
        {start_time: @time, end_time: @time + 1.hour},
        {start_time: @time + 2.hours, end_time: @time + 3.hours},
        {start_time: @time + 4.hours, end_time: @time + 5.hours}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals)
      expect(subintervals.length).to eq 3
      (0..2).each do |i|
        expect(subintervals[i][:start_time]).to eq intervals[i][:start_time]
        expect(subintervals[i][:end_time]).to eq intervals[i][:end_time]
      end
    end

    #               |----|
    #        |----|
    # |----|
    # =>
    # |----|
    #        |----|
    #               |----|
    it 'returns the sub-intervals sorted' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      time3 = @time + 3.hours
      time4 = @time + 4.hours
      time5 = @time + 5.hours
      time6 = @time + 6.hours

      intervals = [
        {start_time: time4, end_time: time5},
        {start_time: time2, end_time: time3},
        {start_time: time0, end_time: time1}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals)
      expect(subintervals.length).to eq 3
      expect(subintervals[0][:start_time]).to eq time0
      expect(subintervals[0][:end_time]).to eq time1
      expect(subintervals[1][:start_time]).to eq time2
      expect(subintervals[1][:end_time]).to eq time3
      expect(subintervals[2][:start_time]).to eq time4
      expect(subintervals[2][:end_time]).to eq time5
    end

    # |----|
    # |----|
    # |----|
    # =>
    # |----|
    it 'merges intervals if they have same start_time and end_time' do
      intervals = [
        {start_time: @time, end_time: @time + 1.hour},
        {start_time: @time, end_time: @time + 1.hour},
        {start_time: @time, end_time: @time + 1.hour}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals)
      expect(subintervals.length).to eq 1
      expect(subintervals[0][:start_time]).to eq intervals[0][:start_time]
      expect(subintervals[0][:end_time]).to eq intervals[0][:end_time]
    end

    # |---|
    # |------|
    # =>
    # |---|
    #     |--|
    it 'returns two intervals if input is 2 intervals with same start_time and different end_time' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      intervals = [
        {start_time: time0, end_time: time1},
        {start_time: time0, end_time: time2}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals)
      expect(subintervals.length).to eq 2
      expect(subintervals[0][:start_time]).to eq time0
      expect(subintervals[0][:end_time]).to eq time1
      expect(subintervals[1][:start_time]).to eq time1
      expect(subintervals[1][:end_time]).to eq time2
    end

    # |------|
    #    |---|
    # =>
    # |--|
    #    |---|
    it 'returns two intervals if input is 2 intervals with same end_time and different start_time' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      intervals = [
        {start_time: time0, end_time: time2},
        {start_time: time1, end_time: time2}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals)
      expect(subintervals.length).to eq 2
      expect(subintervals[0][:start_time]).to eq time0
      expect(subintervals[0][:end_time]).to eq time1
      expect(subintervals[1][:start_time]).to eq time1
      expect(subintervals[1][:end_time]).to eq time2
    end

    # |---------|
    #    |---|
    # =>
    # |--|
    #    |---|
    #        |--|
    it 'returns three intervals if one includes another' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      time3 = @time + 3.hours
      intervals = [
        {start_time: time0, end_time: time3},
        {start_time: time1, end_time: time2}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals)
      expect(subintervals.length).to eq 3
      expect(subintervals[0][:start_time]).to eq time0
      expect(subintervals[0][:end_time]).to eq time1
      expect(subintervals[1][:start_time]).to eq time1
      expect(subintervals[1][:end_time]).to eq time2
      expect(subintervals[2][:start_time]).to eq time2
      expect(subintervals[2][:end_time]).to eq time3
    end

    # |---2---|
    #     |------4------|
    # |----3------|
    #                      |----1----|
    #                      |----8----|
    # =>
    # |-5-|
    #     |-9-|
    #         |-7-|
    #             |--4--|
    #                      |----9----|
    it 'correctly merges interval attributes' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      time3 = @time + 3.hours
      time4 = @time + 4.hours
      time5 = @time + 5.hours
      time6 = @time + 6.hours
      intervals = [
        {start_time: time0, end_time: time2, attr: 2},
        {start_time: time1, end_time: time4, attr: 4},
        {start_time: time0, end_time: time3, attr: 3},
        {start_time: time5, end_time: time6, attr: 1},
        {start_time: time5, end_time: time6, attr: 8}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals) do |a,b,op|
          if op == :open
            res = {attr: a[:attr] + b[:attr]}
          end
          if op == :close
            res = {attr: a[:attr] - b[:attr]}
          end
          res
      end
      expect(subintervals.length).to eq 5
      expect(subintervals[0][:start_time]).to eq time0
      expect(subintervals[0][:end_time]).to eq time1
      expect(subintervals[0][:attr]).to eq 5
      expect(subintervals[1][:start_time]).to eq time1
      expect(subintervals[1][:end_time]).to eq time2
      expect(subintervals[1][:attr]).to eq 9
      expect(subintervals[2][:start_time]).to eq time2
      expect(subintervals[2][:end_time]).to eq time3
      expect(subintervals[2][:attr]).to eq 7
      expect(subintervals[3][:start_time]).to eq time3
      expect(subintervals[3][:end_time]).to eq time4
      expect(subintervals[3][:attr]).to eq 4
      expect(subintervals[4][:start_time]).to eq time5
      expect(subintervals[4][:end_time]).to eq time6
      expect(subintervals[4][:attr]).to eq 9
    end

    # |---2---|
    #     |------4------|
    # |----3------|
    #                      |----1----|
    #                      |----8----|
    # =>
    # |-5-|
    #     |-9-|
    #         |-7-|
    #             |--4--|
    #                      |----9----|
    it 'correctly merges interval attributes handling dates and times' do
      time0 = Date.today.to_time
      time1 = time0 + 1
      time2 = time0 + 2
      time3 = time0 + 3
      time4 = time0 + 4.days + 1.hours
      time5 = time0 + 5.days + 1.hours
      time6 = time0 + 6.days + 1.hours
      intervals = [
        {start_time: time0, end_time: time2, attr: 2},
        {start_time: time1, end_time: time4, attr: 4},
        {start_time: time0, end_time: time3, attr: 3},
        {start_time: time5, end_time: time6, attr: 1},
        {start_time: time5, end_time: time6, attr: 8}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals) do |a,b,op|
          if op == :open
            res = {attr: a[:attr] + b[:attr]}
          end
          if op == :close
            res = {attr: a[:attr] - b[:attr]}
          end
          res
      end
      expect(subintervals.length).to eq 5
      expect(subintervals[0][:start_time]).to eq time0
      expect(subintervals[0][:end_time]).to eq time1
      expect(subintervals[0][:attr]).to eq 5
      expect(subintervals[1][:start_time]).to eq time1
      expect(subintervals[1][:end_time]).to eq time2
      expect(subintervals[1][:attr]).to eq 9
      expect(subintervals[2][:start_time]).to eq time2
      expect(subintervals[2][:end_time]).to eq time3
      expect(subintervals[2][:attr]).to eq 7
      expect(subintervals[3][:start_time]).to eq time3
      expect(subintervals[3][:end_time]).to eq time4
      expect(subintervals[3][:attr]).to eq 4
      expect(subintervals[4][:start_time]).to eq time5
      expect(subintervals[4][:end_time]).to eq time6
      expect(subintervals[4][:attr]).to eq 9
    end

    # |---2---|
    #         |---4---|
    # |---3---|
    #         |---5---|
    # |---1---|
    #         |---1---|
    # =>
    # |---6---|
    #         |---10---|
    it 'merges 3 intervals partially matching' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      intervals = [
        {start_time: time0, end_time: time1, attr: 2},
        {start_time: time1, end_time: time2, attr: 4},
        {start_time: time0, end_time: time1, attr: 3},
        {start_time: time1, end_time: time2, attr: 5},
        {start_time: time0, end_time: time1, attr: 1},
        {start_time: time1, end_time: time2, attr: 1}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals) do |a,b,op|
          if op == :open
            res = {attr: a[:attr] + b[:attr]}
          end
          if op == :close
            res = {attr: a[:attr] - b[:attr]}
          end
          res
      end
      expect(subintervals.length).to eq 2
      expect(subintervals[0][:start_time]).to eq time0
      expect(subintervals[0][:end_time]).to eq time1
      expect(subintervals[0][:attr]).to eq 6
      expect(subintervals[1][:start_time]).to eq time1
      expect(subintervals[1][:end_time]).to eq time2
      expect(subintervals[1][:attr]).to eq 10
    end

    # |---2----|
    #     |----4---|
    # |---3----|
    #     |----5---|
    # |---1----|
    #     |----1---|
    # =>
    # |-6-|
    #     |-16-|
    #          |-10-|
    it 'merges and split 3 intervals partially matching' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      time3 = @time + 3.hours
      intervals = [
        {start_time: time0, end_time: time2, attr: 2},
        {start_time: time1, end_time: time3, attr: 4},
        {start_time: time0, end_time: time2, attr: 3},
        {start_time: time1, end_time: time3, attr: 5},
        {start_time: time0, end_time: time2, attr: 1},
        {start_time: time1, end_time: time3, attr: 1}
      ]
      subintervals = ActsAsBookable::TimeUtils.subintervals(intervals) do |a,b,op|
        if op == :open
          res = {attr: a[:attr] + b[:attr]}
        end
        if op == :close
          res = {attr: a[:attr] - b[:attr]}
        end
        res
      end
      expect(subintervals.length).to eq 3
      expect(subintervals[0][:start_time]).to eq time0
      expect(subintervals[0][:end_time]).to eq time1
      expect(subintervals[0][:attr]).to eq 6
      expect(subintervals[1][:start_time]).to eq time1
      expect(subintervals[1][:end_time]).to eq time2
      expect(subintervals[1][:attr]).to eq 16
      expect(subintervals[2][:start_time]).to eq time2
      expect(subintervals[2][:end_time]).to eq time3
      expect(subintervals[2][:attr]).to eq 10
    end
  end
end
