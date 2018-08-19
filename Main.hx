import sk.thenet.app.*;
import sk.thenet.app.TNPreloader;
import sk.thenet.app.asset.Bind as AssetBind;
import sk.thenet.app.asset.Bitmap as AssetBitmap;
import sk.thenet.app.asset.Sound as AssetSound;
import sk.thenet.app.asset.Trigger as AssetTrigger;
import sk.thenet.bmp.*;
import sk.thenet.plat.Platform;

import lib.*;

using sk.thenet.FM;
using sk.thenet.stream.Stream;

class Main extends Application {
  public static var i:Main;
  public static var g:SGame;
  
  public static inline var W:Int = 320;
  public static inline var H:Int = 240;
  public static inline var WH:Int = W * H;
  public static inline var W2:Int = W >> 1;
  public static inline var H2:Int = H >> 1;
  
  public function new() {
    i = this;
    super([
         Framerate(60)
        ,Optional(Window("", 640, 480))
        ,Surface(320, 240, 1)
        ,Assets([
             Embed.getBitmap("test", "png/test.png")
            ,Embed.getBitmap("rv", "png/rv.png")
            ,Embed.getBitmap("pal", "png/pal.png")
            ,Embed.getBitmap("ing", "png/ing.png")
            ,Embed.getBitmap("unit", "png/unit.png")
            ,Embed.getBitmap("gui", "png/gui.png")
            ,Embed.getBitmap("world", "png/world.png")
            ,Embed.getBitmap("interp", "png/interp.png")
            ,Embed.getBitmap(font.FontNS.ASSET_ID, "png/font.png")

            ,Embed.getSound("snd-cut-start", "wav/cut-start.wav")

            ,Embed.getSound("snd-burn", "wav/burn.mp3")
            ,Embed.getSound("snd-cut1", "wav/cut1.mp3")
            ,Embed.getSound("snd-engine", "wav/engine.mp3")
            ,Embed.getSound("snd-flip1", "wav/flip1.mp3")
            ,Embed.getSound("snd-flip2", "wav/flip2.mp3")
            ,Embed.getSound("snd-hit1", "wav/hit1.mp3")
            ,Embed.getSound("snd-hit2", "wav/hit2.mp3")
            ,Embed.getSound("snd-knife", "wav/knife.mp3")
            ,Embed.getSound("snd-pepsalt", "wav/pepsalt.mp3")
            ,Embed.getSound("snd-sauce", "wav/sauce.mp3")
            ,Embed.getSound("snd-sizzle-start", "wav/sizzle-start.mp3")
            ,Embed.getSound("snd-sizzle", "wav/sizzle.mp3")
            
            ,Embed.getSound("snd-music-battle", "wav/music-battle.mp3")
            ,Embed.getSound("snd-music-roam", "wav/music-roam.mp3")
            ,Embed.getSound("snd-tune-battle", "wav/tune-battle.mp3")
            
            ,new AssetTrigger("pal-t", ["pal"], (am, _) -> { Pal.init(am.getBitmap("pal")); false; })
            ,new AssetTrigger("text-t", [font.FontNS.ASSET_ID, "pal-t"], (am, _) -> { Text.init(am); false; })
            ,new AssetBind(["ing", "pal-t"], (am, _) -> { Board.init(am.getBitmap("ing")); false; })
            ,new AssetBind(["unit", "rv"], (am, _) -> { Unit.init(am.getBitmap("unit"), am.getBitmap("rv")); false; })
            ,new AssetBind(["gui", "text-t"], (am, _) -> { GUI.init(am.getBitmap("gui")); false; })
            ,new AssetBind(["world", "interp", "unit"], (am, _) -> { World.init(am.getBitmap("world"), am.getBitmap("interp"), am.getBitmap("unit")); false; })
            ,new AssetBind(["snd-hit1"], (am, _) -> { Sfx.init(am); false; })
          ])
        ,Keyboard
        ,Mouse
      ]);
    Trig.init();
    preloader = new TNPreloader(this, "title", true);
    addState(new STitle(this));
    addState(g = new SGame(this));
    mainLoop();
  }
}
