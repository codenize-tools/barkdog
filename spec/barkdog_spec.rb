describe Barkdog::Client do
  subject { barkdog_client.export }

  let(:actual_dsl) do
    <<-'RUBY'
monitor "my metric check", :type=>"metric alert" do
  query "avg(last_5m):avg:datadog.dogstatsd.packet.count{*} > 1"
  message "metric check message"
  options do
    notify_no_data false
    no_data_timeframe 2
    notify_audit false
    silenced({})
  end
end

monitor "my service check", :type=>"service check" do
  query "\"datadog.agent.up\".over(\"*\").last(2).count_by_status()"
  message "service check message"
  options do
    notify_audit false
    timeout_h 0
    silenced({})
    thresholds "warning"=>1, "ok"=>1, "critical"=>1
    period 15
    notify_no_data true
    renotify_interval 0
    no_data_timeframe 2
  end
end
    RUBY
  end

  before { barkdog { actual_dsl } }

  context 'when create monitors' do
    it { is_expected.to eq actual_dsl }
  end

  context 'when delete monitors' do
    let(:expected_dsl) { '' }
    before { barkdog { expected_dsl } }
    it { is_expected.to eq expected_dsl }
  end

  context 'when update monitors' do
    let(:expected_dsl) do
      <<-'RUBY'
monitor "my metric check", :type=>"metric alert" do
  query "avg(last_5m):avg:datadog.dogstatsd.packet.count{*} > 2"
  message "metric check message2"
  options do
    notify_no_data true
    no_data_timeframe 3
    notify_audit true
    silenced "*"=>nil
  end
end

monitor "my service check", :type=>"service check" do
  query "\"datadog.agent.up\".over(\"*\").last(3).count_by_status()"
  message "service check message2"
  options do
    notify_audit true
    timeout_h 1
    silenced "*"=>nil
    thresholds "warning"=>2, "ok"=>2, "critical"=>2
    period 30
    notify_no_data true
    renotify_interval 1
    no_data_timeframe 3
  end
end
      RUBY
    end

    before { barkdog { expected_dsl } }
    it { is_expected.to eq expected_dsl }
  end
end
