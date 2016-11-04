class WindyDayAnalyzer::Analyzer
  def initialize(@path : String)
    @batt_u_path = File.join([@path, "buffer_batt_u.txt"])
    @coil_path = File.join([@path, "buffer_coil_1_u.txt"])
    @i_gen_batt_path = File.join([@path, "buffer_i_gen_batt.txt"])
    @imp_per_min_path = File.join([@path, "buffer_imp_per_min.txt"])

    @voltage_linear = 0.0777126099706744868
    @voltage_offset = 0

    @current_linear = 0.191
    @current_offset = -512
  end

  def load_meas_buffer(path : String)
    f = File.open(path)

    time_to = Time.epoch_ms(f.read_line.to_s.to_i64)
    max_count = f.read_line.to_s.to_i64
    count = f.read_line.to_s.to_i64
    _ = f.read_line
    _ = f.read_line
    time_from = Time.epoch_ms(f.read_line.to_s.to_i64)
    interval = f.read_line.to_s.to_i64
    _ = f.read_line
    _ = f.read_line

    raw = Array(UInt16).new

    (0...count).each do |i|
      raw << f.read_line.to_u16
    end

    f.close

    calculated_interval = ((time_to - time_from).total_milliseconds / count).to_i64

    return {
      time_to: time_to,
      time_from: time_from,
      count: count,
      interval: interval,
      calculated_interval: calculated_interval,
      data: raw
    }
  end

  def current_graph
    d = load_meas_buffer(@i_gen_batt_path)

    time_a = Array(Time).new
    value_a = Array(Float64).new

    last_v = 0.0
    d["data"].each_with_index do |r, i|
      t = Time.epoch_ms(d["time_from"].epoch_ms + i.to_i64 * d["interval"])
      v = (r.to_f + @current_offset.to_f) * @current_linear

      # remove spikes
      v = last_v if v > 100.0
      last_v = v if v < 100.0

      time_a << t
      value_a << v
    end

    # fix current offset
    v_min = value_a.min
    value_a = value_a.map{|v| v - v_min}
    puts "fixed offset #{v_min}"

    f = File.new("data.dat", "w")
    f.puts "#Time\tCurrent"

    time_a.each_with_index do |t, i|
      ts = t.to_s("%Y-%m-%d %H:%M:%S")
      v = value_a[i]

      f.puts "#{ts}\t#{v}"

      if i % 50_000 == 0
        puts i
      end
    end

    f.close


    #puts d.inspect

  end
end
