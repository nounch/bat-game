class HealthUp
  attr_reader :x, :y, :value

  def initialize(**options)
    @screen = options[:screen] || 0
    @x = options[:x] || 0
    @y = options[:y] || 0
    @value = options[:value] || 10
    @tile = options[:tile] || 'o'
  end

  def tick()
    render()
  end

  def render()
    @screen.put(@x, @y, @tile)
  end
end
