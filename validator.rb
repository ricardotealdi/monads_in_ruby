# Examples:
#
#  validator =
#   Validator.new(21).
#     bind_validation(Validations::IsAFixnum).
#     bind_validation(Validations::BiggerThan10).
#     bind_validation(Validations::BiggerThan20)
#
#  validator.valid? # => true
#  validator.errors # => []
#
#  validator =
#   Validator.new("20").
#     bind_validation(Validations::IsAFixnum).
#     bind_validation(Validations::BiggerThan10).
#     bind_validation(Validations::BiggerThan20)
#
#  validator.valid? # => false
#  validator.errors # => ["This is not a number", "This number is less or equal than 20"]
#
#  validator =
#   Validator.new("20").
#     bind_validation(Validations::IsAFixnum).
#     bind_validation(Validations::BiggerThan10).
#     bind_validation(Validations::BiggerThan20)
#
#  validator.valid? # => false
#  validator.errors # => ["This is not a number", "This number is less or equal than 20"]

Validator = Struct.new(:number, :function) do
  def errors
    @errors ||= function ? function.call : []
  end

  def valid?
    errors.empty?
  end

  def bind_validation(validation_class)
    bind(
      ->(number, errors) do
        unless (validation = validation_class.new(number)).valid?
          errors << validation.error_message
        end

        errors
      end
    )
  end

  private

  def bind(lambda)
    myself = self
    self.class.new(number, -> { lambda.call(myself.number, myself.errors) })
  end
end

module Validations
  IsAFixnum = Struct.new(:value) do
    def error_message
      'This is not a number'
    end

    def valid?
      puts "validating #{self.class}"
      value.is_a?(Fixnum)
    end
  end

  BiggerThan10 = Struct.new(:value) do
    def error_message
      'This number is less or equal than 10'
    end

    def valid?
      puts "validating #{self.class}"
      value.to_s.to_i > 10
    end
  end

  BiggerThan20 = Struct.new(:value) do
    def error_message
      'This number is less or equal than 20'
    end

    def valid?
      puts "validating #{self.class}"
      value.to_s.to_i > 20
    end
  end
end
