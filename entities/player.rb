require_relative '../weapons/projectile'


class Player
  attr_reader :x, :y, :is_dead, :gun, :health, :points
  attr_writer :health, :points, :tile

  def initialize(**options)
    @speed = 0.3
    @boost_min = 1
    @boost_max = 5
    @is_dead = false
    @boost = @boost_min
    @facing_direction = 'east'
    @shoot_timeout = 0
    @last_tick = 0
    @do_wander = false
    @screen = options[:screen] || nil
    @x = @screen.width / 2 - 1|| 0
    @y = @screen.height / 2 - 1|| 0
    @tile = options[:tile] || '@'
    @game = options[:game] || nil
    @input = options[:input] || nil
    @gun = options[:gun] || nil
    @gui = options[:gui] || nil
    @health = 100
    @points = 0
  end

  def move_right()
    @x += 1 if @x < @screen.width - 1 && !@screen.is_solid?(@x + 1, @y)
  end

  def move_left()
    @x -= 1 if @x > 0 && !@screen.is_solid?(@x - 1, @y)
  end

  def move_up()
    @y -= 1 if @y > 0 && !@screen.is_solid?(@x, @y - 1)
  end

  def move_down()
    @y += 1 if @y < @screen.height - 1 && !@screen.is_solid?(@x, @y + 1)
  end

  def center()
    @x = @screen.width / 2 - 1
    @y = @screen.height / 2 - 1
  end

  def dispatch_input()
    # Ordinal key codes:
    #
    # Up arrow: 65
    # Right arrow: 67
    # Down arrow: 66
    # Left arrow: 68

    # up arrow
    if @input.keys['65'] == true
      @facing_direction = 'north'
      @boost.times { move_up(); render() }
    end
    # right arrow
    if @input.keys['67'] == true
      @facing_direction = 'east'
      @boost.times { move_right(); render() }
    end
    # down arrow
    if @input.keys['66'] == true
      @facing_direction = 'south'
      @boost.times { move_down(); render() }
    end
    # right arrow
    if @input.keys['68'] == true
      @facing_direction = 'west'
      @boost.times { move_left(); render() }
    end
    # `w'
    if @input.keys['119'] == true
      @do_wander = !@do_wander
    end
    # `q'
    if @input.keys['113'] == true
      @gui.toggle_boost()
      @boost == @boost_min ? @boost = @boost_max : @boost = @boost_min
    end
    # `e'
    if @input.keys['101'] == true
      if @boost == @boost_max
        @gun.projectile_boost = 3
      else
        @gun.projectile_boost = 1
      end
      if @shoot_timeout == 0
        if [OrthogonalGun, DiagonalGun, AllDirectionsGun]
            .member?(@gun.class)
          @screen.shake()
        end
        @gun.shoot(@x, @y, @facing_direction)
        @shoot_timeout = 2
      end
    end
  end

  def start_wandering()
    @do_wander = true
  end

  def wander()
    x1 = [0, 1, -1].sample()
    y1 = [0, 1, -1].sample()
    if @x + @boost * x1 > 0 && @x + @boost * x1 < @screen.width - 1 &&
        !@screen.is_solid?(@x + @boost * x1, @y)
      @boost.times { @x += x1; render() }
    end
    if @y + @boost * y1 > 0 && @y + @boost * y1 < @screen.height - 1 &&
        !@screen.is_solid?(@x, @y + @boost * y1)
      @boost.times { @y += y1; render() }
    end
  end

  def give_points(amount)
    @points += amount
  end

  def give_health(amount)
    new = @health + amount
    @health = new if new <= 100
  end

  def give_gun(gun)
    @gun = gun
  end

  def damage(amount)
    @health -= amount
    kill() if @health <= 0
  end

  def kill()
    @tile = @game.tile_types[:dead_body]
    @is_dead = true
  end

  def revive()
    @tile = @game.tile_types[:player]
    @is_dead = false
  end

  def tick()
    @last_tick += 1
    if @last_tick == 2
      @last_tick = 0
      wander() if @do_wander && !@is_dead
      if @shoot_timeout > 0
        @shoot_timeout -= 1
      end
    end
    if !@is_dead
      dispatch_input()
    end
    render()
  end

  def render()
    @screen.put(@x, @y, @tile)
  end
end
