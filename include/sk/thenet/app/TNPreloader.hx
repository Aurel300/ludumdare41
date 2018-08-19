package sk.thenet.app;

import haxe.ds.Vector;
import sk.thenet.FM;
import sk.thenet.anim.Timing;
import sk.thenet.audio.Output;
import sk.thenet.bmp.*;
import sk.thenet.bmp.manip.*;
import sk.thenet.geom.Point2DI;
import sk.thenet.plat.Platform;
import sk.thenet.stream.bmp.*;

class TNPreloader extends Preloader {
  private inline static var rectW:Int = 64;
  private inline static var rectH:Int = 64;
  
  public var useBytes:Bool = false;
  
  private var nextState:String;
  private var fast:Bool;
  private var pal:Array<Colour>;
  private var phase:TNPhase;
  private var rectTiming:Timing;
  private var logo:Bitmap;
  private var logoAppear:Bitmap;
  private var blipBloop:Output;
  private var load:Vector<Bitmap>;
  private var loaded:Int = 0;
  
  public function new(app:Application, nextState:String, ?fast:Bool = false){
    super("preloader", app);
    this.nextState = nextState;
    this.fast = fast;
  }
  
  override public function init():Void {
    rectTiming = Timing.quadInOut;
    
    pal = [
         0xFFFF7722 // 0 orange
        ,0xFFAA0000 // 1 crimson
        ,0xFF550022 // 2 dark crimson
        ,0xFFCCCCCC // 3 light gray
        ,0xFF999999
        ,0xFF666666
        ,0xFF333333 // 6 dark gray
      ];
    var logo16 = Vector.fromArrayCopy([
         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
        ,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
        ,1,1,1,1,1,3,3,4,4,5,1,1,1,1,1,2
        ,1,1,1,1,4,3,4,4,4,5,6,1,1,1,1,2
        ,1,1,1,1,0,0,0,0,0,0,0,2,1,1,1,2
        ,1,1,1,1,1,5,5,5,6,6,2,2,1,1,1,2
        ,1,1,1,1,5,4,4,4,4,5,6,2,1,1,1,2
        ,1,1,1,1,5,3,4,4,4,5,6,2,1,1,1,2
        ,1,1,1,1,4,6,4,4,5,6,5,2,1,1,1,2
        ,1,1,1,1,4,5,2,2,4,2,5,2,1,1,1,2
        ,1,1,1,1,3,5,2,1,4,2,4,2,1,1,1,2
        ,1,1,1,1,3,5,2,1,1,2,3,2,1,1,1,2
        ,1,1,1,1,4,2,1,1,1,1,1,2,1,1,1,2
        ,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
        ,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
        ,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
      ].map(function(i) return pal[i]));
    var logo64 = new Vector<Colour>(rectW * rectH);
    var i = 0;
    for (y in 0...rectH) for (x in 0...rectW){
      logo64[i] = logo16[(x >> 2) + ((y >> 2) << 4)];
      i++;
    }
    logo = Platform.createBitmap(rectW, rectH, 0);
    logo.setVector(logo64);
    
    var dither = OrderedDither.BAYER_4;
    
    logoAppear = Platform.createBitmap(rectW, rectH, 0);
    logoAppear.setVector(Vector.fromArrayCopy([
        for (y in 0...64) for (x in 0...64){
          var dx = x - 48;
          var dy = y + 10;
          var d = Math.sqrt(dx * dx + dy * dy);
          var a = Math.atan2(dy, dx);
          var v = (64 - (x >> 1) + y) * 2;
          v += FM.floor(Math.sin(d / 4) * Math.sin(a * 5) * 30);
          v += dither[(x % 4) + (y % 4) * 4] * 3;
          v = -FM.clampI(v, 0, 255);
          new Colour(v << 24);
        }
      ]));
    
    var load8 = Vector.fromArrayCopy([
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ,2,1,0,0,2,2,2,1,2,2,2,1,2,2,1,0
        ,2,1,0,0,2,1,2,1,2,1,2,1,2,1,2,1
        ,2,1,0,0,2,1,2,1,2,2,2,1,2,1,2,1
        ,2,1,0,0,2,1,2,1,2,1,2,1,2,1,2,1
        ,2,1,0,0,2,1,2,1,2,1,2,1,2,1,2,1
        ,2,2,2,1,2,2,2,1,2,1,2,1,2,2,1,0
        ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      ]);
    
    load = Vector.fromArrayCopy([
        for (i in 0...3){
          var l = Platform.createBitmap(rectW, rectH, 0);
          l.setVector(Vector.fromArrayCopy([
              for (y in 0...64) for (x in 0...64){
                new Colour(switch (load8[(x >> 2) + ((y >> 2) << 4)]){
                  case 1:
                  if (i == 0){
                    0;
                  } else if (i == 1){
                    pal[5];
                  } else {
                    pal[6];
                  }
                  case 2:
                  if (i == 0){
                    pal[5];
                  } else {
                    pal[4];
                  }
                  case _: 0;
                });
              }
            ]));
          l;
        }
      ]);
    blipBloop = Platform.createAudioOutput();
    blipBloop.sample = function(offset:Float, buffer:Vector<Float>):Void {
      for (i in 0...8192){
        var v = (if (offset + i < 4000){
            Math.sin((i + offset) / 30);
          } else if (offset + i < 12000){
            (Math.sin((i + offset) / 20)
              + Math.sin((i + offset) / Math.sin(10 - (offset + i) / 3000) / 200) * .4
              + Math.sin((i + offset) / 5) * .1)
              * (1 - (offset + i - 4000) / 9000);
          } else {
            0;
          }) * .2;
        buffer[i << 1] = v;
        buffer[(i << 1) + 1] = -v;
      }
    };
  }
  
  override public function to():Void {
    phase = Waiting(10, Rect(0));//Logo(0));
    app.bitmap.fill(0xFF333333);
  }
  
  override public function tick():Void {
    var rectX = (app.bitmap.width >> 1) - 32;
    var rectY = (app.bitmap.height >> 1) - 32;
    
    if (useBytes) {
#if flash
      var bytesLoaded = flash.Lib.current.stage.loaderInfo.bytesLoaded;
      var bytesTotal  = flash.Lib.current.stage.loaderInfo.bytesTotal;
      progressBytes(bytesLoaded, bytesTotal);
#end
    }
    phase = (switch (phase){
        case Waiting(0, next): next;
        case Waiting(num, next): Waiting(num - 1, next);
        
        case Rect(60): Load(0);
        case Rect(shown):
        var pos:Array<Int> = [
             (shown - 7 ) / 18
            ,(shown     ) / 22
            ,(shown - 13) / 18
            ,(shown - 6 ) / 22
            ,(shown - 30) / 18
            ,(shown - 23) / 22
            ,(shown - 36) / 18
            ,(shown - 29) / 22
          ].map(function(x) return rectTiming.getI(x, rectW - 1));
        
        if (pos[0] != pos[1]) Bresenham.getCurve(
               new Point2DI(rectX + pos[0], rectY + rectH - 1)
              ,new Point2DI(rectX + pos[1], rectY + rectH - 1)
            ).apply(app.bitmap, 0xFF999999);
        Bresenham.getCurve(
             new Point2DI(rectX, rectY + rectH - 1)
            ,new Point2DI(rectX + pos[0], rectY + rectH - 1)
          ).apply(app.bitmap, 0xFF666666);
        if (pos[2] != pos[3]) Bresenham.getCurve(
               new Point2DI(rectX, rectY + rectH - 1 - pos[2])
              ,new Point2DI(rectX, rectY + rectH - 1 - pos[3])
            ).apply(app.bitmap, 0xFF999999);
        Bresenham.getCurve(
               new Point2DI(rectX, rectY + rectH - 1)
              ,new Point2DI(rectX, rectY + rectH - 1 - pos[2])
          ).apply(app.bitmap, 0xFF666666);
        if (pos[4] != pos[5]) Bresenham.getCurve(
               new Point2DI(rectX + pos[4], rectY)
              ,new Point2DI(rectX + pos[5], rectY)
            ).apply(app.bitmap, 0xFF999999);
        if (pos[5] != 0) Bresenham.getCurve(
                 new Point2DI(rectX + pos[4], rectY)
                ,new Point2DI(rectX, rectY)
            ).apply(app.bitmap, 0xFF666666);
        if (pos[6] != pos[7]) Bresenham.getCurve(
               new Point2DI(rectX + rectW - 1, rectY + rectH - 1 - pos[6])
              ,new Point2DI(rectX + rectW - 1, rectY + rectH - 1 - pos[7])
            ).apply(app.bitmap, 0xFF999999);
        if (pos[7] != 0) Bresenham.getCurve(
                 new Point2DI(rectX + rectW - 1, rectY + rectH - 1 - pos[6])
                ,new Point2DI(rectX + rectW - 1, rectY + rectH - 1)
            ).apply(app.bitmap, 0xFF666666);
        Rect(shown + 1);
        
        case Load(12): Logo(0);
        case Load(shown):
        app.bitmap.blitAlpha(load[shown >> 2], rectX, rectY);
        Load(shown + 1);
        
        case Logo(shown) if (shown > 255):
        app.bitmap.blitAlpha(logo, rectX, rectY);
        Waiting(10, LogoBlip(0));
        case Logo(shown):
        var mask1 = logoAppear.fluent >> (new Cut(0, 0, rectW, rectH))
          << (new Threshold(255 - shown - 10));
        var grayMasked = Platform.createBitmap(rectW, rectH, 0xFF666666).fluent
          << (new AlphaMask(mask1));
        app.bitmap.blitAlpha(grayMasked, rectX, rectY);
        
        var mask2 = logoAppear.fluent >> (new Cut(0, 0, rectW, rectH))
          << (new Threshold(255 - shown));
        var logoMasked = logo.fluent >> (new Cut(0, 0, rectW, rectH));
        
        logoMasked << (new AlphaMask(mask2));
        app.bitmap.blitAlpha(logoMasked, rectX, rectY);
        
        if (loaded > shown){
          Logo(FM.minI(shown + 4, loaded));
        } else {
          Logo(shown);
        }
        
        case LogoBlip(6): Waiting(120, Ready);
        case LogoBlip(shown):
        if (shown == 0){
          blipBloop.play();
        }
        app.bitmap.fillRect(rectX + 4 * 4, rectY + 4 * 4, 6 * 4, 4, pal[0]);
        app.bitmap.fillRect(rectX + 4 * 4 + shown * 4, rectY + 4 * 4, 4, 4, pal[1]);
        LogoBlip(shown + 1);
        
        case Ready:
        blipBloop.stop();
        done();
        Ready;
      });
  }
  
  override public function mouseClick(_, _):Void {
    //phase = Rect(0);
  }
  
  public function progressBytes(b1:Int,b2:Int):Void {
    var total:Float = b1 / b2;
    var all:Bool = b1 == b2;
    if (all){
      loaded = 256;
      if (fast){
        //phase = LogoBlip(0);
        done();
      }
    } else {
      loaded = FM.floor(total * 255);
    }
  }
  
  private function done():Void {
    if (useBytes) {
      var cls = Type.resolveClass("Main");
      var app = Type.createInstance(cls, []);
    } else {
      app.applyState(app.getStateById(nextState));
    }
  }
  
  override public function progress(assets:Array<Asset>):Void {
    var total:Float = 0;
    var all:Bool = true;
    for (a in assets){
      if (a.type != Bitmap && a.type != Sound){
        continue;
      }
      switch (a.status){
        case Loaded: total += 1 / assets.length;
        case Loading(p): total += p / assets.length; all = false;
        case _: all = false;
      }
    }
    if (all){
      loaded = 256;
      if (fast){
        //phase = LogoBlip(0);
        app.applyState(app.getStateById(nextState));
      }
    } else {
      loaded = FM.floor(total * 255);
    }
  }
  
  /*
  override public function mouseMove(_, _):Void {
    if (loaded < 256) loaded++;
  }
  */
}

private enum TNPhase {
  Waiting(num:Int, next:TNPhase);
  Rect(shown:Int);
  Load(shown:Int);
  Logo(shown:Int);
  LogoBlip(shown:Int);
  Ready;
}
