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
  public static inline var W:Int = 320;
  public static inline var H:Int = 240;
  public static inline var WH:Int = W * H;
  
  public function new() {
    super([
         Framerate(60)
        ,Optional(Window("", 640, 480))
        ,Surface(320, 240, 1)
        ,Assets([
          ])
        ,Keyboard
        ,Mouse
      ]);
    preloader = new TNPreloader(this, "test", true);
    addState(new STest(this));
    mainLoop();
  }
}
