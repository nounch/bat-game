class TrippleGun
  attr_accessor :projectile_boost

  def initialize(options)
    @screen = options[:screen] || nil
    @game = options[:game] || nil
    @projectile_boost = 1
  end

  def shoot(x, y, direction)
    if ['east', 'west'].member?(direction)
      Projectile.new({:x => x, :y => y, :direction =>
                       direction, :screen => @screen, :game =>
                       @game, :boost => @projectile_boost})
      Projectile.new({:x => x, :y => y + 1, :direction =>
                       direction, :screen => @screen, :game =>
                       @game, :boost => @projectile_boost})
      Projectile.new({:x => x, :y => y - 1, :direction =>
                       direction, :screen => @screen, :game =>
                       @game, :boost => @projectile_boost})
    else
      Projectile.new({:x => x, :y => y, :direction =>
                       direction, :screen => @screen, :game =>
                       @game, :boost => @projectile_boost})
      Projectile.new({:x => x + 1, :y => y, :direction =>
                       direction, :screen => @screen, :game =>
                       @game, :boost => @projectile_boost})
      Projectile.new({:x => x - 1, :y => y, :direction =>
                       direction, :screen => @screen, :game =>
                       @game, :boost => @projectile_boost})
    end
  end
end
