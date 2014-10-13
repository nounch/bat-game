require 'yaml'

require_relative 'screen'
require_relative 'input'
require_relative 'gui'
require_relative 'entities/player'
require_relative 'entities/npc'
require_relative 'items/stairs'
require_relative 'items/coin'
require_relative 'items/health_up'

require_relative 'weapons/gun'
require_relative 'weapons/orthogonal_gun'
require_relative 'weapons/diagonal_gun'
require_relative 'weapons/all_directions_gun'
require_relative 'weapons/drift_gun'
require_relative 'weapons/tripple_gun'


class Game
  attr_reader :projectiles, :tile_types, :solid_tiles

  def initialize()
    # Load the config file.
    @config = YAML.load(File.read('config/game.yaml'))
    @width = @config['width'] || 80
    @height = @config['height'] || 40
    # Coins
    @num_min_coins = @config['min_coins'] || 5
    @num_max_coins = @config['max_coins'] || 15
    # Health-ups
    @num_min_health_ups = @config['min_health_ups'] || 5
    @num_max_health_ups = @config['max_health_ups'] || 15
    # Bats
    @num_min_bats = @config['min_bats'] || 5
    @num_max_bats = @config['max_bats'] || 15
    # Stairs
    @num_min_stairs = @config['min_stairs'] || 5
    @num_max_stairs = @config['max_stairs'] || 5

    @speed = 0.99
    @tile_types = {
      :blank => ' ',
      :dirt => @config['dirt'] || '.',
      :stone => @config['stone'] || '#',
      :tree => @config['tree'] || '^',
      :water => @config['water'] || '~',  # Unused
      :dead_body => @config['dead_body'] || 'x',
      :player => @config['player'] || '@',
      :bat => @config['bat'] || 'w',
      :coin => @config['coin'] || 'o',
      :health_up => @config['health_up'] || '+',
      :incoming_stairs => @config['incoming_stairs'] || '<',  # Unused
      :outgoing_stairs => @config['stairs'] || '>',
      :star => @config['star'] || '*',
    }
    @solid_tiles = [
                    @tile_types[:stone],
                    @tile_types[:tree],
                    # @tile_types[:water],
                   ]
    @running = false
    @level_counter = 1

    @projectiles = []
    @targets = []

    @screen = Screen.new({:width => @width, :height => @height, :game =>
                           self, :color => @config['color'] || false,
                           :shake => @config['shake'] || false})

    @obstacles = []
    generate()

    @input = Input .new()
    @gui = GUI.new({:screen => @screen, :input => @input})
    @help_message = "Arrows: move - q: boost - w: wander - e: shoot \
- h: help - Space: confirm"
    @gui.show_message(@help_message) {}

    @guns =
      [
       Gun.new({:screen => @screen, :game => self}),
       OrthogonalGun.new({:screen => @screen, :game => self}),
       DiagonalGun.new({:screen => @screen, :game => self}),
       AllDirectionsGun.new({:screen => @screen, :game => self}),
       DriftGun.new({:screen => @screen, :game => self}),
       TrippleGun.new({:screen => @screen, :game => self}),
      ]
    @gun = @guns.sample()
    @player = Player.new({:screen => @screen, :tile =>
                           @tile_types[:player], :game => self, :input =>
                           @input, :gun => @gun, :gui => @gui})

    @coins = []
    add_coins()

    @health_ups = []
    add_health_ups()

    @stairs = []
    add_stairs()

    @bats = []
    add_bats()
  end

  def dispatch_input()
    if @input.keys['104'] == true
      @gui.show_message(@help_message) {}
    end
  end

  def in_player_launch_area?(x, y)
    pad = 5
    !(x < @screen.width / 2 - pad) && !(x > @screen.width / 2 + pad) &&
      !(y < @screen.height / 2 - pad) && !(y > @screen.height / 2 + pad)
  end

  def add_tiles_randomly(tile)
    @screen.height.times do |y|
      @screen.width.times do |x|
        if [true, false].sample()
          if !in_player_launch_area?(x, y)
            @obstacles[y * @screen.width + x] = tile
          end
        end
      end
    end
  end

  def generate()
    # tiles = @solid_tiles.clone()
    # 100.times { tiles << @tile_types[:stone] }
    # 30.times { tiles << @tile_types[:tree] }
    # tiles << @tile_types[:dirt]
    add_tiles_randomly(@tile_types[:tree])
    add_tiles_randomly(@tile_types[:tree])
    add_tiles_randomly(@tile_types[:tree])
    add_tiles_randomly(@tile_types[:tree])
    add_tiles_randomly(@tile_types[:tree])
    add_tiles_randomly(@tile_types[:tree])
    add_tiles_randomly(@tile_types[:tree])
    add_tiles_randomly(@tile_types[:tree])
    add_tiles_randomly(@tile_types[:tree])
    add_tiles_randomly(@tile_types[:tree])
    1.times do
      smoothen_neighbors({:tile => @tile_types[:stone]})
    end
    add_tiles_randomly(@tile_types[:stone])
    5.times do
      smoothen_neighbors({:tile => @tile_types[:stone], :replacer_tile =>
                           @tile_types[:dirt]})
    end

    # 5.times { smoothen() }
  end

  def smoothen_neighbors(options)
    tile = options[:tile] || @tile_types[:stone]
    replacer_tile = options[:replacer_tile] || nil
    @screen.height.times do |y|
      @screen.width.times do |x|
        if neighbors(x, y).count(tile) < 3 && replacer_tile != nil
          @obstacles[y * @screen.width + x] = replacer_tile
        elsif neighbors(x, y).count(@tile_types[:stone]) > 5
          @obstacles[y * @screen.width + x] = tile
        end
      end
    end
  end

  def smoothen()
    # 1.times do
    #   smoothen_neighbors({:tile => @tile_types[:stone], :replacer_tile =>
    #                        @tile_types[:dirt]})
    #   smoothen_neighbors({:tile => @tile_types[:stone]})
    # end
  end

  def put_obstacle_in_direction(direction, x, y, char)
    case direction
    when 'north'
      @obstacles[(y - 1) * @screen.width + x] = char
    when 'east'
      @obstacles[y * @screen.width + x + 1] = char
    when 'south'
      @obstacles[(y + 1) * @screen.width + x] = char
    when 'west'
      @obstacles[y * @screen.width + x - 1] = char
    when 'north-east'
      @obstacles[(y - 1) * @screen.width + x + 1] = char
    when 'south-east'
      @obstacles[(y + 1) * @screen.width + x + 1] = char
    when 'south-west'
      @obstacles[(y + 1) * @screen.width + x - 1] = char
    when 'north-west'
      @obstacles[(y - 1) * @screen.width + x - 1] = char
    end
  end

  def neighbors(x, y)
    neighbors = []
    w = @screen.width
    neighbors << @obstacles[(y - 1) * w + x - 1]
    neighbors << @obstacles[(y - 1) * w + x]
    neighbors << @obstacles[(y - 1) * w + x + 1]
    neighbors << @obstacles[y * w + x + 1]
    neighbors << @obstacles[(y + 1) * w + x + 1]
    neighbors << @obstacles[(y + 1) * w + x]
    neighbors << @obstacles[(y + 1) * w + x - 1]
  end

  def clear_screen()
    puts("\033[H\033[2J")
  end

  def add_coins()
    (@num_min_coins..@num_max_coins).to_a.sample.times do
      x = (0..(@width - 1)).to_a.sample()
      y = (0..(@height - 1)).to_a.sample()
      @coins << Coin.new({:x => x, :y => y, :tile =>
                           @tile_types[:coin], :screen => @screen})
    end
  end

  def add_health_ups()
    (@num_min_health_ups..@num_max_health_ups).to_a.sample.times do
      x = (0..(@width - 1)).to_a.sample()
      y = (0..(@height - 1)).to_a.sample()
      @health_ups << HealthUp.new({:x => x, :y => y, :tile =>
                                    @tile_types[:health_up], :screen =>
                                    @screen})
    end
  end

  def add_bats()
    (@num_min_bats..@num_max_bats).to_a.sample.times do
      x = (0..(@width - 1)).to_a.sample()
      y = (0..(@height - 1)).to_a.sample()
      if !in_player_launch_area?(x, y)
        bat = NPC.new({:x => x, :y => y, :screen => @screen, :tile =>
                        @tile_types[:bat], :game => self})
        @bats << bat
        @targets << bat
      end
    end
  end

  def add_stairs()
    (@num_min_stairs..@num_max_stairs).to_a.sample.times do
      x = (0..(@width - 1)).to_a.sample()
      y = (0..(@height - 1)).to_a.sample()
      @stairs << Stairs.new({:screen => @screen, :x => x, :y => y,
                              :tile => @tile_types[:outgoing_stairs],
                              :type => 'outgoing'})
    end
  end

  def start()
    @running = true
  end

  def render_background()
    @screen.fill(@tile_types[:dirt])
  end

  def fill_screen(char)
    (0..@screen.height).to_a.reverse.each do |y|
      @screen.fill_row(y, char)
      render()
    end
  end

  def check_collisions()
    # Player dead
    if @player.health == 0
      @player.health = 100
      @player.give_gun(@guns.sample())
      @player.revive()
      @player.center()
      @level_counter = 0
      @gui.set_level(@level_counter)
      @player.points = 0
      fill_screen(@tile_types[:dead_body])
      @gui.show_message('You have just died. Sorry.') {}
    end

    # Projectiles and targets
    @targets.each_with_index do |t, i|
      @projectiles.each_with_index do |p, j|
        if p.x == t.x && p.y == t.y && !t.is_dead
          x = [t.x - 1, t.x, t.x + 1].sample()
          y = [t.y - 1, t.y, t.y + 1].sample()
          @coins << Coin.new({:x => x, :y => y, :tile =>
                               @tile_types[:coin], :screen => @screen})

          p.remove()
          t.kill()
          @targets.delete_at(i)
          @projectiles.delete_at(j)
        end
      end
      # Targets and player
      if t.x == @player.x && t.y == @player.y &&
          !t.is_dead && !@player.is_dead
        @player.damage(10) 
        @screen.shake()
      end
    end
    # Projectiles and solid tiles
    @projectiles.each_with_index do |p, i|
      if @screen.is_solid_in_direction?(p.direction, p.x, p.y)
        put_obstacle_in_direction(p.direction, p.x, p.y,
                                  @tile_types[:dirt])
        p.remove()
        @projectiles.delete_at(i)      
      end
      if @screen.is_solid?(p.x, p.y)
        @obstacles[p.y * @screen.height + p.x] = @tile_types[:dirt]
      end
    end
    # Coins and player
    @coins.each_with_index do |c|
      if c.x == @player.x && c.y == @player.y
        idx = @coins.index { |coin| coin.x == @player.x &&
          coin.y == @player.y }
        @player.give_points(@coins[idx].value)
        @coins.delete_at(idx)
      end
    end
    # Health-ups and player
    @health_ups.each_with_index do |h|
      if h.x == @player.x && h.y == @player.y
        idx = @health_ups.index { |hu| hu.x == @player.x &&
          hu.y == @player.y }
        @player.give_health(@health_ups[idx].value)
        @health_ups.delete_at(idx)
      end
    end
    # Stairs and player
    @stairs.each_with_index do |s|
      if s.x == @player.x && s.y == @player.y && s.type == 'outgoing'
        # Go to next level.

        # 1. Remove current things.
        @bats = []
        @coins = []
        @health_ups = []
        @projectiles = []
        @stairs = []

        fill_screen(@tile_types[:star])

        @level_counter += 1
        @gui.set_level(@level_counter)

        @gui.show_new_level_screen() {
          # 2. Add new things.
          generate()
          @player.center()
          @player.give_gun(@guns.sample())
          add_bats()
          add_coins()
          add_health_ups()
          add_stairs()
        }

      end
    end
  end

  def render_obstacles()
    @screen.height.times do |y|
      @screen.width.times do |x|
        char = @obstacles[y * @screen.width + x]
        @screen.put(x, y, char) if char != @tile_types[:dirt] &&
          char != nil
      end
    end
  end

  def tick()
    @input.handle_input()
    dispatch_input()
    render_background()
    render_obstacles()

    @bats.each { |bat| bat.tick() }
    @coins.each { |coin| coin.tick() }
    @health_ups.each { |health_up| health_up.tick() }
    @stairs.each { |stair| stair.tick() }

    @player.tick()

    @gui.set_health(@player.health)
    @gui.set_points(@player.points)
    @gui.tick()

    @projectiles.each { |r| r.tick() }

    check_collisions()
    render()
  end

  def render()
    @screen.render()
  end

  def run()
    while true
      tick()
      sleep(1 - @speed)
    end
  end
end

game = Game.new()
game.run()
