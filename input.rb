# require 'pp'  # DEBUG


class Input
  attr_accessor :keys

  def initialize()
    @keys = {}
    @io = STDIN
  end

  def handle_input()
    system('stty raw -echo')
    begin
      @keys = {}
      key = @io.read_nonblock(1).ord.to_s
      @keys[key] = true
    rescue
      # Ignore it.
    end
    # DEBUG
    #
    # puts(PP.pp(keys, ''))
    system('stty -raw echo')
  end
end

