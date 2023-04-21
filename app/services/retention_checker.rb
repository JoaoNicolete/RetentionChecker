# frozen_string_literal: true

# Lib to check if a snapshot should be retained or not
class RetentionChecker
  attr_reader :plan, :date

  AVALIABLE_PLANS = %w[standard gold platinum]
  DAYS_TO_RETAIN = 42
  MONTHS_TO_RETAIN = 12
  YEARS_TO_MANTAIN = 7

  def initialize(plan:, date:)
    @plan = plan
    @date = parse_date(date: date)
  end

  def check_retention
    validate_attributes!

    return 'retain' if send("should_retain_for_#{@plan}?")

    'delete'
  end

  private

  def should_retain_for_platinum?
    return should_retain_for_gold? unless @date == @date.end_of_year

    return true if Date.today <= @date + YEARS_TO_MANTAIN.years

    false
  end

  def should_retain_for_gold?
    return should_retain_for_standard? unless @date == @date.end_of_month

    return true if Date.today <= @date + MONTHS_TO_RETAIN.months

    false
  end

  def should_retain_for_standard?
    return true if Date.today <= @date + DAYS_TO_RETAIN.days

    false
  end

  def validate_attributes!
    raise StandardError, 'Invalid plan' unless AVALIABLE_PLANS.include?(@plan)

    raise StandardError, 'Invalid date' unless @date && @date < Date.today
  end

  def parse_date(date:)
    return date if date.is_a?(Date)

    Date.parse(date)
  end
end
