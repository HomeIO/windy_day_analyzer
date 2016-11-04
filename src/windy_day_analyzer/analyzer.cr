class WindyDayAnalyzer::Analyzer
  def initialize(@path : String)
    @batt_u_path = File.join([@path, "buffer_batt_u.txt"])
    @coil_path = File.join([@path, "buffer_coil_1_u.txt"])
    @i_gen_batt_path = File.join([@path, "buffer_i_gen_batt.txt"])
    @imp_per_min_path = File.join([@path, "buffer_imp_per_min.txt"])
  end

  def analyze
  end
end
