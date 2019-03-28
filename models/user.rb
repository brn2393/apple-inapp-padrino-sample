class User < Sequel::Model
  plugin :timestamps

  def before_validation
    super
  end

  def validate
    super
  end

  def before_create
    super
  end

  def before_save
    super
  end

  def after_save
    super
  end
end
