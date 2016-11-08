require "../src/windy_day_analyzer"

a = WindyDayAnalyzer::Analyzer.new(
  path: "data"
)
a.get_idle_current_error

unless File.exists?("gnuplot/data/stats_charg_current_300000_short.dat")
  a.prepare_stats_data(
    path: a.i_gen_batt_path,
    offset: a.current_offset,
    linear: a.current_linear,
    max: 30.0,
    real_offset: -1.0 * a.current_error,
    name: "charg_current",
    stats_time_window: Time::Span.new(0, 5, 0)
  )
end

unless File.exists?("gnuplot/data/stats_charg_current_60000_short.dat")
  a.prepare_stats_data(
    path: a.i_gen_batt_path,
    offset: a.current_offset,
    linear: a.current_linear,
    max: 30.0,
    real_offset: -1.0 * a.current_error,
    name: "charg_current",
    stats_time_window: Time::Span.new(0, 1, 0)
  )
end

unless File.exists?("gnuplot/data/stats_charg_current_1800000_short.dat")
  a.prepare_stats_data(
    path: a.i_gen_batt_path,
    offset: a.current_offset,
    linear: a.current_linear,
    max: 30.0,
    real_offset: -1.0 * a.current_error,
    name: "charg_current",
    stats_time_window: Time::Span.new(0, 30, 0)
  )
end

a.prepare_total_summary_data
