package lib;

import sk.thenet.anim.*;
import sk.thenet.audio.*;

class Crossfade {
  public var state:Bitween;
  public var channel:IChannel;
  
  public function new(id:String) {
    state = new Bitween(60);
    channel = Sfx.play(id, true);
    channel.setVolume(0);
  }
  
  public function tick(?playing:Bool = false, ?vol:Float = 1, ?pan:Float = 0) {
    state.setTo(playing);
    state.tick();
    channel.setVolume(state.valueF * vol);
    channel.setPan(pan);
  }
  
  public var playing(never, set):Bool;
  private inline function set_playing(to:Bool):Bool {
    state.setTo(to);
    return to;
  }
  
  private var pan(never, set):Float;
  private inline function set_pan(to:Float):Float {
    channel.setPan(to);
    return to;
  }
}
