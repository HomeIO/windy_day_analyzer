require "../src/windy_day_analyzer"

a = WindyDayAnalyzer::Analyzer.new(
  path: "data/2016_11_04"
)
a.get_idle_current_error

a.prepare_stats_data(
  path: a.i_gen_batt_path,
  offset: a.current_offset,
  linear: a.current_linear,
  max: 30.0,
  real_offset: -1.0 * a.current_error,
  name: "2016_11_04_charg_current",
  stats_time_window: Time::Span.new(0, 5, 0)
)

a.prepare_stats_data(
  path: a.i_gen_batt_path,
  offset: a.current_offset,
  linear: a.current_linear,
  max: 30.0,
  real_offset: -1.0 * a.current_error,
  name: "2016_11_04_charg_current",
  stats_time_window: Time::Span.new(0, 1, 0)
)

a.prepare_stats_data(
  path: a.i_gen_batt_path,
  offset: a.current_offset,
  linear: a.current_linear,
  max: 30.0,
  real_offset: -1.0 * a.current_error,
  name: "2016_11_04_charg_current",
  stats_time_window: Time::Span.new(0, 30, 0)
)

a.prepare_total_summary_data(
  name: "2016_11_04"
)
