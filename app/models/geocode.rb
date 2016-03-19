class Geocode < ApplicationRecord

  validates_uniqueness_of :geocode, :scope => [:latitude, :longitude]

end
