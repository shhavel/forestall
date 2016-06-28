require 'spec_helper'

describe SourceCodeAnalyzer do
  it { expect(described_class).to be_processed_in :analyze_source_code }
  it { expect(described_class).to be_retryable 5 }
end
