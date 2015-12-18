require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/date_and_time/calculations'
require 'active_support/core_ext/integer/time'
require 'active_support/core_ext/time'
require 'awesome_print'

module  GitQuickBooks
  # Provides two CLI actions init and tally
  class Cli < Thor
    include Thor::Actions

    desc 'authorize', 'Login'

    def authorize
      api = GitQuickBooks::Api.new

      say 'To use Quickbooks, you need to grant access to the app.'
      say 'Press enter to launch your web browser and grant access.'

      Launchy.open api.authorize_url

      oauth_verifier = ask 'Now, copy the PIN below and press enter:'

      api.authorize(oauth_verifier)
    end

    desc 'companies', 'List Company Names and IDs'
    def companies
      api = GitQuickBooks::Api.new

      @customer_service = Quickbooks::Service::Customer.new
      @customer_service.access_token = api.access_token
      @customer_service.company_id = api.realm

      # Called without args you get the first page of results
      @customer_service.query_in_batches(nil, per_page: 20) do |batch|
        batch.each do |customer|
          puts "#{customer.id} : #{customer.display_name || customer.method}"
        end
      end
    end

    desc 'process', 'Produce time spend for each commit and file in each commit'
    method_option :customer, aliases: '-c', type: 'numeric', required: true
    method_option :file, aliases: '-f', default: '.'

    method_option :start_on, aliases: '-s', default: Date.today.beginning_of_month.to_s
    method_option :end_on, aliases: '-e'
    method_option :output, aliases: '-o', default: 'text'
    method_option :flush, default: false, type: 'boolean'
    method_option :add_to_qb, default: false
    method_option :rate, default: 75.0

    def process
      path = File.expand_path(options.file)
      start_date = Date.parse(options.start_on)
      end_date = Date.today

      # == Setup QB
      GitWakaTime.config.setup_local_db
      api = GitQuickBooks::Api.new
      @time_service = Quickbooks::Service::TimeActivity.new
      @time_service.access_token = api.access_token
      @time_service.company_id = api.realm

      @customer_service = Quickbooks::Service::Customer.new
      @customer_service.access_token = api.access_token
      @customer_service.company_id = api.realm

      customer = @customer_service.fetch_by_id(options.customer)

      puts "running for #{customer.display_name} for #{start_date} #{end_date}".blue

      return unless customer
      @total_time = 0

      controller = GitWakaTime::Controller.new(path: path, date: start_date)
      @timer = controller.timer

      @slips = @timer.map do |date, commits|
        next unless date >= start_date
        next unless date <= end_date
        commits = commits.reject { |c| c.message.to_s.downcase.delete(' ').include?('nocharge') }

        total_time = commits.map(&:time_in_seconds).compact.reduce(&:+) || 0

        # has a local time flaw
        recorded_time = GitWakaTime::Heartbeat.where(
          'DATE(time) >= ? and DATE(time) <= ? ', date.to_time.utc.to_date, date.to_time.utc.to_date
        ).where(project: controller.project).sum(:duration) || 0

        msgs = commits.map(&:message)
        message = CommitMsgCleaner.new(msgs).call

        @total_time += total_time

        hours   =  (total_time / 60.0 / 60).floor
        minutes =  (total_time / 60.0).remainder(60).ceil

        GitWakaTime::Log.new format(
          '%-100s %-30s %-30s %30s'.purple,
          date,
          "Recorded #{ChronicDuration.output recorded_time}",
          "Commited #{ChronicDuration.output total_time}",
          seconds_to_money(total_time, rate: options.rate)
        )

        message.split("\n").each do |msg_line|
          GitWakaTime::Log.new format(
            '%-120s'.green,
            msg_line
          )
        end

        # commits.each do |commit|
        #   GitWakaTime::Log.new format(
        #     '%-120s %-30s %30s'.green,
        #     commit.message.split("\n").first,
        #     "Total #{ChronicDuration.output commit.time_in_seconds.to_f}",
        #     seconds_to_money(commit.time_in_seconds, rate: options.rate)
        #   )
        # end

        slip = Quickbooks::Model::TimeActivity.new
        slip.txn_date = date
        slip.customer_id = options.customer
        slip.name_of = 'Employee'
        slip.employee_id = 196

        slip.billable_status = 'Billable' # or NotBillable
        slip.taxable = false
        slip.hours = hours
        slip.hourly_rate = options.rate
        slip.minutes = minutes
        slip.description = message

        slip
      end

      GitWakaTime::Log.new format(
        '%-120s %-30s %30s'.red,
        "#{@slips.size} slips",
        "Total #{ChronicDuration.output @total_time}",
        seconds_to_money(@total_time, rate: options.rate)
      )

      return unless options.add_to_qb
      # Send slips to Quickbooks Online
      @slips.compact.each do |slip|
        next unless ((slip.hours * 60) + slip.minutes) > 0
        puts 'Saving Slip'
        @time_service.create(slip)
      end
    end
    no_commands do
      def seconds_to_money(seconds, rate: 75.0)
        ((seconds.to_f / 3600.0) * rate.to_f).round(2)
      end
    end
  end
end
