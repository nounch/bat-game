class Gun
  attr_accessor :projectile_boost

  def initialize(options)
    @screen = options[:screen] || nil
    @game = options[:game] || nil
    @projectile_boost = 1
  end

  def shoot(x, y, direction)
    Projectile.new({:x => x, :y => y, :direction =>
                     direction, :screen => @screen, :game =>
                     @game, :boost => @projectile_boost})
  end
end
