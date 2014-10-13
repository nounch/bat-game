class GUI
  def initialize(**options)
    @screen = options[:screen] || nil
    @input = options[:input] || nil
    @last_tick = 0
    @lines = []
    @health = 0
    @points = 0
    @levels = 0
    @boost = false
    @do_show_new_level_screen = false
    @do_show_a_message = false
    @message
  end

  def tick()
    @last_tick += 1
    if @last_tick > 170
      @last_tick = 0
    end
    dispatch_input()
    render()
  end

  def dispatch_input()
    keys = @input.keys.keys
    # SPACE
    if @input.keys['32'] == true
      @do_show_new_level_screen = false
      @do_show_a_message = false
    end
  end

  def set_health(health)
    @health = health
  end

  def set_points(points)
    @points = points
  end

  def set_level(count)
    @levels = count
  end

  def toggle_boost_on() @boost = true end
  def toggle_boost_off() @boost = false end
  def toggle_boost() @boost = !@boost end

  def show_new_level_screen(&block)
    @do_show_new_level_screen = true
    yield
  end

  def show_message(message, &block)
    @do_show_a_message = true
    @message = message
    yield
  end

  def render()
    @lines = ['Health ' + @health.to_s, 'Coins ' + @points.to_s,
              'Level ' + @levels.to_s]
    # Health
    @lines[0].split('').each_with_index do |char, x|
      @screen.put(x, 0, char)
    end
    # Points
    @lines[1].split('').reverse.each_with_index do |char, x|
      @screen.put(@screen.width - 1 - x, 0, char)
    end
    # Level
    @lines[2].split('').reverse.each_with_index do |char, x|
      @screen.put(@screen.width - 1 - x, @screen.height - 1, char)
    end
    # Boost
    if @boost
      "BOOST".split('').reverse.each_with_index do |char, i|
        @screen.put(@screen.width / 2 - 2 - i, @screen.height - 1, char)
      end
    end
    # Level screen
    if @do_show_new_level_screen
      msg = 'You have descended deeper into the darkness...'
      render_message(msg)
    end
    # User-defined message
    if @do_show_a_message
      render_message(@message)
    end
  end

  def render_message(msg)
    msg = msg
      .ljust(msg.length + (@screen.width - msg.length) / 2, ' ')
      .rjust(@screen.width, ' ')
    @screen.width.times do |x|
      @screen.put(x, (@screen.height - 1) / 2 - 2, ' ')
      @screen.put(x, (@screen.height - 1) / 2, ' ')
    end
    msg.split('').each_with_index do |char, i|
      @screen.put(i, (@screen.height - 1) / 2 - 1, char)
    end
  end
end
