describe Barkdog::Client do
  subject { barkdog_client(options).export }
  let(:options) { {} }

  let(:before_dsl) do
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
  end

  let(:update_dsl) do
    <<-'RUBY'
      monitor "my metric check", :type=>"metric alert" do
        query "avg(last_5m):avg:datadog.dogstatsd.packet.count{*} > 2"
        message "metric check message2"
        options do
          locked false
          new_host_delay 300
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
          new_host_delay 300
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

  context 'when update monitors' do
    before do
      barkdog(options) { before_dsl }
    end

    specify do
      barkdog(options) { update_dsl }
      expect(subject).to match_fuzzy update_dsl
    end
  end

  context 'when use template monitors (ignore silenced)' do
    let(:options) { {ignore_silenced: true} }

    specify do
      barkdog(options) { update_dsl }
      expect(subject).to match_fuzzy update_dsl.gsub('silenced "*"=>nil', '')
    end
  end
end
