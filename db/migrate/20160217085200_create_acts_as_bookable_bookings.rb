class CreateActsAsBookableBookings < ActiveRecord::Migration[6.0]
  def change
    create_table :acts_as_bookable_bookings do |t|
      t.references :bookable, polymorphic: true, index: {name: "index_acts_as_bookable_bookings_bookable"}
      t.references :booker, polymorphic: true, index: {name: "index_acts_as_bookable_bookings_booker"}
      t.column :amount, :integer, default: 1
      t.column :pricing, :json
      t.column :paid, :boolean
      t.column :status, :integer, default: 0
      t.column :start_time, :datetime
      t.column :end_time, :datetime
      t.column :time, :datetime
      t.column :message, :text
      t.datetime :created_at
    end
  end
end
