package lib;

import sk.thenet.anim.*;
import sk.thenet.bmp.manip.*;
import sk.thenet.geom.*;
import sk.thenet.plat.Platform;

class GUI {
  public static var as:Map<String, Bitmap>;
  public static var dropArrow:Array<Bitmap>;
  public static var turnBit:Array<Bitmap>;
  public static var banners:Map<UnitRank, Bitmap>;
  public static var traits:Map<UnitTrait, Bitmap>;
  public static var stars:Array<Bitmap>;
  
  public static var panels:Map<String, GUI>;
  
  public static function init(b:FluentBitmap):Void {
    as = [
         "timer1" => b >> new Cut(0, 8, 32, 40)
        ,"timer2" => b >> new Cut(32, 8, 32, 40)
        ,"timerEx" => b >> new Cut(64, 8, 32, 32)
        ,"trash" => b >> new Cut(0, 48, 48, 48)
        ,"deploy" => b >> new Cut(48 * 2, 48, 48, 48)
        ,"drop" => b >> new Cut(0, 96, 64, 64)
        ,"dropArrow" => b >> new Cut(64, 96, 64, 64)
        ,"stats" => b >> new Cut(0, 160, 120, 80)
        ,"turn" => b >> new Cut(128, 96, 120, 120)
        ,"turnBit" => b >> new Cut(128, 96 + 120, 120, 120)
        ,"box" => b >> new Cut(96, 8, 16, 16)
      ];
    banners = [
         RankS => Text.banner(Platform.createBitmap(40, 32, 0), "S")
        ,RankA => Text.banner(Platform.createBitmap(40, 32, 0), "A")
        ,RankB => Text.banner(Platform.createBitmap(40, 32, 0), "B")
        ,RankD => Text.banner(Platform.createBitmap(40, 32, 0), "D")
        ,RankF => Text.banner(Platform.createBitmap(40, 32, 0), "F")
      ];
    stars = [ for (y in 0...2) for (x in 0...3) b >> new Cut(112 + x * 16, 8 + y * 16, 12, 12) ];
    var i = 0;
    traits = [
         Healer => b >> new Cut(i++ * 17, 240, 17, 17)
        ,Smell => b >> new Cut(i++ * 17, 240, 17, 17)
        ,Poison => b >> new Cut(i++ * 17, 240, 17, 17)
        ,Toxic => b >> new Cut(i++ * 17, 240, 17, 17)
      ];
    dropArrow = [ for (i in 0...Trig.densityAngle)
      as["dropArrow"].fluent
        >> new Rotate((i / Trig.densityAngle) * Math.PI * 2)
        >> new Grow(-32, -32, -32, -32) ];
    turnBit = [ for (i in 0...Trig.densityAngle)
      as["turnBit"].fluent
        >> new Rotate((-i / Trig.densityAngle) * Math.PI * 2)
        >> new Grow(-60, -60, -60, -60) ];
    panels = [
         "drop" => new GUI(-64, 128, 8, 128, [as["drop"], dropArrow[0]])
        ,"stats" => new GUI(Main.W, Main.H - 88, Main.W - 128, Main.H - 88, [as["stats"], Platform.createBitmap(120, 80, 0)])
        ,"trash" => new GUI(8, Main.H, 8, Main.H - 46, [as["trash"]])
        ,"deploy" => new GUI(Main.W - 48 - 8, -48, Main.W - 48 - 8, -2, [as["deploy"]])
        ,"timer" => new GUI(-32, 8, 8, 8, [as["timer1"]])
        ,"dropInfo" => new GUI(-120, 8, 8, 8, [as["box"].fluent >> new Box(new Point2DI(3, 3), new Point2DI(13, 13), 120, 32) >> new Grow(0, 0, 0, 10), Platform.createBitmap(120, 42, 0)])
      ];
    panels["drop"].ignoreClicks = true;
    Text.render(panels["trash"].bs[0], 4, 30, "Destroy!");
    Text.render(panels["deploy"].bs[0], 8, 24, "Deploy!");
    panels["trash"].moy = -2;
    panels["deploy"].moy = 2;
  }
  
  public static function clickAll(mx:Int, my:Int):Bool {
    for (p in panels) {
      if (p.click(mx, my)) return true;
    }
    return false;
  }
  
  public static function renderAll(to:Bitmap, mx:Int, my:Int):Bool {
    var mo = false;
    for (p in panels) {
      if (p.render(to, mx, my)) {
        mo = true;
        mx = my = -1;
      }
    }
    return mo;
  }
  
  public static function show(id:String):Void panels[id].state.setTo(true);
  public static function hide(id:String):Void panels[id].state.setTo(false);
  
  public static var currentStatsGrid:Bool = false;
  
  public static function showStats(s:UnitStats, ?fromGrid:Bool = false):Void {
    currentStatsGrid = fromGrid;
    var b = panels["stats"].bs[1];
    b.fill(0);
    Text.render(b, 5, 21 - 18, s.name);
    Text.render(b, 25, 21, 'HP: ${s.hp}/${s.hpMax}');
    Text.render(b, 25, 21 + 18, 'AP: ${s.ap}');
    Text.render(b, 25, 21 + 18 * 2, 'MP: ${s.mp}/${s.mpMax}');
    if (s.rank != null) {
      Text.render(b, 82, 21 + 18, "Rank");
      b.blitAlpha(banners[s.rank], 80, 45);
    }
    var curx = 120 - 5 - 17;
    for (t in s.traits) {
      b.blitAlpha(traits[t], curx, 3);
      curx -= 18;
    }
    show("stats");
  }
  
  public static function showDropInfo(m:String, ?r:UnitRank):Void {
    var b = panels["dropInfo"].bs[1];
    b.fill(0);
    var curx = 4;
    if (r != null) {
      Text.render(b, 4, 2, "Rank");
      b.blitAlpha(banners[r], 2, 8);
      curx += 38;
    }
    Text.render(b, curx, 2, m);
    show("dropInfo");
  }
  
  public var state = new Bitween(30);
  public var px1:Int;
  public var py1:Int;
  public var px2:Int;
  public var py2:Int;
  public var w:Int;
  public var h:Int;
  public var mox:Int = 0;
  public var moy:Int = 0;
  public var bs:Array<Bitmap>;
  public var ignoreClicks:Bool = false;
  
  public function new(px1:Int, py1:Int, px2:Int, py2:Int, bs:Array<Bitmap>) {
    this.px1 = px1;
    this.py1 = py1;
    this.px2 = px2;
    this.py2 = py2;
    this.bs = bs;
    w = bs[0].width;
    h = bs[0].height;
  }
  
  public dynamic function action():Void {}
  
  public function click(mx:Int, my:Int):Bool {
    if (!state.isOn || ignoreClicks) return false;
    var px = px1 + ((px2 - px1) * Timing.quadInOut.getF(state.valueF)).floor();
    var py = py1 + ((py2 - py1) * Timing.quadInOut.getF(state.valueF)).floor();
    if (mx.withinI(px, px + w - 1) && my.withinI(py, py + h - 1)) {
      action();
      return true;
    }
    return false;
  }
  
  public function render(to:Bitmap, mx:Int, my:Int):Bool {
    var mo:Bool = false;
    state.tick();
    if (state.isOff) return false;
    var px = px1 + ((px2 - px1) * Timing.quadInOut.getF(state.valueF)).floor();
    var py = py1 + ((py2 - py1) * Timing.quadInOut.getF(state.valueF)).floor();
    if (state.isOn && mx != -1 && my != -1 && mx.withinI(px, px + w - 1) && my.withinI(py, py + h - 1)) {
      px += mox;
      py += moy;
      mo = true;
    }
    for (b in bs) if (b != null) {
      to.blitAlpha(b, px, py);
    }
    return mo;
  }
}
