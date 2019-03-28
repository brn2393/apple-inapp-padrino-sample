require 'venice'

##
# Requires receipt_data & user_id as mandatory parameters to initialize.
# Handles basic database related tasks based on receipt status &
# updates user as premium or non-premium account holder.
class AppleManager

  @receipt_data = nil # receipt data received from iOS client
  @user_id = nil
  @environment = nil # environment if staging or PROD, received from Apple
  @enc_latest_receipt = nil # base64 encoded latest receipt from Apple

  attr_accessor :receipt_data
  attr_accessor :user_id
  attr_accessor :environment
  attr_accessor :enc_latest_receipt

  # initializing attributes with params values
  def initialize(params)
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  # function to verify encoded receipt
  def verify_receipt
    cloud_receipt = fetch_cloud_receipt
    raise StandardError, 'Receipt verification failed!' unless cloud_receipt

    status = cloud_receipt.original_json_response['status']
    case status
    # receipt is valid & can be used for database related tasks
    when 0 then proceed_with_receipt(cloud_receipt)
    # receipt is NOT valid
    when 21_000 then raise StandardError, 'Receipt could not be read.'
    when 21_002 then raise StandardError, 'Receipt data is malformed.'
    when 21_003 then raise StandardError, 'Receipt not authenticated.'
    when 21_004 then raise StandardError, 'Secret provided is invalid.'
    when 21_005 then raise StandardError, 'Apple servers are unreachable.'
    when 21_006 then raise StandardError, 'Receipt found to be invalid!'
    else
      raise StandardError, "Receipt is invalid with status #{status}!"
    end
  end

  def fetch_cloud_receipt
    receipt = nil
    # shared_secret is REQUIRED & it can be an environment variable.
    # exclude_old_transactions is optional & can be very useful in case you
    # don't want all transaction history to be included in response
    opts = { shared_secret: ENV['APP_STORE_SECRET'], exclude_old_transactions: true }
    begin
      receipt = Venice::Receipt.verify(@receipt_data, opts)
    rescue Venice::Receipt::VerificationError => ae
      raise StandardError, ae.message
    end

    receipt
  end

  def proceed_with_receipt(receipt)
    original_json_response = receipt.original_json_response
    @environment = original_json_response['environment']
    @enc_latest_receipt = original_json_response['latest_receipt']
    if receipt.try(:latest_expired_receipt_info)
      # can consider that the corresponding purchase has expired
      check_latest_expired_receipt(receipt)
    elsif receipt.try(:latest_receipt_info)
      # purchase is active & subscriptions might be renewed
      check_latest_receipts(receipt)
    end
  end

  def check_latest_expired_receipt(receipt)
    latest_expired_receipt = receipt.latest_expired_receipt_info
    return unless latest_expired_receipt

    update_db_with_expired
  end

  def check_latest_receipts(receipt)
    latest_receipts = receipt.latest_receipt_info
    return unless latest_receipts

    latest_receipts.each do |rec|
      is_expired = rec.expires_at < DateTime.now
      is_expired ? update_db_with_expired : update_db_with_latest(rec)
    end
  end

  # update user as non-premium account holder
  def update_db_with_expired
    user = User.find(id: @user_id)
    raise StandardError, 'User not found!' if user.blank?

    user.update(attibutes_expired_premium)
  end

  # update user as premium account holder
  def update_db_with_latest(receipt)
    user = User.find(id: @user_id)
    raise StandardError, 'User not found!' if user.blank?

    user.update(attibutes_new_premium(receipt))
  end

  def attibutes_new_premium(receipt)
    attributes = {}
    attributes[:environment] = @environment
    attributes[:receipt_data] = @enc_latest_receipt
    attributes[:transaction_id] = receipt.transaction_id
    attributes[:original_transaction_id] = receipt.original.transaction_id
    attributes[:premium_start_time] = receipt.purchased_at
    attributes[:premium_end_time] = receipt.expires_at
    attributes[:is_premium] = true

    attributes
  end

  def attibutes_expired_premium
    attributes = {}
    attributes[:environment] = nil
    attributes[:receipt_data] = nil
    attributes[:transaction_id] = nil
    attributes[:original_transaction_id] = nil
    attributes[:premium_start_time] = nil
    attributes[:premium_end_time] = nil
    attributes[:is_premium] = false

    attributes
  end
end
