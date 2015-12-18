module  GitQuickBooks
  class CommitMsgCleaner
    def initialize(msgs)
      @msgs = msgs
    end

    def remove_blanks
      @msgs.reject(&:blank?).compact
    end

    def remove_former_commits
      @msgs.reject { |m| m =~ /Former-commit-id/ }
    end

    def remove_trail_period
      @msgs.map do |msg|
        # [ci-skip]
        msg.strip.chomp('.')
      end
    end

    def remove_square_brackets
      @msgs.map do |msg|
        # [ci-skip]
        msg.gsub(/\[.*\]/, '')
      end
    end

    def capitolize_first_word
      @msgs.map do |msg|
        msg[0] = msg[0].to_s.capitalize
        msg
      end
    end

    def call
      @msgs = remove_blanks
      @msgs = remove_trail_period
      @msgs = remove_former_commits
      @msgs = capitolize_first_word
      @msgs = remove_square_brackets
      @msgs.join("\n")
    end
  end
end
