require 'venice'

## This task is triggered each day to check if a subscription is renewed or not?
# Expired subscriptions are also updated in database.
# This is just basic implementation & could vary based on different cases.
class ExpireUpdateSubscriptions
  @queue = :high

  def self.perform
    users = User.where { end_time < DateTime.now }
                .exclude(transaction_id: nil)
                .exclude(receipt_data: nil)
                .not_deleted
                .all
    users.each { |u| verify(u) unless u.blank? }
  end

  def self.verify(user)
    params = {}
    params[:user_id] = user.id
    params[:receipt_data] = user.receipt_data
    manager = AppleManager.new(params)
    manager.verify_receipt
  end
end
