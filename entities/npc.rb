class NPC
  attr_accessor :x, :y, :is_dead

  def initialize(**options)
    @x = options[:x] || 0
    @y = options[:y] || 0
    @screen = options[:screen] || nil
    @game = options[:game] || nil
    @tile = options[:tile] || 'w'
    @killable = options[:killable] || true
    @last_tick = 0
    @do_tick = true
    @is_dead = false
  end

  def wander()
    x1 = @x + [0, 1, -1].sample()
    y1 = @y + [0, 1, -1].sample()
    if x1 >= 0 && x1 < @screen.width
      @x = x1
    end
    if y1 >= 0 && y1 < @screen.height
      @y = y1
    end
  end

  def kill()
    @is_dead = true
  end

  def tick()
    if @do_tick
      @last_tick += 1
      if @last_tick > 10
        @last_tick = 0
        if !@is_dead
          wander()
        else
          @tile = @game.tile_types[:dead_body]
        end
      end
      render()
    end
  end

  def render()
    @screen.put(@x, @y, @tile)
  end
end
