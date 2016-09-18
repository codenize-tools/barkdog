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
  }

  context 'when create monitors' do
    specify do
      barkdog(options) { dsl }
      expect(subject).to match_fuzzy dsl
    end
  end

  context 'when use template monitors' do
    specify do
      barkdog(options) {
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
      }

      expect(subject).to match_fuzzy dsl
    end
  end
end
