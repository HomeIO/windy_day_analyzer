require "logger"

class WindyDayAnalyzer::Analyzer
  GNUPLOT_TIME_SCHEME = "%Y-%m-%d_%H:%M:%S"

  def initialize(@path : String, @stats_time_window : Time::Span = Time::Span.new(0, 0, 30))
    @batt_u_path = File.join([@path, "buffer_batt_u.txt"])
    @coil1_path = File.join([@path, "buffer_coil_1_u.txt"])
    @coil2_path = File.join([@path, "buffer_coil_2_u.txt"])
    @coil3_path = File.join([@path, "buffer_coil_3_u.txt"])
    @i_gen_batt_path = File.join([@path, "buffer_i_gen_batt.txt"])
    @imp_per_min_path = File.join([@path, "buffer_imp_per_min.txt"])

    @voltage_linear = 0.0777126099706744868
    @voltage_offset = 0

    @current_linear = 0.191
    @current_offset = -512

    @current_error = 0.0

    @logger = Logger.new(STDOUT)
  end

  getter :i_gen_batt_path, :coil1_path, :coil2_path, :coil3_path, :i_gen_batt_path, :imp_per_min_path
  getter :voltage_linear, :voltage_offset, :current_linear, :current_offset, :current_error

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
      time_to:             time_to,
      time_from:           time_from,
      count:               count,
      interval:            interval,
      calculated_interval: calculated_interval,
      data:                raw,
    }
  end

  def process_raw_file(
                       path : String,
                       offset : Int32,
                       linear : Float64,
                       max : Float64 = 100.0,
                       stats_time_window = @stats_time_window,
                       stats : Bool = false,
                       short : Bool = false,
                       real_offset : Float64 = 0.0)
    d = load_meas_buffer(path)

    index_a = Array(Int32).new
    time_a = Array(Time).new
    value_a = Array(Float64).new

    stat_time_a = Array(Time).new
    stat_index_a = Array(Int32).new
    avg_a = Array(Float64).new
    min_a = Array(Float64).new
    max_a = Array(Float64).new

    last_v = 0.0
    d["data"].each_with_index do |r, i|
      t = Time.epoch_ms(d["time_from"].epoch_ms + i.to_i64 * d["interval"])
      v = (r.to_f + offset.to_f) * linear
      v += real_offset # fix current sensor

      # remove spikes
      v = last_v if v > max
      last_v = v if v < max

      index_a << i
      time_a << t
      value_a << v
    end

    stats_count_window = 1
    if stats
      stats_count_window = stats_time_window.total_milliseconds.to_i64 / d["interval"].to_i64

      max = d["data"].size - 1
      i = 0
      while i < max
        f = i - (stats_count_window / 2)
        t = i + (stats_count_window / 2)

        f = 0 if f < 0
        t = max if t > max

        sa = value_a[f..t]
        if sa.size == 0
          avg = 0.0
        else
          avg = (sa.sum / sa.size)
        end

        stat_index_a << i
        stat_time_a << time_a[i]
        avg_a << avg
        min_a << sa.min
        max_a << sa.max

        # short=true - only return rows with calculated stats
        # short=false - return all rows
        # stats=true - calculate stats
        if short
          i += stats_count_window
        else
          i += 1
        end
      end
    else
      # use regular
      stat_index_a = index_a
      stat_time_a = time_a
    end

    {index: stat_index_a, time: stat_time_a, value: value_a, avg: avg_a, min: min_a, max: max_a, stats_count_window: stats_count_window}
  end

  def get_idle_current_error
    @logger.info("Start idle current error")

    coil_data = process_raw_file(
      path: @coil1_path,
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

    @logger.info("End idle current error")

    # return max because we do not want
    # have constant positive current
    @current_error = idle_currents.max
    return @current_error
  end

  # def current_graph
  #   get_idle_current_error
  #   puts "Idle current error"
  #   prepare_current_graph
  #   puts "Summary data"
  #   prepare_current_stats_graph
  #   puts "Detailed stats data"
  #
  #   gc = [
  #     "set datafile separator \",\"",
  #     "plot \"data.dat\"",
  #   ]
  #
  #   command = "gnuplot5 gnuplot/*.gnu"
  #
  #   puts command
  #   `#{command}`
  # end

  def prepare_total_summary_data(name : String = "")
    fn = "gnuplot/data/data_#{name}.dat"
    return if File.exists?(fn)
    r = process_raw_file(
      path: @i_gen_batt_path,
      offset: @current_offset,
      linear: @current_linear,
      max: 30.0,
      stats: false
    )
    times = r[:time]
    currents = r[:value]
    # fix current offset
    currents = currents.map { |v| v - @current_error }

    r = process_raw_file(
      path: @coil1_path,
      offset: @voltage_offset,
      linear: @voltage_linear,
      max: 120.0
    )
    coil1_voltages = r[:value]
    r = process_raw_file(
      path: @coil2_path,
      offset: @voltage_offset,
      linear: @voltage_linear,
      max: 120.0
    )
    coil2_voltages = r[:value]
    r = process_raw_file(
      path: @coil3_path,
      offset: @voltage_offset,
      linear: @voltage_linear,
      max: 120.0
    )
    coil3_voltages = r[:value]

    r = process_raw_file(
      path: @batt_u_path,
      offset: @voltage_offset,
      linear: @voltage_linear,
      max: 80.0
    )
    batt_voltages = r[:value]

    r = process_raw_file(
      path: @imp_per_min_path,
      offset: 0,
      linear: 1.0,
      max: 2000.0
    )
    impulses = r[:value]

    f = File.new(fn, "w")
    f.puts "#Index\tTime\tCurrent\tCoil1\tCoil2\tCoil3\tBatt voltage\tImpulses\t"

    max_size = times.size
    times.each_with_index do |t, i|
      ts = t.to_s(GNUPLOT_TIME_SCHEME)

      s = "#{i}\t#{ts}\t"

      if currents[i]?
        cv = currents[i]
        cv = 0.0 if cv < 0.0 # no negative current
        s += "#{cv}"
      end
      s += "\t"

      if coil1_voltages[i]?
        s += "#{coil1_voltages[i]}"
      end
      s += "\t"
      if coil2_voltages[i]?
        s += "#{coil2_voltages[i]}"
      end
      s += "\t"
      if coil3_voltages[i]?
        s += "#{coil3_voltages[i]}"
      end
      s += "\t"

      if batt_voltages[i]?
        s += "#{batt_voltages[i]}"
      end
      s += "\t"

      if impulses[i]?
        s += "#{impulses[i]}"
      end
      s += "\t"

      f.puts(s)

      if i % 50_000 == 0
        @logger.info("prepare_total_summary_data - #{i}/#{max_size}")
      end
    end

    f.close
  end

  def prepare_stats_data(
                         path : String,
                         offset : Int32,
                         linear : Float64,
                         max : Float64,
                         real_offset : Float64 = 0.0,
                         name : String = "default",
                         stats_time_window : Time::Span = @stats_time_window,
                         short : Bool = true)
    suffix = short ? "short" : "full"
    fn = "gnuplot/data/stats_#{name}_#{stats_time_window.total_milliseconds.to_i}_#{suffix}.dat"
    return if File.exists?(fn)

    @logger.info("prepare_stats_data START - #{name}/#{stats_time_window.total_seconds}s")

    r = process_raw_file(
      path: path,
      offset: offset,
      linear: linear,
      max: max,
      stats_time_window: stats_time_window,
      stats: true,
      short: short,
      real_offset: real_offset
    )
    times = r[:time]
    values = r[:value]

    @logger.info("prepare_stats_data GOT DATA - #{name}/#{stats_time_window.total_seconds}s")

    f = File.new(fn, "w")
    f.puts "#Index\tTime\Value\tAvg\tMin\tMax"

    max_size = times.size
    last_verbose_at = 0

    times.each_with_index do |t, i|
      ts = t.to_s(GNUPLOT_TIME_SCHEME)

      s = "#{i}\t#{ts}\t"

      v = r[:value][i]
      s += "#{v}"
      s += "\t"

      v = r[:avg][i]
      s += "#{v}"
      s += "\t"

      v = r[:min][i]
      s += "#{v}"
      s += "\t"

      v = r[:max][i]
      s += "#{v}"
      s += "\t"

      f.puts(s)

      if 100 * (i - last_verbose_at) / max_size > 10
        @logger.info("prepare_stats_data - #{name}/#{stats_time_window.total_seconds}s - #{i}/#{max_size}")
        last_verbose_at = i
      end
    end

    f.close

    @logger.info("prepare_stats_data END - #{name}/#{stats_time_window.total_seconds}s")
  end

  def prepare_current_stats_graph
    prepare_stats_data(
      path: @i_gen_batt_path,
      offset: @current_offset,
      linear: @current_linear,
      max: 30.0,
      real_offset: -1.0 * @current_error,
      name: "charg_current",
      stats_time_window: Time::Span.new(0, 0, 10)
    )

    prepare_stats_data(
      path: @i_gen_batt_path,
      offset: @current_offset,
      linear: @current_linear,
      max: 30.0,
      real_offset: -1.0 * @current_error,
      name: "charg_current",
      stats_time_window: Time::Span.new(0, 5, 0)
    )
  end
end
