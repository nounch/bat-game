class Projectile
  attr_accessor :x, :y, :direction

  def initialize(**options)
    @x = options[:x] || 0
    @y = options[:y] || 0
    @screen = options[:screen] || nil
    @game = options[:game] || nil
    @boost = options[:boost] || 3
    @do_drift = options[:drift] || false
    @do_tick = true
    @last_tick = 0
    @x_drift = 0
    @y_drift = 0
    @direction = options[:direction] || 'east'
    if ['north', 'south'].member?(@direction)
      @tile = '|'
    elsif ['north-east', 'south-west'].member?(@direction)
      @tile = '/'
    elsif ['north-west', 'south-east'].member?(@direction)
      @tile = '\\'
    else  # `east' and `west'
      @tile = '-'
    end
    if !@screen.is_solid_in_direction?(@direction, @x, @y)
      @game.projectiles << self
      fly()
    end
  end

  def drift_x()
    @x += @x_drift
    case @x_drift
    when -1
      @x_drift = 1
    when 0
      @x_drift = [-1, 1].sample()
    when 1
      @x_drift = -1
    end
  end

  def drift_y()
    @y += @y_drift
    case @y_drift
    when -1
      @y_drift = 1
    when 0
      @y_drift = [-1, 1].sample()
    when 1
      @y_drift = -1
    end
  end

  def fly()
    case @direction
    when 'north'
      if @y > -1
        @boost.times { @y -= 1; drift_x() if @do_drift; render() }
      end
    when 'east'
      if @x < @screen.width
        @boost.times { @x += 1; drift_y() if @do_drift; render() }
      end
    when 'south'
      if @y < @screen.height
        @boost.times { @y += 1; drift_x() if @do_drift; render() }
      end
    when 'west'
      if @x > -1
        @boost.times { @x -= 1; drift_y() if @do_drift; render() }
      end
    when 'north-east'
      if @x < @screen.width && @y > -1
        @boost.times { @x += 1; @y -=1; render() }
      end
    when 'south-east'
      if @x < @screen.width && @y < @screen.height
        @boost.times { @x += 1; @y +=1; render() }
      end
    when 'south-west'
      if @x > -1 && @y < @screen.height
        @boost.times { @x -= 1; @y +=1; render() }
      end
    when 'north-west'
      if @x > -1 && @y > -1
        @boost.times { @x -= 1; @y -=1; render() }
      end
    end
  end

  def remove()
    @do_tick = false
  end

  def tick()
    if @do_tick &&
      @last_tick += 1
      if @last_tick < 2
        @last_tick = 0
        fly() if !@screen.is_solid_in_direction?(@direction, @x, @y)
      end
      render()
    end
  end

  def render()
    @screen.put(@x, @y, @tile)
  end
end
