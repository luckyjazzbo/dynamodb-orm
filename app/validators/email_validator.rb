class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, error_message) unless email?(value)
  end

  private

  def email?(value)
    value =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  end

  def error_message
    options[:message] || 'is not an email'
  end
end
