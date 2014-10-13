class DiagonalGun
  attr_accessor :projectile_boost

  def initialize(options)
    @screen = options[:screen] || nil
    @game = options[:game] || nil
    @projectile_boost = 1
  end

  def shoot(x, y, direction)
    Projectile.new({:x => x, :y => y, :direction =>
                     'north-east', :screen => @screen, :game =>
                     @game, :boost => @projectile_boost})
    Projectile.new({:x => x, :y => y, :direction =>
                     'south-east', :screen => @screen, :game =>
                     @game, :boost => @projectile_boost})
    Projectile.new({:x => x, :y => y, :direction =>
                     'south-west', :screen => @screen, :game =>
                     @game, :boost => @projectile_boost})
    Projectile.new({:x => x, :y => y, :direction =>
                     'north-west', :screen => @screen, :game =>
                     @game, :boost => @projectile_boost})
  end
end
