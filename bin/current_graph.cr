require "../src/windy_day_analyzer"

a = WindyDayAnalyzer::Analyzer.new(
  path: "data"
)
a.current_graph
