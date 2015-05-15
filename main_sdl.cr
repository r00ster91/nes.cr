require "./sdl/sdl"
require "./src/nes"

filename = ARGV.first? || abort("error: missing rom filename")
nes = Nes.new filename

p "PRG banks: #{nes.rom.prg_banks}"
p "CHR banks: #{nes.rom.chr_banks}"
p "MAPPER: #{nes.rom.mapper_number}"

SDL.init
SDL.show_cursor

surface = SDL.set_video_mode 256, 240, 32, LibSDL::DOUBLEBUF | LibSDL::HWSURFACE | LibSDL::ASYNCBLIT
last_rendered_at = 0
last_tick_cycles = SDL.ticks
cycles = 0

def color(x)
  r = (x >> 16) & 0xFF
  g = (x >> 8) & 0xFF
  b = x & 0xFF
  (b << 24) | (g << 16) | (r << 8) | 0xFF
end

count = 0

while true
  count += 1

  if count % 100 == 0
    SDL.poll_events do |event|
      case event.type
      when LibSDL::QUIT
        SDL.quit
        exit
      when LibSDL::KEYDOWN
        case event.key.key_sym.sym
        when LibSDL::Key::Z
          nes.control_pad.press(ControlPad::Button::A)
        when LibSDL::Key::X
          nes.control_pad.press(ControlPad::Button::B)
        when LibSDL::Key::UP
          nes.control_pad.press(ControlPad::Button::Up)
        when LibSDL::Key::DOWN
          nes.control_pad.press(ControlPad::Button::Down)
        when LibSDL::Key::LEFT
          nes.control_pad.press(ControlPad::Button::Left)
        when LibSDL::Key::RIGHT
          nes.control_pad.press(ControlPad::Button::Right)
        when LibSDL::Key::O
          nes.control_pad.press(ControlPad::Button::Start)
        when LibSDL::Key::P
          nes.control_pad.press(ControlPad::Button::Select)
        end
      when LibSDL::KEYUP
        case event.key.key_sym.sym
        when LibSDL::Key::Z
          nes.control_pad.release(ControlPad::Button::A)
        when LibSDL::Key::X
          nes.control_pad.release(ControlPad::Button::B)
        when LibSDL::Key::UP
          nes.control_pad.release(ControlPad::Button::Up)
        when LibSDL::Key::DOWN
          nes.control_pad.release(ControlPad::Button::Down)
        when LibSDL::Key::LEFT
          nes.control_pad.release(ControlPad::Button::Left)
        when LibSDL::Key::RIGHT
          nes.control_pad.release(ControlPad::Button::Right)
        when LibSDL::Key::O
          nes.control_pad.release(ControlPad::Button::Start)
        when LibSDL::Key::P
          nes.control_pad.release(ControlPad::Button::Select)
        end
      end
    end
  end

  cycles += nes.step

  now = SDL.ticks

  if now - last_tick_cycles >= 1000
    last_tick_cycles = now
    p "Cycles per second: #{cycles}"
    cycles = 0
  end

  if now - last_rendered_at > 40
    last_rendered_at = now

    surface.lock

    256.times do |x|
      240.times do |y|
        surface[x, y] = color(nes.ppu.shown[x][y])
      end
    end

    surface.unlock
    surface.flip
  end
end

