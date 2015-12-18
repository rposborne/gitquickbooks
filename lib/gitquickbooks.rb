require 'dotenv'
Dotenv.load

require 'thor'
require 'gitquickbooks/version'
require 'gitquickbooks/api'
require 'gitquickbooks/cli'
require 'gitquickbooks/cache'
require 'gitquickbooks/commit_msg_cleaner'
require 'quickbooks-ruby'
require 'gitwakatime'
# Yup it's a module :)
module GitQuickBooks
end
