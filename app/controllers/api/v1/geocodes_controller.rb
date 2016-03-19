class Api::V1::GeocodesController < Api::ApiController

  before_action :authenticate
  #before_action :validate_rpm

  def read

    latitude = params[:latitude]
    longitude = params[:longitude]
    type = params[:type]

    # Prepare request
    api_key = ENV['GOOGLE_API_KEY']
    content_type = "Content-Type: application/json"
    url = "https://maps.googleapis.com/maps/api/geocode/json?key=#{api_key}&latlng=#{latitude},#{longitude}"
    url = URI(url)
    req = Net::HTTP::Get.new(url, initheader = {'Content-Type' =>'application/json'})
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true

    place = 'unknown'
    res.start do |http|
      resp = http.request(req)
      json = JSON.parse(resp.body)
      if json && json['status'] == 'OK' && json['results'][0]['address_components'] && json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == type }
        place = json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == type }
        if place[0]
          place = place[0]['long_name']
          place = place.downcase.tr(" ", "-")
        end
      end
    end

    if label
      render json: {place: place}, status: :ok
    else
      render json: {place: 'unknown'}, status: :unprocessable_entity
    end
  end

  private
    def geocodes_params
      params.require(:geocode).permit(:latitude, :longitude, :type)
    end

end
