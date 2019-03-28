# Helper methods defined here can be accessed in any controller or view in the application

module AppleInappSample
  class App
    module UsersHelper
      def validate_subscription(params)
        validate_fetch(params)
        raise StandardError, 'Receipt data is not provided!' if params[:receipt_data].nil?
      end

      def validate_fetch(params)
        raise StandardError, 'Parameters not provided!' if params.nil?
        raise StandardError, 'User ID is not provided!' if params[:user_id].nil?

        user = User[params[:user_id]]
        raise StandardError, 'User for provided ID not found!' unless user
      end
    end

    helpers UsersHelper
  end
end
