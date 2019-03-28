AppleInappSample::App.controllers :users do
  get '/profile', with: :user_id do
    ret = {}
    begin
      validate_fetch(params)
      user = User[params[:user_id]]
      ret = { success: true, message: 'User found!', data: user.to_h }
    rescue StandardError => e
      status 400
      ret = { success: false, message: e.message }
    end

    ret.to_json
  end

  post '/verify_subscription/', csrf_protection: false do
    ret = {}
    begin
      validate_subscription(params)
      manager = AppleManager.new(params)
      manager.verify_receipt
      ret = { success: true, message: 'Subscription verified!' }
    rescue StandardError => ae
      status 400
      ret = { success: false, message: ae.message }
    end

    return ret.to_json
  end
end
