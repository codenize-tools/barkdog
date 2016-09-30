describe Barkdog::Client do
  subject { barkdog_client(options).export }
  let(:options) { {} }

  let(:dsl) {
    <<-'RUBY'
      monitor "my metric check", :type=>"metric alert" do
        query "avg(last_5m):avg:datadog.dogstatsd.packet.count{*} > 1"
        message "metric check message"
        options do
          locked false
          new_host_delay 300
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
          new_host_delay 300
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
  }

  context 'when delete monitors' do
    before do
      barkdog(options) { dsl }
    end

    specify do
      barkdog(options) { '' }
      expect(subject).to match_fuzzy ''
    end
  end

  context 'when delete monitors (no delete)' do
    let(:options) { {no_delete: true} }

    before do
      barkdog(options) { dsl }
    end

    specify do
      barkdog(options) { '' }
      expect(subject).to match_fuzzy dsl
    end
  end
end
