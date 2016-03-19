class Geocode < ApplicationRecord

  validates_uniqueness_of :latitude, :scope => [:longitude]

end
