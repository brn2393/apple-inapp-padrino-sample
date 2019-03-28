Sequel.migration do
  up do
    create_table :users do
      primary_key :id
      String      :username, unique: true, null: false
      String      :password, null: false

      TrueClass   :is_premium, default: false
      DateTime    :premium_start_time
      DateTime    :premium_end_time
      Text        :receipt_data
      String      :environment
      String      :transaction_id
      String      :original_transaction_id

      DateTime    :created_at
      DateTime    :updated_at
      DateTime    :deleted_at
    end
  end

  down do
    drop_table :users
  end
end
