class Api::ApiController < ActionController::Base

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @user = User.where(api_key: token).first
    end
  end

  #def validate_rpm
  #  if ApiRpmStore.threshold?(@user.id, @user.api_rpm) # 10 request per min
  #    render json: { help: 'pj@bergeron.io' }, status: :too_many_requests
  #    return false
  #  end
  #end

end