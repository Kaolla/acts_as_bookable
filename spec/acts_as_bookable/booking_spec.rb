require 'spec_helper'

describe 'Booking model' do
  before(:each) do
    @booking = ActsAsBookable::Booking.new(quantity: 2)
    @booker = create(:booker)
    @bookable = create(:bookable)
    @booking.booker = @booker
    @booking.bookable = @bookable
  end

  it 'should be valid with all required fields set' do
    expect(@booking).to be_valid
  end

  it 'should save a booking' do
    expect(@booking.save).to be_truthy
  end

  it 'should not be valid without a booker' do
    @booking.booker = nil
    expect(@booking).not_to be_valid
  end

  it 'should not be valid without a bookable' do
    @booking.bookable = nil
    expect(@booking).not_to be_valid
  end

  it 'should not be valid if booking.booker.booker? is false' do
    not_booker = Generic.create(name: 'New generic model')
    @booking.booker = not_booker
    expect(@booking).not_to be_valid
    expect(@booking.errors.messages[:booker]).to be_present
    expect(@booking.errors.messages[:booker][0]).to include "Generic"
    expect(@booking.errors.messages).not_to include "missing translation"
  end

  it 'should not be valid if booking.bookable.bookable? is false' do
    bookable = Generic.create(name: 'New generic model')
    @booking.bookable = bookable
    expect(@booking).not_to be_valid
    expect(@booking.errors.messages[:bookable]).to be_present
    expect(@booking.errors.messages[:bookable][0]).to include "Generic"
    expect(@booking.errors.messages).not_to include "missing translation"
  end

  it 'should belong to booker' do
    expect(@booking.booker.id).to eq @booker.id
  end

  it 'should belong to bookable' do
    expect(@booking.bookable.id).to eq @bookable.id
  end

  describe "overlapped scope" do

    describe "without time" do
      it "returns a booking without checking the time" do
        time = Date.today.to_time
        booking = ActsAsBookable::Booking.create!(start_time: nil, end_time: nil, time: time, bookable: @bookable, booker: @booker)
        opts = {}
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 1
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts)[0].id).to eq booking.id
      end

      it "returns all the bookings without checking the time" do
        booking1 = ActsAsBookable::Booking.create!(start_time: nil, end_time: nil, time: Time.now, bookable: @bookable, booker: @booker)
        booking2 = ActsAsBookable::Booking.create!(start_time: Time.now, end_time: Time.now + 3.hours, time: nil, bookable: @bookable, booker: @booker)
        booking3 = ActsAsBookable::Booking.create!(start_time: Time.now - 10.days, end_time: Time.now - 9.days, time: nil, bookable: @bookable, booker: @booker)
        opts = {}
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 3
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[0].id).to eq booking1.id
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[1].id).to eq booking2.id
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[2].id).to eq booking3.id
      end
    end

    describe "with fixed time" do
      it "returns overlapped booking" do
        time = Date.today.to_time
        booking = ActsAsBookable::Booking.create!(start_time: nil, end_time: nil, time: time, bookable: @bookable, booker: @booker)
        opts = {time: time}
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 1
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts)[0].id).to eq booking.id
      end

      it "returns all the overlapped bookings" do
        time = Date.today.to_time
        booking1 = ActsAsBookable::Booking.create!(start_time: nil, end_time: nil, time: time, bookable: @bookable, booker: @booker)
        booking2 = ActsAsBookable::Booking.create!(start_time: nil, end_time: nil, time: time, bookable: @bookable, booker: @booker)
        booking3 = ActsAsBookable::Booking.create!(start_time: nil, end_time: nil, time: time + 1.hour, bookable: @bookable, booker: @booker)
        opts = {time: time}
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 2
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[0].id).to eq booking1.id
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[1].id).to eq booking2.id
      end

      it "returns no overlapped booking if time is wrong" do
        time = Date.today.to_time
        booking = ActsAsBookable::Booking.create!(start_time: nil, end_time: nil, time: time, bookable: @bookable, booker: @booker)
        opts = {time: (time + 1.hour)}
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 0
      end
    end

    describe "with time range" do
      it "returns overlapped booking" do
        start_time = Date.today.to_time
        end_time = Date.today.to_time + 10.hours
        booking = ActsAsBookable::Booking.create!(start_time: start_time, end_time: end_time, time: nil, bookable: @bookable, booker: @booker)
        opts = { start_time: start_time, end_time: end_time }
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 1
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts)[0].id).to eq booking.id
      end

      it "returns more overlapped bookings" do
        start_time = Date.today.to_time
        end_time = Date.today.to_time + 10.hours
        booking1 = ActsAsBookable::Booking.create!(start_time: start_time, end_time: end_time, time: nil, bookable: @bookable, booker: @booker)
        booking2 = ActsAsBookable::Booking.create!(start_time: start_time, end_time: end_time, time: nil, bookable: @bookable, booker: @booker)
        booking3 = ActsAsBookable::Booking.create!(start_time: start_time-10.days, end_time: end_time-10.days, time: nil, bookable: @bookable, booker: @booker)
        opts = { start_time: start_time, end_time: end_time }
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 2
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[0].id).to eq booking1.id
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[1].id).to eq booking2.id
      end

      it "doesn't return any booking if time is wrong" do
        start_time = Date.today.to_time
        end_time = Date.today.to_time + 10.hours
        booking = ActsAsBookable::Booking.create!(start_time: start_time - 10.days, end_time: end_time - 10.days, time: nil, bookable: @bookable, booker: @booker)
        opts = { start_time: start_time, end_time: end_time }
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 0
      end

      it "returns also a booking overlapping but with start_time outside interval" do
        start_time = Date.today.to_time
        end_time = Date.tomorrow.to_time
        booking = ActsAsBookable::Booking.create!(start_time: start_time - 10.hours, end_time: end_time, bookable: @bookable, booker: @booker)
        opts = { start_time: start_time, end_time: end_time }
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 1
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts)[0].id).to eq booking.id
      end

      it "returns also a booking overlapping but with end_time outside interval" do
        start_time = Date.today.to_time
        end_time = Date.tomorrow.to_time
        booking = ActsAsBookable::Booking.create!(start_time: start_time, end_time: end_time + 10.hours, bookable: @bookable, booker: @booker)
        opts = { start_time: start_time, end_time: end_time }
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 1
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts)[0].id).to eq booking.id
      end

      it "returns more overlapped bookings, some of them not completely overlapping" do
        start_time = Date.today.to_time
        end_time = Date.today.to_time + 10.hours
        booking1 = ActsAsBookable::Booking.create!(start_time: start_time - 5.hours, end_time: end_time - 5.hours, time: nil, bookable: @bookable, booker: @booker)
        booking2 = ActsAsBookable::Booking.create!(start_time: start_time + 5.hours, end_time: end_time + 5.hours, time: nil, bookable: @bookable, booker: @booker)
        booking3 = ActsAsBookable::Booking.create!(start_time: start_time + 2.hours, end_time: end_time - 2.hours, time: nil, bookable: @bookable, booker: @booker)
        booking4 = ActsAsBookable::Booking.create!(start_time: start_time-10.days, end_time: end_time-10.days, time: nil, bookable: @bookable, booker: @booker)
        booking4 = ActsAsBookable::Booking.create!(start_time: start_time+10.days, end_time: end_time+10.days, time: nil, bookable: @bookable, booker: @booker)
        opts = { start_time: start_time, end_time: end_time }
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).count).to eq 3
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[0].id).to eq booking1.id
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[1].id).to eq booking2.id
        expect(ActsAsBookable::Booking.overlapped(@bookable,opts).order(:id)[2].id).to eq booking3.id
      end

      describe "should handle limit cases" do
        before :each do
          @start_time = Date.today.to_time
          @end_time = Date.today.to_time + 10.hours

          @time_before_start = @start_time - 1.second
          @time_after_start = @start_time + 1.second
          @time_before_end = @end_time - 1.second
          @time_after_end = @end_time + 1.second

          @opts = { start_time: @start_time, end_time: @end_time }
        end

        it "excludes intervals with end before start_time and start after end_time" do
          booking1 = ActsAsBookable::Booking.create!(start_time: @start_time - 5.hours, end_time: @time_before_start, time: nil, bookable: @bookable, booker: @booker)
          booking2 = ActsAsBookable::Booking.create!(start_time: @time_after_end, end_time: @end_time + 5.hours, time: nil, bookable: @bookable, booker: @booker)
          expect(ActsAsBookable::Booking.overlapped(@bookable,@opts).count).to eq 0
        end

        it "excludes intervals with start matching exactly with end_time" do
          booking1 = ActsAsBookable::Booking.create!(start_time: @end_time, end_time: @end_time + 2.hours, time: nil, bookable: @bookable, booker: @booker)
          expect(ActsAsBookable::Booking.overlapped(@bookable,@opts).count).to eq 0
        end

        it "includes intervals with end after start_time" do
          booking1 = ActsAsBookable::Booking.create!(start_time: @start_time - 5.hours, end_time: @time_after_start, time: nil, bookable: @bookable, booker: @booker)
          expect(ActsAsBookable::Booking.overlapped(@bookable,@opts).count).to eq 1
        end

        it "includes intervals with end exactly at start_time" do
          booking1 = ActsAsBookable::Booking.create!(start_time: @start_time - 5.hours, end_time: @start_time, time: nil, bookable: @bookable, booker: @booker)
          expect(ActsAsBookable::Booking.overlapped(@bookable,@opts).count).to eq 1
        end
      end

      describe "should convert dates to times" do
        before :each do
          @start_time = Date.today
          @end_time = Date.tomorrow

          @time_before_start = @start_time - 1.second
          @time_after_start = @start_time + 1.second
          @time_before_end = @end_time - 1.second
          @time_after_end = @end_time + 1.second

          @opts = { start_time: @start_time, end_time: @end_time }
        end

        it "excludes intervals with end before start_time and start after end_time" do
          booking1 = ActsAsBookable::Booking.create!(start_time: @start_time - 5.hours, end_time: @time_before_start, time: nil, bookable: @bookable, booker: @booker)
          booking2 = ActsAsBookable::Booking.create!(start_time: @time_after_end, end_time: @end_time + 5.hours, time: nil, bookable: @bookable, booker: @booker)
          expect(ActsAsBookable::Booking.overlapped(@bookable,@opts).count).to eq 0
        end

        it "excludes intervals with start matching exactly with end_time" do
          booking1 = ActsAsBookable::Booking.create!(start_time: @end_time, end_time: @end_time + 2.hours, time: nil, bookable: @bookable, booker: @booker)
          expect(ActsAsBookable::Booking.overlapped(@bookable,@opts).count).to eq 0
        end

        it "includes intervals with end after start_time" do
          booking1 = ActsAsBookable::Booking.create!(start_time: @start_time - 5.hours, end_time: @time_after_start, time: nil, bookable: @bookable, booker: @booker)
          expect(ActsAsBookable::Booking.overlapped(@bookable,@opts).count).to eq 1
        end

        it "includes intervals with end exactly at start_time" do
          booking1 = ActsAsBookable::Booking.create!(start_time: @start_time - 5.hours, end_time: @start_time, time: nil, bookable: @bookable, booker: @booker)
          expect(ActsAsBookable::Booking.overlapped(@bookable,@opts).count).to eq 1
        end
      end
    end
  end
end
