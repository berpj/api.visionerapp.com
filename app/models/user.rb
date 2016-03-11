class User < ApplicationRecord

  before_create do |doc|
    doc.api_key = doc.generate_api_key
  end

  def generate_api_key
    begin
      token = SecureRandom.base64.tr('+/=', 'Qrt')
    end while User.exists?(api_key: token)
    token
  end

end
