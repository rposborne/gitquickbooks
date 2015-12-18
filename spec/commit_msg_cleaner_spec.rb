describe GitQuickBooks::CommitMsgCleaner do
  let(:msgs) do
    [
      'I am the first message',
      '',
      nil,
      'I am the last. ',
      'i skipped [ci-skip]',
      'i wish i was capitalized correctly'
    ]
  end

  subject(:subject) { described_class.new(msgs) }
  it 'string' do
    expect(subject.call).to eql('')
  end
end