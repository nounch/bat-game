class Stairs
  attr_reader :x, :y, :type

  def initialize(**options)
    @screen = options[:screen] || 0
    @x = options[:x] || 0
    @y = options[:y] || 0
    @tile = options[:tile] || '>'
    @type = options[:type] || 'outgoing'
  end

  def tick()
    render()
  end

  def render()
    @screen.put(@x, @y, @tile)
  end
end
