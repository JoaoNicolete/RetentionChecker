# Retention Plan
  This project implements a simple service to check if we need to keep a snapshot of an ERP instance backup based on the retention plan and date.

## Running
  The service that implements this logic is `retention_plan/app/services/retention_checker.rb`.

  To run it, call:
  `retention_checker = RetentionChecker.new(plan: plan, date: date)`

  Plan accepts a string containing the plan name, being one of 3 options: standard, gold or platinum.

  Date accepts a Date object or a string containing a date in the format: DD/MM/YYYY.

  After initializing, run:

  `retention_checker.check_retention`

  It will return 'retain' when the snapshot should be retained and 'delete' when it should be deleted.

## Testing
  Tests are implemented on `retention_plan/spec/services/retention_checker_spec.rb`

  To run it, just run: `rspec retention_plan/spec/services/retention_checker_spec.rb`



