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

    @current_error = 0.0
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

  def process_raw_file(path, offset : Int32, linear : Float64, max : Float64 = 100.0 )
    d = load_meas_buffer(path)

    index_a = Array(Int32).new
    time_a = Array(Time).new
    value_a = Array(Float64).new

    last_v = 0.0
    d["data"].each_with_index do |r, i|
      t = Time.epoch_ms(d["time_from"].epoch_ms + i.to_i64 * d["interval"])
      v = (r.to_f + offset.to_f) * linear

      # remove spikes
      v = last_v if v > max
      last_v = v if v < max

      index_a << i
      time_a << t
      value_a << v
    end

    {index: index_a, time: time_a, value: value_a}
  end

  def get_idle_current_error
    coil_data = process_raw_file(
      path: @coil_path,
      offset: @voltage_offset,
      linear: @voltage_linear
    )

    # where wind turbine was idle - no rotation
    idle_indexes = Array(Int32).new

    cv = coil_data[:value]
    cv.each_with_index do |v, i|
      idle_indexes << i if v < 2.0
    end

    # select idle current values

    # where wind turbine was idle - no rotation
    idle_currents = Array(Float64).new

    current_data = process_raw_file(
      path: @i_gen_batt_path,
      offset: @current_offset,
      linear: @current_linear
    )
    # add values to temp array
    idle_indexes.each do |i|
      idle_currents << current_data[:value][i]
    end

    # return max because we do not want
    # have constant positive current
    @current_error = idle_currents.max
    return @current_error
  end

  def current_graph
    get_idle_current_error

    r = process_raw_file(
      path: @i_gen_batt_path,
      offset: @current_offset,
      linear: @current_linear
    )
    #index_a = r[:index]
    time_a = r[:time]
    value_a = r[:value]

    # fix current offset
    value_a = value_a.map{|v| v - @current_error}

    f = File.new("data.dat", "w")
    f.puts "#Time\tCurrent"

    time_a.each_with_index do |t, i|
      ts = t.to_s("%Y-%m-%d %H:%M:%S")
      v = value_a[i]
      v = 0.0 if v < 0.0 # no negative current

      f.puts "#{ts}\t#{v}"

      if i % 50_000 == 0
        puts i
      end
    end

    f.close

  end
end
