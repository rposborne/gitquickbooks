# GitQuickBooks

[![Build Status](https://travis-ci.org/rposborne/gitquickbooks.svg)](https://travis-ci.org/rposborne/gitquickbooks)
[![Code Climate](https://codeclimate.com/github/rposborne/gitquickbooks/badges/gpa.svg)](https://codeclimate.com/github/rposborne/gitquickbooks)
[![Test Coverage](https://codeclimate.com/github/rposborne/gitquickbooks/badges/coverage.svg)](https://codeclimate.com/github/rposborne/gitquickbooks/coverage)

This code links git wakatime per commit data to quickbooks online.
It will automatically manage API keys and storing of wakatime data locally via
GitWakatime gem.

## Installation

Add this line to your application's Gemfile:

    gem 'gitquickbooks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gitquickbooks

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gitquickbooks/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


# Loop through TimeServices
``` ruby
  @entires = @time_service.query("Select * from TimeActivity where BillableStatus = 'Billable' and CustomerRef = '167'", :per_page => 50)

  def update_entry(entry)
    if entry.employee_ref
      entry.hourly_rate = 75
      name = entry.employee_ref.name
    else #sam
      entry.hourly_rate = 50
      name = entry.vendor_ref.name
    end
    puts "#{entry.billable_status} #{entry.txn_date} #{entry.hourly_rate} for #{name}: #{entry.description}"
    @time_service.update(entry)
  end
  entry = @entires.entries.first

  update_entry(entry)
  @entires.entries.each do |time_entry|
    update_entry(time_entry)
  end
```
