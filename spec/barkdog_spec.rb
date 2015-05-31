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
end
