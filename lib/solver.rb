class Solver
  attr_reader :time_value, :goal
  attr_accessor :guess, :lower_bound, :upper_bound, :upper_cap_met

  def initialize(time_value, guess = 10.00, lower_bound = 0.00, upper_bound = 10.00)
    @upper_bound = upper_bound
    @lower_bound = lower_bound
    @guess = guess
    @time_value = time_value
    @goal = time_value.fv
    @upper_cap_met = false
  end

  def solve!
    iteration_count = 0
    time_value.i = guess
    while (upper_bound - lower_bound).round(2) > 0.01 && iteration_count < 100
      iteration_count += 1
      begin
        result = time_value.calc_fv
      rescue FloatDomainError => error
        return nil
      end
      adjust_bounds(result)
      time_value.i = guess
    end
    guess if iteration_count < 100
  end

  def adjust_bounds(result)
    if result > goal
      # interest rate too high
      self.upper_cap_met = true
      self.upper_bound = guess
    elsif result < goal
      # interest rate too low
      self.upper_bound *= 2 unless upper_cap_met
      self.lower_bound = guess
    end
    self.guess = ((upper_bound + lower_bound) / 2).round(2)
  end
end