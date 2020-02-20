class CreateActsAsBookableBookings < ActiveRecord::Migration[6.0]
  def change
    create_table :acts_as_bookable_bookings do |t|
      t.references :bookable, polymorphic: true, index: {name: "index_acts_as_bookable_bookings_bookable"}
      t.references :booker, polymorphic: true, index: {name: "index_acts_as_bookable_bookings_booker"}
      t.column :quantity, :integer, default: 1
      t.column :pricing, :jsonb
      t.column :serialized_bookable, :jsonb
      t.column :status, :integer, default: 0
      t.column :start_time, :datetime
      t.column :end_time, :datetime
      t.column :time, :datetime
      t.column :extra_billing_info, :string
      t.column :street, :string
      t.column :extra_address_field, :string
      t.column :city, :string
      t.column :zipcode, :string
      t.column :state, :string
      t.column :country, :string
      t.column :latitude, :float
      t.column :longitude, :float
      t.column :confirmed, :boolean
      t.column :refunded, :boolean
      t.datetime :paid_at
      t.datetime :refunded_at
      t.datetime :created_at
    end
  end
end
