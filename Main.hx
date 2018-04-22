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
            ,Embed.getSound("snd-cut", "wav/cut.wav")
            ,Embed.getSound("snd-cut-start", "wav/cut-start.wav")
            ,new AssetBind(["pal"], (am, _) -> { Pal.init(am.getBitmap("pal")); false; })
            ,new AssetBind(["ing"], (am, _) -> { Board.init(am.getBitmap("ing")); false; })
            ,new AssetBind(["unit"], (am, _) -> { Unit.init(am.getBitmap("unit")); false; })
            ,new AssetBind(["gui"], (am, _) -> { GUI.init(am.getBitmap("gui")); false; })
            ,new AssetBind([
                 "snd-cut"
                ,"snd-cut-start"
              ], (am, _) -> { Sfx.init(am); false; })
          ])
        ,Keyboard
        ,Mouse
      ]);
    Trig.init();
    preloader = new TNPreloader(this, "game", true);
    addState(g = new SGame(this));
    mainLoop();
  }
}
