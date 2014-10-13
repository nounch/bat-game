require_relative 'string_colors'


class Screen
  attr_reader :width, :height

  def initialize(options)
    @pixels = []
    @width = options[:width] || 30
    @height = options[:height] || 20
    @game = options[:game] || 20
    @do_colorize = options[:color] || false
    @do_shake = options[:shake] || false
  end

  def clear_screen()
    # In case `tput' was not available, you could alwos use an ANSI escape
    # sequence:
    # puts("\033[H\033[2J")
    system("tput clear")
  end

  def put(x, y, char)
    @pixels[y * @width + x] = char
  end

  def fill(char)
    @height.times do |y|
      @width.times do |x|
        @pixels[y * @width + x] = char
      end
    end
  end

  def fill_row(y0, char)
    @height.times do |y|
      if y0 == y
        @width.times do |x|
          @pixels[y * @width + x] = char
        end
        break
      end
    end
  end

  def shake()
    if @do_shake
      # Move up
      @width.times { @pixels.unshift(@game.tile_types[:dirt]) }
      render()
      # Move down again
      @width.times { @pixels.shift() }
      render()
      # Move down
      @width.times { @pixels.push(@game.tile_types[:dirt]) }
      render()
      # Move up again
      @width.times { @pixels.pop() }
      render()
    end
  end

  def get(x, y)
    return @pixels[y * @width + x]
  end

  def is_solid?(x, y)
    @game.solid_tiles.member?(get(x, y))
  end
  
  def is_solid_in_direction?(direction, x, y)
    ((direction == 'north' && is_solid?(x, y - 1)) ||
     (direction == 'east' && is_solid?(x + 1, y)) ||
     (direction == 'south' && is_solid?(x, y + 1)) ||
     (direction == 'west' && is_solid?(x - 1, y)) ||
     (direction == 'north-east' && is_solid?(x + 1, y - 1)) ||
     (direction == 'south-east' && is_solid?(x + 1, y + 1)) ||
     (direction == 'south-west' && is_solid?(x - 1, y + 1)) ||
     (direction == 'north-west' && is_solid?(x - 1, y - 1)))
  end

  def colorize(s)
    colors =
      [
       # :black,
       :red,
       :green,
       :yellow,
       :blue,
       :magenta,
       :cyan,
       :white,

       # :bg_black,
       :bg_red,
       :bg_green,
       :bg_yellow,
       :bg_blue,
       :bg_magenta,
       :bg_cyan,
       :bg_white,

       :normal,
       :bold,
       :underline,
       :blink,
       :reverse_video,
      ]
    @game.tile_types.values.each_with_index do |tile_type, i|
      s.gsub!(/#{Regexp.quote(tile_type)}/, '\0'.send(colors[i]))
    end
  end

  def render()
    s = ''
    @height.times do |y|
      @width.times do |x|
        # if (@y > 0 && @y < @screen.length) && (@x > 0 && @x < @screen[0].length)
        s += @pixels[y * @width + x]
        # end
      end
      s += "\n"
    end
    clear_screen()
    colorize(s) if @do_colorize
    puts(s)
  end
end
