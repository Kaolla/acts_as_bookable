class CreateActsAsBookableBookings < ActiveRecord::Migration[6.0]
  def change
    create_table :acts_as_bookable_bookings do |t|
      t.references :bookable, polymorphic: true, index: {name: "index_acts_as_bookable_bookings_bookable"}
      t.references :booker, polymorphic: true, index: {name: "index_acts_as_bookable_bookings_booker"}
      t.column :quantity, :integer, default: 1
      t.column :pricing, :json
      t.column :status, :integer, default: 0
      t.column :start_time, :datetime
      t.column :end_time, :datetime
      t.column :time, :datetime
      t.column :message, :text
      t.column :address, :string
      t.column :street, :string
      t.column :city, :string
      t.column :zipcode, :string
      t.column :state, :string
      t.column :country, :string
      t.column :latitude, :float
      t.column :longitude, :float
      t.datetime :created_at
    end
  end
end
