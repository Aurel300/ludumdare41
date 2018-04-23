package lib;

import sk.thenet.app.Keyboard.Key;
import sk.thenet.bmp.manip.*;

class Board {
  static var as:Map<String, Bitmap>;
  static var ingr:Map<Ingredient, Bitmap>;
  
  public static inline function pattyState(t:Int):Int {
    return (t < 3 * 60 ? 0 :
      (t < 13 * 60 ? 1 :
      (t < 23 * 60 ? 2 : 3)));
  }
  
  public static inline function combinedPattyState(ten:Int, f:Int, t:Int):BurgerLayer {
    var a = pattyState(f);
    var b = pattyState(t);
    return Patty(a == 3 || b == 3 ? 3
      : (a == 0 || b == 0 ? 0
      : (a == 1 || b == 1 ? 1
      : 2)));
  }
  
  public static function init(b:Bitmap):Void {
    var f = b.fluent;
    as = [
         "carrot" => f >> new Cut(0, 8, 232, 64)
        ,"tomato" => f >> new Cut(0, 72, 88, 80)
        ,"cucumber" => f >> new Cut(400, 48, 224, 64)
        ,"bun" => f >> new Cut(88, 72, 144, 80)
        ,"patty" => f >> new Cut(0, 152, 184, 72)
        ,"knife" => f >> new Cut(232, 16, 168, 48)
        ,"knife_ghost" => f >> new Cut(232, 64, 168, 48)
        ,"tenderiser" => f >> new Cut(232, 112, 168, 56)
        ,"interiour" => f >> new Cut(0, 232, 320 * 3, 240)
        ,"plate" => f >> new Cut(184, 168, 104, 56)
        ,"plate_shadow" => f >> new Cut(184 + 104, 168, 104, 56)
        ,"patty_grill0" => f >> new Cut(400, 112, 120, 56)
      ];
    var pattyMap = [
         0  => [0, 0,  0,  0 ]
        ,17 => [0, 27, 27, 21]
        ,18 => [0, 17, 17, 21]
        ,19 => [0, 17, 17, 22]
        ,26 => [0, 26, 7,  7 ]
        ,27 => [0, 26, 26, 20]
      ];
    for (i in 1...4) {
      as["patty_grill" + i] = f >> new Cut(400, 112, 120, 56);
      var vec = as["patty_grill" + i].getVector();
      for (vi in 0...vec.length) {
        var q = Colour.quantise(vec[vi], Pal.reg);
        if (!pattyMap.exists(q)) trace(vec[vi], q);
        vec[vi] = Pal.reg[pattyMap[q][i]];
      }
      as["patty_grill" + i].setVector(vec);
    }
    for (i in 0...4) as["patty_grill_flip" + i] = as["patty_grill" + i].fluent >> new Flip();
    var i = 0;
    ingr = [
         Carrot => f >> new Cut(400 + i++ * 32, 8, 32, 34)
        ,Tomato => f >> new Cut(400 + i++ * 32, 8, 32, 34)
        ,Patty => f >> new Cut(400 + i++ * 32, 8, 32, 34)
        ,Cucumber => f >> new Cut(400 + i++ * 32, 8, 32, 34)
        ,Lettuce => f >> new Cut(400 + i++ * 32, 8, 32, 34)
        ,Cheese => f >> new Cut(400 + i++ * 32, 8, 32, 34)
      ];
  }
  
  static var platePosX = [40, 184, 112];
  static var platePosY = [103, 103, 160];
  
  static var pattyPosX = [34, 174, 34, 174];
  static var pattyPosY = [50, 50, 134, 134];
  
  public var task:BoardTask = None;
  public var obj:Bitmap = null;
  public var objX:Float = 0;
  public var objY:Float = Main.H;
  public var objW:Int = 0;
  public var objTX:Float = 0;
  public var objTY:Float = Main.H;
  public var knife:Bitmap =  null;
  public var knifeX:Float = Main.W + 10;
  public var knifeY:Float = Main.H;
  public var knifeTX:Float = Main.W + 10;
  public var knifeTY:Float = Main.H;
  public var knifeDip:Int = 0;
  public var bpieces = new Array<Piece>();
  public var pieces = new List<Piece>();
  public var timer:Int = 0;
  public var space:Int = 0;
  public var spaceX:Float = 0;
  public var spaceTX:Float = 0;
  public var inventory:Array<Ingredient> = [Carrot, Tomato, Patty, Cucumber, Lettuce, Cheese, null, null];
  public var inventoryHover:Int = -1;
  public var slotHover:Int = -1;
  public var slotSelect:Int = -1;
  public var pattyHover:Int = -1;
  public var grill:Array<PattyGrill>;
  var plots:Array<Plot>;
  var slots:Array<Burger>;
  var p3d:P3D;
  var dropLayer:P3DBuild;
  var score:Int = 0;
  
  public function new() {
    plots = [ for (i in 0...3) new Plot(106, 126) ];
    slots = [ for (i in 0...3) new Burger() ];
    grill = [ for (i in 0...4) None ];
    
    p3d = new P3D();
    p3d.zoom = 3;
    p3d.camAngle = 3;
    p3d.offY = 90;
    
    GUI.panels["trash"].action = function () {
      slots[slotSelect] = new Burger();
      deinit();
    };
  }
  
  public function initTask(task:BoardTask):BoardTask {
    timer = 0;
    return (switch (task) {
        case CutCarrot(_):
        score = 0;
        obj = as["carrot"];
        objW = as["carrot"].width;
        objTX = 40;
        objTY = 80;
        CutCarrot([ for (i in 1...6) {
            55 + i * 38 + FM.prng.nextMod(18);
          } ]);
        case CutCucumber(_):
        score = 0;
        obj = as["cucumber"];
        objW = as["cucumber"].width;
        objTX = 40;
        objTY = 80;
        CutCucumber([ for (i in 1...8) {
            65 + i * 25 + FM.prng.nextMod(18);
          } ]);
        case Tenderise:
        score = 0;
        obj = null;
        objTX = 60;
        objTY = 120;
        objW = 0;
        knifeTX = 160;
        knife = as["tenderiser"];
        bpieces = [ for (y in 0...4) for (x in 0...6) {
             b: as["patty"]
            ,bx: x * 32
            ,by: y * 18
            ,bw: 32
            ,bh: 18
            ,x: x * 32
            ,y: y * 18
            ,vx: 0
            ,vy: 0
          } ];
        Tenderise;
        case Stats(b):
        GUI.showStats(b.stats);
        if (b.layers.length > 1) GUI.show("trash");
        if (b.layers.length > 1) GUI.show("deploy");
        Stats(b);
        case Drop(l):
        dropLayer = slots[slotSelect].addLayer(l);
        dropLayer.z += 10;
        GUI.panels["drop"].bs[1] = GUI.dropArrow[0];
        GUI.show("drop");
        Drop(l);
        case _: task;
      });
  }
  
  public function start(task:BoardTask) {
    deinit();
    bpieces = null;
    space = (switch (task) {
        case SelectBurger(_): 0;
        case SelectGrill(_): 2;
        case _: 1;
      });
    this.task = Starting(task, 20);
    timer = 0;
  }
  
  function deinit():Void {
    switch (task) {
      case CutCarrot(_) | CutCucumber(_) | Tenderise:
      objTX = 0;
      objTY = Main.H + 10;
      knifeX = Main.W + 10;
      knifeY = Main.H + 10;
      knifeTX = Main.W + 10;
      knifeTY = Main.H + 10;
      case Stats(_):
      GUI.hide("stats");
      GUI.hide("trash");
      GUI.hide("deploy");
      case Drop(_):
      GUI.hide("drop");
      case _:
    }
    task = None;
    timer = 0;
  }
  
  public function render(to:Bitmap, y:Int, mx:Int, my:Int):Void {
    if (y >= Main.H) return;
    
    // render logic
    switch (task) {
      case None:
      case CutCarrot(marks) | CutCucumber(marks):
      knifeTY = 40;
      if (timer == 0 || timer == 320) Sfx.play("cut-start");
      if (timer < 320) {
        knife = as["knife_ghost"];
        knifeTX = Main.W - timer;
        if (marks.indexOf(timer) != -1) {
          Sfx.play("cut");
          knifeDip += 1;
        }
      } else {
        knife = as["knife"];
        knifeTX = Main.W - (timer - 320);
      }
      case Tenderise:
      knifeTY = 50;
      case Drop(_):
      timer %= Trig.densityAngle;
      dropLayer.angle = timer;
      GUI.panels["drop"].bs[1] = GUI.dropArrow[timer];
      case _:
    }
    
    // render
    to.blitAlpha(as["interiour"], -spaceX.floor(), y);
    
    // prep
    var doSelect = (switch (task) {
        case None: y == 0 && space == 0 && spaceX < 1;
        case _: false;
      });
    inventoryHover = -1;
    var curx = 22 - spaceX.floor();
    for (i in 0...inventory.length) {
      if (inventory[i] != null) {
        if (doSelect
            && mx.withinI(curx, curx + 31)
            && my.withinI(36, 36 + 31)) {
          to.blitAlphaRect(ingr[inventory[i]], curx, 36 + y, 0, 2, 32, 32);
          inventoryHover = i;
        } else {
          to.blitAlphaRect(ingr[inventory[i]], curx, 36 + y, 0, 0, 32, 32);
        }
      }
      curx += 35;
    }
    
    doSelect = (switch (task) {
        case None | SelectBurger(_): y == 0 && space == 0 && spaceX < 1;
        case _: false;
      });
    slotHover = -1;
    for (i in 0...plots.length) {
      plots[i].prerender(true);
      to.blitAlpha(as["plate_shadow"], platePosX[i] - spaceX.floor(), platePosY[i] + 2 + y);
      if (doSelect
          && mx.withinI(platePosX[i], platePosX[i] + 103)
          && my.withinI(platePosY[i], platePosY[i] + 54)) {
        slotHover = i;
      }
      to.blitAlpha(as["plate"], platePosX[i] - spaceX.floor(), platePosY[i] + y - (slotHover == i ? 2 : 0));
      if (slots[i] != null) p3d.renderUnit(plots[i], slots[i]);
      p3d.camX = Grid.TILE_HALF;
      p3d.camY = Grid.TILE_HALF;
      plots[i].renderAlpha(to, platePosX[i] - spaceX.floor(), platePosY[i] - 75 + y - (slotHover == i ? 2 : 0));
    }
    
    // cutting board
    var space2X = -320 + spaceX;
    if (bpieces != null) for (p in bpieces) {
      to.blitAlphaRect(p.b, (objX + p.x - space2X).floor(), (objY + p.y).floor() + y, p.bx, p.by, p.bw, p.bh);
    }
    if (knife != null) to.blitAlpha(knife, (knifeX - space2X).floor(), knifeY.floor() + y);
    if (obj != null) to.blitAlphaRect(obj, (objX - space2X).floor(), objY.floor() + y, 0, 0, objW, obj.height);
    for (p in pieces) {
      if (p.y > Main.H) pieces.remove(p);
      to.blitAlphaRect(p.b, (p.x - space2X).floor(), p.y.floor() + y, p.bx, p.by, p.bw, p.bh);
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.09;
    }
    
    // grill
    doSelect = (switch (task) {
        case None | SelectGrill(_): y == 0 && space == 2 && spaceX > 639;
        case _: false;
      });
    pattyHover = -1;
    var space3X = -640 + spaceX;
    for (i in 0...4) {
      var cury = pattyPosY[i] + y;
      if (doSelect
          && mx.withinI(pattyPosX[i], pattyPosX[i] + 119)
          && my.withinI(pattyPosY[i], pattyPosY[i] + 55)) {
        pattyHover = i;
        cury -= 2;
      }
      grill[i] = (switch (grill[i]) {
          case First(ten, t):
          var s = pattyState(t);
          to.blitAlpha(as["patty_grill" + s], (pattyPosX[i] - space3X).floor(), cury);
          if (s == 2 && (t >> 4) % 2 == 1) to.blitAlpha(GUI.as["timerEx"], (pattyPosX[i] - space3X).floor(), cury);
          First(ten, t + 1);
          case Second(ten, f, t):
          var s = pattyState(t);
          to.blitAlpha(as["patty_grill_flip" + s], (pattyPosX[i] - space3X).floor(), cury);
          if (s == 2 && (t >> 4) % 2 == 1) to.blitAlpha(GUI.as["timerEx"], (pattyPosX[i] - space3X).floor(), cury);
          Second(ten, f, t + 1);
          case None: None;
        });
    }
    
    // logic
    switch (task) {
      case Starting(t, f):
      if (timer >= f) {
        task = initTask(t);
        timer = 0;
      }
      case CutCarrot(_): if (timer >= 640) start(SelectBurger(Drop(Carrot)));
      case CutCucumber(_): if (timer >= 640) start(SelectBurger(Drop(Cucumber)));
      case Tenderise: if (timer >= 10/*640*/) start(SelectGrill(score));
      case _:
    }
    
    // tween
    objX.target(objTX, 19);
    objY.target(objTY, 19);
    spaceTX = space * Main.W;
    spaceX.targetMin(spaceTX, 9, .5);
    if (task == None) {
      knifeX.target(knifeTX, 29);
      knifeY.target((knifeDip > 0 ? 200 : 0) + knifeTY, 29);
    } else {
      knifeX.target(knifeTX, 7);
      knifeY.target((knifeDip > 0 ? 200 : 0) + knifeTY, 7);
    }
    if (knifeDip > 0) knifeDip--;
    timer++;
  }
  
  public function click(mx, my):Bool {
    if (slotHover != -1) {
      switch (task) {
        case SelectBurger(t):
        slotSelect = slotHover;
        task = initTask(t);
        case None:
        slotSelect = slotHover;
        task = initTask(Stats(slots[slotSelect]));
        case _:
      }
      slotHover = -1;
      return true;
    }
    if (inventoryHover != -1) {
      start(switch (inventory[inventoryHover]) {
          case Carrot: CutCarrot(null);
          case Cucumber: CutCucumber(null);
          case Tomato: CutCarrot(null);
          case Patty: Tenderise;
          case Lettuce: SelectBurger(Drop(Lettuce));
          case Cheese: SelectBurger(Drop(Cheese));
        });
      inventoryHover = -1;
      return true;
    }
    if (pattyHover != -1) {
      switch (task) {
        case SelectGrill(ten):
        switch (grill[pattyHover]) {
          case None: grill[pattyHover] = First(ten, 0);
          deinit();
          case _: // TODO: let player know
        }
        case None:
        switch (grill[pattyHover]) {
          case First(ten, t): grill[pattyHover] = Second(ten, t, 0);
          case Second(ten, f, t): grill[pattyHover] = None;
          start(SelectBurger(Drop(combinedPattyState(ten, f, t))));
          case _:
        }
        case _:
      }
      pattyHover = -1;
      return true;
    }
    switch (task) {
      case CutCarrot(marks) | CutCucumber(marks):
      if (timer.withinI(320, 640)) {
        Sfx.play("cut");
        knifeDip += 2;
        var prevW = objW;
        objW = (knifeX + 20 - objX).floor();
        var bestDist = 500;
        var bestFit = -1;
        for (i in 0...marks.length) {
          var dist = ((timer - 320) - marks[i]).absI();
          if (dist < bestDist) {
            bestDist = dist;
            bestFit = i;
          }
        }
        if (bestFit != -1 && bestDist < 50) {
          marks.splice(bestFit, 1);
        }
        pieces.push({
             b: obj
            ,bx: objW
            ,by: 0
            ,bw: prevW - objW
            ,bh: obj.height
            ,x: objX + objW
            ,y: objY
            ,vx: .3 + Math.random() * 1.4
            ,vy: -1.3 - Math.random() * .9
          });
      }
      case Tenderise:
      score++;
      Sfx.play("cut");
      knifeTX = 80 + FM.prng.nextMod(100);
      knifeTY = 50 + FM.prng.nextMod(30);
      knifeDip += 1;
      var ex = FM.prng.nextMod(6);
      var ey = FM.prng.nextMod(3);
      for (i in 0...ey + 1) {
        bpieces[ex + i * 6].y += 1;
      }
      case Stats(_): deinit();
      case Drop(_): deinit();
      dropLayer.z -= 10;
      case _:
    }
    return true;
  }
  
  public function keyUp(k:Key):Bool {
    return (switch [k, task] {
        case [KeyA | KeyD, None | Stats(_)]: deinit();
        space = (space + (1).negposI(k == KeyA, k == KeyD)).clampI(0, 2); true;
        case [Space, Stats(_)]: deinit(); true;
        case [Space, None]: false;
        case [Space, _]: true; // TODO: warn about task
        case _: false;
      });
  }
}

enum BoardTask {
  None;
  CutCarrot(marks:Array<Int>);
  CutCucumber(marks:Array<Int>);
  Tenderise;
  
  Starting(t:BoardTask, f:Int);
  
  Stats(b:Burger);
  SelectBurger(t:BoardTask);
  SelectGrill(p:Int);
  Drop(i:BurgerLayer);
}

typedef Piece = {
     b:Bitmap
    ,bx:Int
    ,by:Int
    ,bw:Int
    ,bh:Int
    ,x:Float
    ,y:Float
    ,vx:Float
    ,vy:Float
  };

enum PattyGrill {
  None;
  First(ten:Int, t:Int);
  Second(ten:Int, f:Int, t:Int);
}
