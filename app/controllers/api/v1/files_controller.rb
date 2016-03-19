class Api::V1::FilesController < Api::ApiController

  before_action :authenticate

  respond_to :json

  def upload # replace by create or read

    require 'digest/md5'

    b64_data = params[:data]

    # Check if already in DB

    md5 = Digest::MD5.hexdigest(b64_data)


    # Prepare request
    api_key = ENV['GOOGLE_API_KEY']
    content_type = "Content-Type: application/json"
    url = "https://vision.googleapis.com/v1/images:annotate?key=#{api_key}"
    data = {
      "requests": [
        {
          "image": {
            "content": b64_data
          },
          "features": [
            {
              "type": "LABEL_DETECTION",
              "maxResults": 1
            }
          ]
        }
      ]
    }.to_json
    url = URI(url)
    req = Net::HTTP::Post.new(url, initheader = {'Content-Type' =>'application/json'})
    req.body = data
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true

    label = 'unknown'
    res.start do |http|
      resp = http.request(req)
      json = JSON.parse(resp.body)
      if json && json["responses"] && json["responses"][0]["labelAnnotations"] && json["responses"][0]["labelAnnotations"][0]["description"]
        label = json['responses'][0]['labelAnnotations'][0]['description']
        label = label.tr(" ", "-")
      end
    end

    # Create in DB

    if label
      render json: {label: label}, status: :ok
    else
      render json: {label: 'unknown'}, status: :unprocessable_entity
    end
  end

  private
    def files_params
      params.require(:file).permit(:data)
    end

end
