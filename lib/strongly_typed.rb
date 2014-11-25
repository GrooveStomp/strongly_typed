require "strongly_typed/version"
#
# StronglyTyped
#
# Validate types and values for parameters.
#
# Example Usage:
#
#  class MyClass
#    extend StronglyTyped
#    def add(left, right)
#      validate_type_equals('left', left, Fixnum)
#      validate_type_equals('right', right, Fixnum)
#      left + right
#    end
#  end
#
#  class Myclass
#    def add(left, right)
#      StronglyTyped.validate_type_equals('left', left, Fixnum)
#      StronglyTyped.validate_type_equals('right', right, Fixnum)
#      left + right
#    end
#  end
#
module StronglyTyped
  VALUE_IN_MISSING_PARAM_ERROR = ArgumentError.new("args must include either :options, or both: [:first, :last]")
  extend self

  def validate_type_equals(name, parameter, type)
    if parameter.is_a?(type)
      true
    else
      fail ArgumentError.new("#{name} must be a #{type}")
    end
  end

  def validate_array_of_type(name, parameter, type)
    error = ArgumentError.new("#{name} must be an array of #{type}s")
    fail error unless parameter.is_a?(Array)
    fail error if parameter.any? { |p| !p.is_a?(type) }

    true
  end

  def validate_type_in(name, parameter, types)
    if types.include?(parameter.class)
      true
    else
      fail ArgumentError.new("#{name} must be one of: " + types.collect{ |t| t.to_s }.to_s)
    end
  end

  def validate_value_greater_than(name, parameter, value)
    fail ArgumentError.new("#{name} must be greater than #{value}") unless parameter > value
    true
  end

  def validate_value_in(name, parameter, **args)
    if args[:options]
      validate_value_in_set(name, parameter, args[:options])
    elsif args[:first] && args[:last]
      validate_value_in_range(name, parameter, args[:first], args[:last])
    else
      fail VALUE_IN_MISSING_PARAM_ERROR
    end
  end

  private

    def validate_value_in_set(name, parameter, options)
      if options.include?(parameter)
        true
      else
        fail ArgumentError.new("#{name} must have a value equal to one of: #{options} - received: #{parameter}")
      end
    end

    def validate_value_in_range(name, parameter, first, last)
      if (first..last).include?(parameter)
        true
      else
        fail ArgumentError.new("#{name} must have a value in the range: [#{first}..#{last}]")
      end
    end

end
