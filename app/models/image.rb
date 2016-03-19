class Image < ApplicationRecord

  validates_uniqueness_of :md5

end
