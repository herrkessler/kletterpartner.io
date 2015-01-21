class Site
  include DataMapper::Resource

  property :id, Serial

  property :title, String, :required => true, :length => 128
  property :description, Text, :lazy => [ :show ]

  property :street, String, :lazy => [ :show ]
  property :zip, String, :lazy => [ :show ]
  property :town, String, :lazy => [ :show ]

  property :lat, String
  property :lng, String

  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  has n, :users, :through => Resource

  before :save do

    full_address = self.street, self.zip, self.town

    print full_address

    data = Geokit::Geocoders::GoogleGeocoder.geocode full_address.to_s
    self.lat = data.lat
    self.lng = data.lng

  end

end