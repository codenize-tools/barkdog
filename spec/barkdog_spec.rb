describe Barkdog::Client do
  subject { barkdog_client.export }

  let(:dsl) do
    <<-'RUBY'
monitor "my metric check", :type=>"metric alert" do
  query "avg(last_5m):avg:datadog.dogstatsd.packet.count{*} > 1"
  message "metric check message"
  options do
    locked false
    no_data_timeframe 2
    notify_audit false
    notify_no_data false
    silenced({})
  end
end

monitor "my service check", :type=>"service check" do
  query "\"datadog.agent.up\".over(\"*\").last(2).count_by_status()"
  message "service check message"
  options do
    locked false
    no_data_timeframe 2
    notify_audit false
    notify_no_data true
    period 15
    renotify_interval 0
    silenced({})
    thresholds "critical"=>1, "ok"=>1, "warning"=>1
    timeout_h 0
  end
end
    RUBY
  end

  let(:actual_dsl) { dsl }
  let(:expected_dsl) { dsl }

  before { barkdog { actual_dsl } }

  context 'when create monitors' do
    it { is_expected.to eq expected_dsl }
  end

  context 'when use template monitors' do
    let(:actual_dsl) do
      <<-'RUBY'
template 'my metric check' do
  query "avg(last_5m):avg:datadog.dogstatsd.packet.count{*} > 1"
  message "metric check message"
  options do
    locked false
    no_data_timeframe context.no_data_timeframe
    notify_audit false
    notify_no_data false
    silenced({})
  end
end

template "my service check options" do
  locked false
  no_data_timeframe 2
  notify_audit false
  notify_no_data true
  period context.period
  renotify_interval 0
  silenced({})
  thresholds "critical"=>1, "ok"=>1, "warning"=>1
  timeout_h 0
end

monitor "my metric check", :type=>"metric alert" do
  include_template "my metric check", :no_data_timeframe=>2
end

monitor "my service check", :type=>"service check" do
  query "\"datadog.agent.up\".over(\"*\").last(2).count_by_status()"
  message "service check message"
  options do
    context.period = 15
    include_template "my service check options"
  end
end
      RUBY
    end

    it { is_expected.to eq expected_dsl }
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
    locked false
    no_data_timeframe 3
    notify_audit true
    notify_no_data true
    silenced "*"=>nil
  end
end

monitor "my service check", :type=>"service check" do
  query "\"datadog.agent.up\".over(\"*\").last(3).count_by_status()"
  message "service check message2"
  options do
    locked false
    no_data_timeframe 3
    notify_audit true
    notify_no_data true
    period 30
    renotify_interval 1
    silenced "*"=>nil
    thresholds "critical"=>2, "ok"=>2, "warning"=>2
    timeout_h 1
  end
end
      RUBY
    end

    before { barkdog { expected_dsl } }
    it { is_expected.to eq expected_dsl }
  end
end
