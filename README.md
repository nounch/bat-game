# Bat Game

This is a game running in your favorite ANSI terminal or terminal emulator.

It is not turn-based. Instead there are "animations" and even colors, if
you want.

It uses characters only (they can be configured):

    .  Dirt
    #  Stone
    ^  Tree
    x  Dead body
    @  Player
    w  Bat
    o  Coin
    +  Health-up
    >  Stairs

# Here Is How You Run It

Run either of the following in your terminal or terminal emulator:

> ./run

or

> ruby game.rb

Quit the game by hitting `Ctrl + c` or sending the appropriate
termination/kill signal otherwise.

# Configuration

There is a `game.yaml` config file in the `config` directory. It is
self-explanatory.

You can adjust the number of items on the screen etc. By default, colors
are disabled.

# Technicalities

The game continually writes to STDOUT and then clears the screen in rapid
succession to produce the illusion of motion pictures.
**This is an ugly hack.** But it works.

Clearing the screen is achieved by running `tput clear` or simply writing
the ANSI clear escape sequence (`\033[H\033[2J`) to STDOUT if `tput` is not
available. The game does not use curses/ncurses. Key presses are read by
calling Ruby's `IO::read_nonblock` after switching to raw input mode
(`stty raw -echo`). The normal input mode is restored using
`stty -raw echo`.

The higher the refresh rate of your terminal or terminal emulator, the
better the game should look, in general (adjust it, if possilbe).
Flickering will always be an issue, though.

Colors are achieved by writing ANSI escape sequences to STDOUT instead of
normal characters. This increases the number of bytes to be processed per
unit of time, so the flickering pattern may diverges a bit in terminals
with slow refresh rate (probably not a problem with most modern emulators,
though).

# Platform-Compatibility

The game is *nix-only due to it using `stty` for input. This can be
changed, though, by using the native raw input mode switch for the target
platform. Not much more than a few changes to `input.rb` and manual testing
should be required for that. Also keep in mind that for screen clearing and
color support an ANSI-compliant terminal/terminal emulator is required. If
you can live without colors and have other means to clear the screen,
ANSI-compliance is not required.
