class Api::V1::GeocodesController < Api::ApiController

  before_action :authenticate

  respond_to :json

  def read

    latitude = '%.3f' % params[:latitude]
    longitude = '%.3f' % params[:longitude]

    # Check if already in DB
    @geocode = Geocode.where(latitude: latitude, longitude: longitude)

    if @geocode.blank?

      @geocode = {latitude: latitude, longitude: longitude, country: nil, locality: nil}

      # Prepare request
      url = "https://maps.googleapis.com/maps/api/geocode/json?key=#{ENV['GOOGLE_API_KEY']}&latlng=#{latitude},#{longitude}"
      url = URI(url)
      req = Net::HTTP::Get.new(url, initheader = {'Content-Type' =>'application/json'})
      res = Net::HTTP.new(url.host, url.port)
      res.use_ssl = true

      res.start do |http|
        resp = http.request(req)
        json = JSON.parse(resp.body)
        if json && json['status'] == 'OK' && json['results'][0]['address_components']
          if json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == 'locality' }
            place = json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == 'locality' }
            if place[0]
              @geocode[:locality] = place[0]['long_name']
            end
          end
          if  json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == 'country' }
            place = json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == 'country' }
            if place[0]
              @geocode[:country] = place[0]['long_name']
            end
          end
        end
      end

      @geocode = Geocode.create(@geocode)

    end

    render json: @geocode, status: :ok
  end

  private
    def geocodes_params
      params.require(:geocode).permit(:latitude, :longitude, :type)
    end

end
