class Api::V1::FilesController < Api::ApiController

  before_action :authenticate

  respond_to :json

  def upload # replace by create or read

    require 'digest/md5'

    b64_data = params[:data]


    md5 = Digest::MD5.hexdigest(b64_data)

    # Check if already in DB
    @image = Image.where(md5: md5).first

    if @image.blank?

      @image = {md5: md5, label: nil}

      # Prepare request
      url = "https://vision.googleapis.com/v1/images:annotate?key=#{ENV['GOOGLE_API_KEY']}"
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

      label = nil
      res.start do |http|
        resp = http.request(req)
        json = JSON.parse(resp.body)
        if json && json["responses"] && json["responses"][0]["labelAnnotations"] && json["responses"][0]["labelAnnotations"][0]["description"]
          label = json['responses'][0]['labelAnnotations'][0]['description']
        end
      end

      @image = Image.find_or_create_by(md5: md5, label: label)

    end

    render json: @image, status: :ok
  end

  private
    def files_params
      params.require(:file).permit(:data)
    end

end
