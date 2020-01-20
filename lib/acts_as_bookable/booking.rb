module ActsAsBookable
  ##
  # Booking model. Store in database bookings made by bookers on bookables
  #
  class Booking < ::ActiveRecord::Base
    self.table_name = 'acts_as_bookable_bookings'

    enum status: [:draft, :pending, :accepted, :rejected, :completed]
    belongs_to :bookable, polymorphic: true
    belongs_to :booker,   polymorphic: true

    validates_presence_of :bookable
    validates_presence_of :booker
    validate  :bookable_must_be_bookable,
              :booker_must_be_booker

    validates :quantity, numericality: { only_interger: true, greater_than: 0 }, allow_blank: true

    ##
    # Handy scopes for bookings
    #
    # Status
    scope :saved,       -> { where.not(status: 'draft') }
    scope :draft,       -> { where(status: 'draft') }
    scope :pending,     -> { where(status: 'pending') }
    scope :accepted,    -> { where(status: 'accepted') }
    scope :rejected,    -> { where(status: 'rejected') }
    scope :completed,   -> { where(status: 'completed') }
    scope :confirmed,   -> { where(confirmed: 'true') }
    scope :paid,        -> { where(paid: 'true') }
    scope :refunded,    -> { where(refunded: 'true') }
    # Time
    scope :weekly, -> { saved.completed.where(created_at: Time.now.last_week..Time.now) }
    scope :monthly, -> { saved.completed.where(created_at: Time.now.last_month..Time.now) }
    scope :quarterly, -> { saved.completed.where(created_at: Time.now.months_ago(3)..Time.now) }
    scope :half_yearly, -> { saved.completed.where(created_at: Time.now.months_ago(6)..Time.now) }
    scope :yearly, -> { saved.completed.where(created_at: Time.now.years_ago(1)..Time.now) }

    ##
    # Retrieves overlapped bookings, given a bookable and some booking options
    #
    scope :overlapped, ->(bookable,opts) {
      query = where(bookable_id: bookable.id)

      # Time options
      if(opts[:time].present?)
        query = DBUtils.time_comparison(query,'time','=',opts[:time])
      end
      if(opts[:start_time].present?)
        query = DBUtils.time_comparison(query,'end_time', '>=', opts[:start_time])
      end
      if(opts[:end_time].present?)
        query = DBUtils.time_comparison(query,'start_time', '<', opts[:end_time])
      end
      query
    }

    # ###### ###### ###### ###### ######
    # Geocode
    # ###### ###### ###### ###### ######
    geocoded_by :address
    # before_validation :geocode, if: :will_save_change_to_address?
    after_validation :geocode, if: :address_changed?

    def address
      [street, city, zipcode, state].compact.join(", ")
    end

    def address_changed?
      street_changed? || city_changed? || zipcode_changed? || state_changed?
    end

    private
      ##
      # Validation method. Check if the bookable resource is actually bookable
      #
      def bookable_must_be_bookable
        if bookable.present? && !bookable.class.bookable?
          errors.add(:bookable, T.er('booking.bookable_must_be_bookable', model: bookable.class.to_s))
        end
      end

      ##
      # Validation method. Check if the booker model is actually a booker
      #
      def booker_must_be_booker
        if booker.present? && !booker.class.booker?
          errors.add(:booker, T.er('booking.booker_must_be_booker', model: booker.class.to_s))
        end
      end
  end
end
