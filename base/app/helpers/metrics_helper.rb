# encoding: UTF-8 
module MetricsHelper
  def metric_tsm_help
    <<-EOF
    The TSM Average column is the Trailing Six Month Compound Growth Rate. 
    In most businesses, a monthly growth percent is too volatile to be meaningful. 
    However the TSM Average smooths out the monthly change. 
    Comparing the monthly to the TSM, we can get a sense of whether the monthly growth is accelerating or decelerating and how it compares to the goal you set each quarter.
    EOF
  end
end
