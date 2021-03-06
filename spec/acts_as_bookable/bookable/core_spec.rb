require 'spec_helper'

describe 'Bookable model' do
  describe 'InstanceMethods' do
    it 'should add a method #check_availability! in instance-side' do
      @bookable = Bookable.new
      expect(@bookable).to respond_to :check_availability!
    end

    it 'should add a method #check_availability in instance-side' do
      @bookable = Bookable.new
      expect(@bookable).to respond_to :check_availability
    end

    it 'should add a method #validate_booking_options! in instance-side' do
      @bookable = Bookable.new
      expect(@bookable).to respond_to :validate_booking_options!
    end

    describe '#check_availability! and check_availability' do
      after(:each) do
        Bookable.booking_opts = {}
        Bookable.initialize_acts_as_bookable_core
      end

      describe 'whithout any constraint' do
        before(:each) do
          Bookable.booking_opts = {
            time_type: :none,
            capacity_type: :none
          }
          Bookable.initialize_acts_as_bookable_core
          @bookable = Bookable.create!(name: 'bookable')
        end

        it 'should be always available' do
          expect(@bookable.check_availability({})).to be_truthy
          expect(@bookable.check_availability!({})).to be_truthy
        end
      end
    end

    describe 'with time_type: :range' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :range,
          capacity_type: :none
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable', schedule: IceCube::Schedule.new('2016-01-01'.to_date, duration: 1.day))
        ## bookable the first and third day of the month
        @bookable.schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month([1,3])
        @bookable.save!
      end

      it 'should be available in bookable times' do
        time = '2016-01-01'.to_date
        endtime = time + 10.minutes
        expect(@bookable.check_availability!({start_time: time, end_time: endtime})).to be_truthy
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_truthy
      end

      it 'should not be available in not bookable times' do
        time = '2016-01-02'.to_date
        endtime = '2016-01-04'.to_date
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_falsy
        expect{ @bookable.check_availability!({start_time: time, end_time: endtime}) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!({start_time: time, end_time: endtime})
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include "the Bookable is not available from #{time.to_time} to #{endtime.to_time}"
        end
      end

      it 'should be bookable within a bookable time' do
        time = '2016-01-01'.to_date + 1.minute
        endtime = '2016-01-02'.to_date - 1.minute
        expect(@bookable.check_availability!({start_time: time, end_time: endtime})).to be_truthy
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_truthy
      end

      it 'should be bookable within a bookable time' do
        time = '2016-01-01'.to_date + 1.minute
        endtime = '2016-01-02'.to_date - 1.minute
        expect(@bookable.check_availability!({start_time: time, end_time: endtime})).to be_truthy
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_truthy
      end

      it 'should not be available when start_time is available, end_time is available but the availability is splitted in between' do
        time = '2016-01-01'.to_date + 1.minute
        endtime = '2016-01-03'.to_date + 1.minute
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_falsy
        expect{ @bookable.check_availability!({start_time: time, end_time: endtime}) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!({start_time: time, end_time: endtime})
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include "the Bookable is not available from #{time} to #{endtime}"
        end
      end
    end

    describe 'with time_type: :range and with bookable_across_occurrences: true' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :range,
          capacity_type: :none,
          bookable_across_occurrences: true
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable', schedule: IceCube::Schedule.new('2016-01-01'.to_date, duration: 1.day))
        ## bookable the first and third day of the month
        @bookable.schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month([1,3])
        @bookable.save!
      end

      it 'should be available in bookable times' do
        time = '2016-01-01'.to_date
        endtime = time + 10.minutes
        expect(@bookable.check_availability!({start_time: time, end_time: endtime})).to be_truthy
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_truthy
      end

      it 'should not be available in not bookable times' do
        time = '2016-01-02'.to_date
        endtime = '2016-01-04'.to_date
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_falsy
        expect{ @bookable.check_availability!({start_time: time, end_time: endtime}) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!({start_time: time, end_time: endtime})
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include "the Bookable is not available from #{time.to_time} to #{endtime.to_time}"
        end
      end

      it 'should be bookable within a bookable time' do
        time = '2016-01-01'.to_date + 1.minute
        endtime = '2016-01-02'.to_date - 1.minute
        expect(@bookable.check_availability!({start_time: time, end_time: endtime})).to be_truthy
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_truthy
      end

      it 'should be bookable within a bookable time' do
        time = '2016-01-01'.to_date + 1.minute
        endtime = '2016-01-02'.to_date - 1.minute
        expect(@bookable.check_availability!({start_time: time, end_time: endtime})).to be_truthy
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_truthy
      end

      it 'should be available when start_time is available, end_time is available and the availability is splitted in between' do
        time = '2016-01-01'.to_date + 1.minute
        endtime = '2016-01-03'.to_date + 1.minute
        expect(@bookable.check_availability({start_time: time, end_time: endtime})).to be_truthy
        expect(@bookable.check_availability!({start_time: time, end_time: endtime})).to be_truthy
      end
    end

    describe 'with time_type: :fixed' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :fixed,
          capacity_type: :none
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable', schedule: IceCube::Schedule.new('2016-01-01'.to_date))
        ## bookable the first and third day of the month, at 9AM
        @bookable.schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month([1,3]).hour_of_day(9)
        @bookable.save!
      end

      it 'should be available in available times' do
        time = '2016-01-01'.to_date + 9.hours
        expect(@bookable.check_availability(time: time)).to be_truthy
        expect(@bookable.check_availability!(time: time)).to be_truthy
        time = '2016-01-03'.to_date + 9.hours
        expect(@bookable.check_availability(time: time)).to be_truthy
        expect(@bookable.check_availability!(time: time)).to be_truthy
      end

      it 'should not be available in not bookable day' do
        time = '2016-01-02'.to_date
        expect(@bookable.check_availability(time: time)).to be_falsy
        expect{ @bookable.check_availability!(time: time) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!(time: time)
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include "the Bookable is not available at #{time}"
        end
      end


      it 'should not be available in bookable day but not bookable time' do
        time = '2016-01-02'.to_date + 10.hours
        expect(@bookable.check_availability(time: time)).to be_falsy
        expect{ @bookable.check_availability!(time: time) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!(time: time)
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include "the Bookable is not available at #{time}"
        end
      end

      it 'should not be available very close to a bookable time but not the exact second' do
        time = '2016-01-02'.to_date + 9.hours + 1.second
        expect(@bookable.check_availability(time: time)).to be_falsy
        expect{ @bookable.check_availability!(time: time) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!(time: time)
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include "the Bookable is not available at #{time}"
        end
      end
    end

    describe 'with capacity_type: :open' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :none,
          capacity_type: :open
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable', capacity: 4)
      end

      it 'should be available if quantity <= capacity' do
        (1..@bookable.capacity).each do |quantity|
          expect(@bookable.check_availability(quantity: quantity)).to be_truthy
          expect(@bookable.check_availability!(quantity: quantity)).to be_truthy
        end
      end

      it 'should not be available if quantity > capacity' do
        expect(@bookable.check_availability(quantity: @bookable.capacity + 1)).to be_falsy
        expect { @bookable.check_availability!(quantity: @bookable.capacity + 1) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!(quantity: @bookable.capacity + 1)
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include 'cannot be greater'
        end
      end

      it 'should be available if already booked but quantity <= conditional capacity' do
        booker = create(:booker)
        @bookable.be_booked!(booker, quantity: 2)
        (1..(@bookable.capacity - 2)).each do |quantity|
          expect(@bookable.check_availability(quantity: quantity)).to be_truthy
          expect(@bookable.check_availability!(quantity: quantity)).to be_truthy
        end
      end

      it 'should not be available if quantity <= capacity but already booked and quantity > conditional capacity' do
        booker = create(:booker)
        @bookable.be_booked!(booker, quantity: 2)
        quantity = @bookable.capacity - 2 + 1
        expect(@bookable.check_availability(quantity: quantity)).to be_falsy
        expect { @bookable.check_availability!(quantity: quantity) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!(quantity: quantity)
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include 'is fully booked'
        end
      end

      it 'should be available if quantity <= capacity and already booked and quantity > conditional capacity but overlappings are separated in time and space' do
        Bookable.booking_opts = {
          time_type: :range,
          capacity_type: :open,
          bookable_across_occurrences: true
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable', capacity: 4, schedule: IceCube::Schedule.new(Date.today, duration: 1.day))
        @bookable.schedule.add_recurrence_rule IceCube::Rule.daily
        @bookable.save!
        booker = create(:booker)
        @bookable.be_booked!(booker, quantity: 3, start_time: Date.today, end_time: Date.today + 8.hours)
        @bookable.be_booked!(booker, quantity: 3, start_time: Date.today + 8.hours, end_time: Date.today + 16.hours)
        @bookable.be_booked!(booker, quantity: 3, start_time: Date.today + 16.hours, end_time: Date.today + 24.hours)
        quantity = 1
        expect(@bookable.check_availability(quantity: quantity, start_time: Date.today, end_time: Date.today + 24.hours)).to be_truthy
      end

      it 'should not be available if quantity <= capacity and already booked and quantity > conditional capacity' do
        Bookable.booking_opts = {
          time_type: :range,
          capacity_type: :open,
          bookable_across_occurrences: true
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable', capacity: 4, schedule: IceCube::Schedule.new(Date.today, duration: 1.day))
        @bookable.schedule.add_recurrence_rule IceCube::Rule.daily
        @bookable.save!
        booker = create(:booker)
        @bookable.be_booked!(booker, quantity: 3, start_time: Date.today, end_time: Date.today + 8.hours)
        @bookable.be_booked!(booker, quantity: 3, start_time: Date.today + 8.hours, end_time: Date.today + 16.hours)
        @bookable.be_booked!(booker, quantity: 1, start_time: Date.today + 8.hours, end_time: Date.today + 24.hours)
        quantity = 2
        expect(@bookable.check_availability(quantity: quantity, start_time: Date.today, end_time: Date.today + 8.hours)).to be_truthy
        expect(@bookable.check_availability(quantity: quantity, start_time: Date.today + 8.hours, end_time: Date.today + 16.hours)).to be_truthy
        expect(@bookable.check_availability(quantity: quantity, start_time: Date.today + 16.hours, end_time: Date.today + 24.hours)).to be_truthy
        expect(@bookable.check_availability(quantity: quantity, start_time: Date.today, end_time: Date.today + 24.hours)).to be_truthy
      end
    end

    describe 'with capacity_type: :closed' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :none,
          capacity_type: :closed
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable', capacity: 4)
      end

      it 'should be available if quantity <= capacity' do
        (1..@bookable.capacity).each do |quantity|
          expect(@bookable.check_availability(quantity: quantity)).to be_truthy
          expect(@bookable.check_availability!(quantity: quantity)).to be_truthy
        end
      end

      it 'should not be available if quantity > capacity' do
        expect(@bookable.check_availability(quantity: @bookable.capacity + 1)).to be_falsy
        expect { @bookable.check_availability!(quantity: @bookable.capacity + 1) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!(quantity: @bookable.capacity + 1)
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include 'cannot be greater'
        end
      end

      it 'should not be available if already booked (even though quantity < capacity - overlapped quantitys)' do
        booker = create(:booker)
        @bookable.be_booked!(booker, quantity: 1)
        (1..(@bookable.capacity + 1)).each do |quantity|
          expect(@bookable.check_availability(quantity: quantity)).to be_falsy
          expect { @bookable.check_availability!(quantity: quantity) }.to raise_error ActsAsBookable::AvailabilityError
          begin
            @bookable.check_availability!(quantity: quantity)
          rescue ActsAsBookable::AvailabilityError => e
            if(quantity <= @bookable.capacity)
              expect(e.message).to include('is fully booked')
            else
              expect(e.message).to include('cannot be greater')
            end
          end
        end
      end
    end
  end

  describe 'classMethods' do
    before(:each) do
      Bookable.booking_opts = {}
      Bookable.initialize_acts_as_bookable_core
    end
    after(:each) do
      Bookable.booking_opts = {}
      Bookable.initialize_acts_as_bookable_core
    end

    describe 'self.initialize_acts_as_bookable_core' do
      describe '#set_options' do
        it 'preset options for room' do
          [:room,:event,:show].each do |p|
            Bookable.booking_opts = {preset: p}
            Bookable.initialize_acts_as_bookable_core
            expect(Bookable.booking_opts[:preset]).to eq p
            expect(Bookable.booking_opts[:time_type]).to be(:range).or be(:fixed).or be(:none)
            expect(Bookable.booking_opts[:capacity_type]).to be(:open).or be(:closed)
            expect(Bookable.booking_opts[:bookable_across_occurrences]).to be(true).or be(false)
          end
        end

        it 'fails when using an unknown preset' do
          Bookable.booking_opts = {preset: 'unknown'}
          expect{ Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
        end

        it 'correctly set undefined options' do
          Bookable.booking_opts = {}
          Bookable.initialize_acts_as_bookable_core
          expect(Bookable.booking_opts[:preset]).not_to be_present
          expect(Bookable.booking_opts[:date_type]).not_to be_present
          expect(Bookable.booking_opts[:time_type]).to be_present
          expect(Bookable.booking_opts[:location_type]).not_to be_present
          expect(Bookable.booking_opts[:capacity_type]).to be_present
          expect(Bookable.booking_opts[:bookable_across_occurrences]).not_to be_nil
        end

        it 'correctly merges options' do
          Bookable.booking_opts = {
            time_type: :range,
            capacity_type: :closed,
            bookable_across_occurrences: false
          }
          Bookable.initialize_acts_as_bookable_core
          expect(Bookable.booking_opts[:preset]).not_to be_present
          expect(Bookable.booking_opts[:date_type]).not_to be_present
          expect(Bookable.booking_opts[:time_type]).to be :range
          expect(Bookable.booking_opts[:location_type]).not_to be_present
          expect(Bookable.booking_opts[:capacity_type]).to be :closed
          expect(Bookable.booking_opts[:bookable_across_occurrences]).to be false
        end

        it 'should not allow unknown keys' do
          Bookable.booking_opts = {unknown: 'lol'}
          expect { Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
          begin
            Bookable.initialize_acts_as_bookable_core
          rescue ActsAsBookable::InitializationError => e
            expect(e.message).to include 'is not a valid option'
          end
        end

        it 'should not allow unknown values on :time_type' do
          Bookable.booking_opts = {time_type: :unknown}
          expect { Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
          begin
            Bookable.initialize_acts_as_bookable_core
          rescue ActsAsBookable::InitializationError => e
            expect(e.message).to include 'is not a valid value for time_type'
          end
        end

        it 'should not allow unknown values on :capacity_type' do
          Bookable.booking_opts = {capacity_type: :unknown}
          expect { Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
          begin
            Bookable.initialize_acts_as_bookable_core
          rescue ActsAsBookable::InitializationError => e
            expect(e.message).to include 'is not a valid value for capacity_type'
          end
        end

        it 'should not allow unknown values on bookable_across_occurrences' do
          Bookable.booking_opts = {bookable_across_occurrences: :unknown}
          expect { Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
          begin
            Bookable.initialize_acts_as_bookable_core
          rescue ActsAsBookable::InitializationError => e
            expect(e.message).to include 'is not a valid value for bookable_across_occurrences'
          end
        end
      end
    end

    describe 'self.validate_booking_options!' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :none,
          capacity_type: :none
        }
        @opts = {}
      end

      describe 'with capacity_type: :none and time_type: :none' do
        it 'validates with default options' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end
      end

      describe 'with time_type = ' do
        describe ':range' do
          before(:each) do
            Bookable.booking_opts[:time_type] = :range
            Bookable.initialize_acts_as_bookable_core
            @opts[:start_time] = Time.now + 1.hour
            @opts[:end_time] = Time.now + 4.hours
          end

          it 'validates with all options fields set' do
            expect(Bookable.validate_booking_options!(@opts)).to be_truthy
          end

          it 'requires start_time as Time' do
            @opts[:start_time] = nil
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
            @opts[:start_time] = 'String'
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end

          it 'requires end_time as Time' do
            @opts[:end_time] = nil
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
            @opts[:end_time] = 'String'
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end

          it 'doesn\'t accept a fixed time' do
            @opts[:time] = Time.now
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end
        end

        describe ':fixed' do
          before(:each) do
            Bookable.booking_opts[:time_type] = :fixed
            Bookable.initialize_acts_as_bookable_core
            @opts[:time] = Time.now + 1.hour
          end

          it 'validates with the right fields set' do
            expect(Bookable.validate_booking_options!(@opts)).to be_truthy
          end

          it 'requires date as Time' do
            @opts[:time] = nil
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
            @opts[:time] = 'String'
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end

          it 'doesn\'t accept start_time' do
            @opts[:start_time] = Time.now + 13
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end

          it 'doesn\'t accept end_time' do
            @opts[:end_time] = Time.now + 15
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end
        end

        describe ':none' do
          before(:each) do
            Bookable.initialize_acts_as_bookable_core
          end

          it 'doesn\'t accept time' do
            @opts[:time] = Time.now + 13
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end

          it 'doesn\'t accept start_time' do
            @opts[:start_time] = Time.now + 13
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end

          it 'doesn\'t accept end_time' do
            @opts[:end_time] = Time.now + 15
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end
        end
      end

      describe 'with capacity_type = ' do
        describe ':open' do
          before(:each) do
            Bookable.booking_opts[:capacity_type] = :open
            Bookable.initialize_acts_as_bookable_core
            @opts[:quantity] = 2
          end

          it 'validates with all options fields set' do
            expect(Bookable.validate_booking_options!(@opts)).to be_truthy
          end

          it 'requires :quantity as integer' do
            @opts[:quantity] = nil
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end
        end

        describe ':closed' do
          before(:each) do
            Bookable.booking_opts[:capacity_type] = :closed
            Bookable.initialize_acts_as_bookable_core
            @opts[:quantity] = 2
          end

          it 'validates with all options fields set' do
            expect(Bookable.validate_booking_options!(@opts)).to be_truthy
          end

          it 'requires :quantity as integer' do
            @opts[:quantity] = nil
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end
        end

        describe ':none' do
          before(:each) do
            Bookable.initialize_acts_as_bookable_core
          end

          it 'doesn\'t accept quantity' do
            @opts[:quantity] = 2.3
            expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          end
        end
      end
    end
  end
end
