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
  public static var cursors:Map<Cursor, Bitmap>;
  public static var cursor:Cursor = Normal;
  public static var tooltip:String = "";
  
  static var lastTooltip:String = "";
  static var tooltipW:Int = 0;
  static var tooltipX:Float = Main.W;
  static var tooltipTX:Int = Main.W;
  static var tooltipB:Bitmap;
  
  public static var panels:Map<String, GUI>;
  
  static var textra = 148;
  
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
        ,"hud" => b >> new Cut(144, 40, 112, 24)
        ,"hudHealth" => b >> new Cut(144, 64, 61, 7)
        ,"hudTimer" => b >> new Cut(144, 72, 62, 5)
      ];
    tooltipB = Platform.createBitmap(Main.W2, 12, 0);
    banners = [
         RankS => Text.banner(Platform.createBitmap(40, 32, 0), "S")
        ,RankA => Text.banner(Platform.createBitmap(40, 32, 0), "A")
        ,RankB => Text.banner(Platform.createBitmap(40, 32, 0), "B")
        ,RankD => Text.banner(Platform.createBitmap(40, 32, 0), "D")
        ,RankF => Text.banner(Platform.createBitmap(40, 32, 0), "F")
      ];
    var i = 0;
    cursors = [
         Normal => b >> new Cut(160 + i++ * 16, 8, 16, 16)
        ,Hover => b >> new Cut(160 + i++ * 16, 8, 16, 16)
        ,Left => b >> new Cut(160 + i++ * 16, 8, 16, 16)
        ,Right => b >> new Cut(160 + i++ * 16, 8, 16, 16)
      ];
    stars = [ for (y in 0...2) for (x in 0...3) b >> new Cut(112 + x * 16, 8 + y * 16, 12, 12) ];
    i = 0;
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
    var transBg:FluentBitmap = Platform.createBitmap(Main.W, 32, 0);
    transBg.fillRect(0, 8, Main.W, 16, Pal.reg[1]);
    panels = [
         "drop" => new GUI(-64, 128, 8, 128, [as["drop"], dropArrow[0]])
        ,"stats" => new GUI(Main.W, Main.H - 88, Main.W - 128, Main.H - 88, [as["stats"], Platform.createBitmap(120, 80, 0)])
        ,"trash" => new GUI(8, Main.H, 8, Main.H - 46, [as["trash"]])
        ,"deploy" => new GUI(Main.W - 48 - 8, -48, Main.W - 48 - 8, -2, [as["deploy"]])
        ,"timer" => new GUI(-32, 8, 8, 8, [as["timer1"]])
        ,"dropInfo" => new GUI(-120, 8, 8, 8, [as["box"].fluent >> new Box(new Point2DI(3, 3), new Point2DI(13, 13), 120, 32) >> new Grow(0, 0, 0, 10), Platform.createBitmap(120, 42, 0)])
        ,"trans_fight" => new GUI(Main.W, Main.H2 - 30, 0, Main.H2 - 30, [Text.banner(transBg >> new Copy(), "CULINARY WARFARE!")])
        ,"trans_fight2" => new GUI(Main.W, Main.H2 + 4, -80, Main.H2 + 4, [{
            var t = Platform.createBitmap(Main.W + textra * 2, 16, 0);
            t.fillRect(0, 4, Main.W + textra * 2, 8, Pal.reg[2]);
            var curx = 0;
            while (curx < Main.W + textra * 2) {
              Text.render(t, curx, 0, "COOK BURGERS TO VICTORY!");
              curx += textra;
            }
            t;
          }])
        ,"trans_win" => new GUI(Main.W, Main.H2 - 30, 0, Main.H2 - 30, [Text.banner(transBg >> new Copy(), "GLORIOUS VICTORY!")])
        ,"trans_win2" => new GUI(Main.W, Main.H2 + 4, -80, Main.H2 + 4, [{
            var t = Platform.createBitmap(Main.W + textra * 2, 16, 0);
            t.fillRect(0, 4, Main.W + textra * 2, 8, Pal.reg[2]);
            var curx = 0;
            while (curx < Main.W + textra * 2) {
              Text.render(t, curx, 0, "FLAWLESS COOKERY ACTION!");
              curx += textra;
            }
            t;
          }])
        ,"trans_loss" => new GUI(Main.W, Main.H2 - 30, 0, Main.H2 - 30, [Text.banner(transBg >> new Copy(), "TERRIBLE DEFEAT!")])
        ,"trans_loss2" => new GUI(Main.W, Main.H2 + 4, -80, Main.H2 + 4, [{
            var t = Platform.createBitmap(Main.W + textra * 2, 16, 0);
            t.fillRect(0, 4, Main.W + textra * 2, 8, Pal.reg[2]);
            var curx = 0;
            while (curx < Main.W + textra * 2) {
              Text.render(t, curx, 0, "BUTTER LUCK NEXT TIME!");
              curx += textra;
            }
            t;
          }])
        ,"hud_battle" => new GUI(136, Main.H, 136, Main.H - 24, [as["hud"], Platform.createBitmap(112, 24, 0)])
      ];
    panels["drop"].ignoreClicks = true;
    Text.render(panels["trash"].bs[0], 4, 30, "Destroy!");
    Text.render(panels["deploy"].bs[0], 8, 24, "Deploy!");
    panels["timer"].panelTooltip = "Stop minigame";
    panels["trash"].moy = -2;
    panels["trash"].panelTooltip = "Dispose of item/burger";
    panels["deploy"].moy = 2;
    panels["deploy"].panelTooltip = "Use burger in combat";
    panels["stats"].ignoreClicks = true;
    panels["dropInfo"].ignoreClicks = true;
    panels["trans_fight"].state = new Bitween(90);
    panels["trans_fight"].ignoreClicks = true;
    panels["trans_fight2"].state = new Bitween(130);
    panels["trans_fight2"].ignoreClicks = true;
    panels["trans_win"].state = new Bitween(90);
    panels["trans_win"].ignoreClicks = true;
    panels["trans_win2"].state = new Bitween(130);
    panels["trans_win2"].ignoreClicks = true;
    panels["trans_loss"].state = new Bitween(90);
    panels["trans_loss"].ignoreClicks = true;
    panels["trans_loss2"].state = new Bitween(130);
    panels["trans_loss2"].ignoreClicks = true;
    var hud = panels["hud_battle"];
    hud.tick = function () {
      if (Main.g.mode != TBS) return;
      hud.panelTooltip = (Main.g.boardY() == 0 ? "Switch to combat" : "Switch to kitchen");
      hud.px1 = hud.px2 = 104.maxI(panels["dropInfo"].px + panels["dropInfo"].w + 8);
      hud.py2 = (Main.g.boardY() - 24).maxI(0).floor();
      hud.bs[1].fill(0);
      hud.bs[1].blitAlphaRect(as["hudHealth"], 19, 8, 0, 0, 1 + 6 * Main.g.grid.rv.stats.hp, 7);
      hud.bs[1].blitAlphaRect(as["hudTimer"], 18, 0, 0, 0, (62 * Main.g.grid.playerTime).floor(), 5);
      Text.render(hud.bs[1], 82, 2, Main.g.enemyTurn() ? "ENEMY\nTURN" : "YOUR\nTURN");
    };
  }
  
  public static function clickAll(mx:Int, my:Int):Bool {
    for (p in panels) {
      if (p.click(mx, my)) return true;
    }
    return false;
  }
  
  public static function renderAll(to:Bitmap, mx:Int, my:Int):Bool {
    var omx = mx;
    var omy = my;
    var mo = false;
    for (p in panels) {
      if (p.render(to, mx, my)) {
        mo = true;
        mx = my = -1;
      }
    }
    if (tooltip != "") {
      if (tooltip != lastTooltip) {
        lastTooltip = tooltip;
        tooltipB.fill(Pal.reg[2]);
        tooltipW = Text.render(tooltipB, 1, 1, tooltip).x;
      }
      tooltipTX = Main.W - tooltipW - 2;
    } else {
      tooltipTX = Main.W;
    }
    tooltipX.target(tooltipTX, 19);
    to.blitAlpha(tooltipB, tooltipX.floor(), Main.H - tooltipB.height);
    if (mo) cursor = Hover;
    to.blitAlpha(cursors[cursor], omx, omy);
    cursor = Normal;
    tooltip = "";
    return mo;
  }
  
  public static function showTransition(id:String):Void {
    var cnt = 0;
    show('trans_${id}');
    show('trans_${id}2');
    panels['trans_${id}2'].box = 0;
    panels['trans_${id}'].tick = function () {
      cnt++;
      if (cnt == 300) {
        hide('trans_${id}');
      } else if (cnt == 400) {
        panels['trans_${id}2'].state.setTo(false, true);
        panels['trans_${id}'].tick = () -> {};
      }
    };
    panels['trans_${id}2'].tick = function () {
      if (panels['trans_${id}2'].state.valueF < .9) return;
      panels['trans_${id}2'].box -= 2;
      if (panels['trans_${id}2'].box < -textra && cnt < 180) panels['trans_${id}2'].box += textra;
    };
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
    Text.render(b, 25, 21 + 18, 'AP: ${s.ap}/${s.apMax}');
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
  public var box:Int = 0;
  public var bs:Array<Bitmap>;
  public var ignoreClicks:Bool = false;
  public var panelTooltip:String;
  
  public var px(get, never):Int;
  private inline function get_px():Int {
    return px1 + ((px2 - px1) * Timing.quadInOut.getF(state.valueF)).floor();
  }
  
  public var py(get, never):Int;
  private inline function get_py():Int {
    return py1 + ((py2 - py1) * Timing.quadInOut.getF(state.valueF)).floor();
  }
  
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
    if (mx.withinI(px, px + w - 1) && my.withinI(py, py + h - 1)) {
      action();
      return true;
    }
    return false;
  }
  
  public dynamic function tick():Void {}
  
  public function render(to:Bitmap, mx:Int, my:Int):Bool {
    tick();
    var mo:Bool = false;
    state.tick();
    if (state.isOff) return false;
    var px = this.px;
    var py = this.py;
    if (state.isOn && mx != -1 && my != -1 && mx.withinI(px, px + w - 1) && my.withinI(py, py + h - 1)) {
      px += mox;
      py += moy;
      mo = true;
    }
    for (b in bs) if (b != null) {
      to.blitAlpha(b, px + box, py);
    }
    if (!ignoreClicks && mo && panelTooltip != null) tooltip = panelTooltip;
    return !ignoreClicks && mo;
  }
}
