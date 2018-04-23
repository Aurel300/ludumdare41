package lib;

import sk.thenet.app.Keyboard.Key;
import sk.thenet.bmp.manip.*;

class Board {
  static var as:Map<String, Bitmap>;
  static var ingr:Map<Ingredient, Bitmap>;
  
  static inline var BASE_CARROT = 140;
  static inline var BASE_CUCUMBER = 240;
  static inline var BASE_TOMATO = 80;
  static inline var BASE_TENDERISE = 50;
  
  static inline var TASK_LENGTH = 640;
  
  static var timerFrames:Vector<Int> = {
      var ret = new Vector<Int>(TASK_LENGTH);
      var cf = 1;
      for (i in 0...TASK_LENGTH) {
        ret[i] = cf;
        if (i == 80 || i == 160 || i == 240 || i == 320
            || i == 360 || i == 400 || i == 440 || i == 480
            || i == 500 || i == 520 || i == 540 || i == 560 || i == 580 || i == 600 || i == 620 || i == 640)
          cf = 3 - cf;
      }
      ret;
    };
  
  public static inline function pattyState(t:Int):Int {
    if (t == 23 * 60) Sfx.play("burn");
    return (t < 3 * 60 ? 0 :
      (t < 13 * 60 ? 1 :
      (t < 23 * 60 ? 2 : 3)));
  }
  
  static function rankScore(score:Int, baseline:Int):UnitRank {
    return (score < .25 * baseline ? RankF :
      (score < .75 * baseline ? RankD :
      (score < 1.25 * baseline ? RankB :
      (score < 1.75 * baseline ? RankA : RankS))));
  }
  
  public static inline function rankPatty(ten:Int, f:Int, t:Int):BurgerLayer {
    var r = rankScore(ten, BASE_TENDERISE);
    var a = pattyState(f);
    var b = pattyState(t);
    var maxRank:UnitRank = RankS;
    var pattyName = "Crisp patty";
    var resPatty = (switch [a, b] {
        case [3, _] | [_, 3]: pattyName = "Burnt patty"; maxRank = RankD; 3;
        case [0, _] | [_, 0]: pattyName = "Raw patty"; maxRank = RankD; 0;
        case [1, _] | [_, 1]: pattyName = "Undercooked patty"; maxRank = RankA; 1;
        case _: 2;
      });
    if ((r:Int) < (maxRank:Int)) r = maxRank;
    GUI.showDropInfo(pattyName, r);
    return Scored(Patty(resPatty), r);
  }
  
  public static function rankScoreShow(l:BurgerLayer, ?score:Int = -1, ?baseline:Int = -1):BurgerLayer {
    var rank = score >= 0 ? rankScore(score, baseline) : null;
    GUI.showDropInfo(switch (l) {
        case Tomato: "Tomato slice";
        case Carrot: "Carrot slices";
        case Cucumber: "Cucumber slices";
        case Patty(cook): "Burger patty";
        case Lettuce: "Lettuce slice";
        case Cheese: "Cheese slice";
        case Sauce: "Special sauce";
        case Pepsalt: "Pepsalt";
        case _: "";
      }, rank);
    return rank != null ? Scored(l, rank) : l;
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
        ,Sauce => f >> new Cut(400 + i++ * 32, 8, 32, 34)
        ,Pepsalt => f >> new Cut(400 + i++ * 32, 8, 32, 34)
      ];
  }
  
  static var platePosX = [40, 184, 112];
  static var platePosY = [103, 103, 160];
  
  static var pattyPosX = [34, 174, 34, 174];
  static var pattyPosY = [50, 50, 134, 134];
  
  var inventory:Array<Ingredient> = [Carrot, Tomato, Patty, Cucumber, Lettuce, Cheese, Sauce, Pepsalt];
  var plots:Array<Plot>;
  var p3d:P3D;
  
  var task:BoardTask;
  var obj:Bitmap;
  var objX:Float;
  var objY:Float;
  var objW:Int;
  var objTX:Float;
  var objTY:Float;
  var knife:Bitmap;
  var knifeX:Float;
  var knifeY:Float;
  var knifeTX:Float;
  var knifeTY:Float;
  var knifeDip:Int;
  var bpieces:Array<Piece>;
  var pieces:List<Piece>;
  var timer:Int;
  var space:Int;
  var spaceX:Float;
  var spaceTX:Float;
  var inventoryHover:Int;
  var slotHover:Int;
  var slotSelect:Int;
  var pattyHover:Int;
  var grill:Array<PattyGrill>;
  var slots:Array<Burger>;
  var dropLayer:P3DBuild;
  var score:Int;
  
  var sizzle:Crossfade;
  
  public function new() {
    plots = [ for (i in 0...3) new Plot(106, 126) ];
    p3d = new P3D();
    p3d.zoom = 3;
    p3d.camAngle = 3;
    p3d.offY = 90;
    
    sizzle = new Crossfade("sizzle");
    
    GUI.panels["deploy"].action = function () {
      switch (task) {
        case Stats(_):
        if (Main.g.grid.deploy(slots[slotSelect])) {
          slots[slotSelect] = new Burger();
          Main.g.boardBT.setTo(false);
        }
        case _:
      }
      deinit();
    };
    GUI.panels["trash"].action = function () {
      switch (task) {
        case Stats(_): slots[slotSelect] = new Burger();
        case _:
      }
      deinit();
    };
    GUI.panels["timer"].action = function () {
      timer = TASK_LENGTH - 1;
    }; 
    GUI.panels["hud_battle"].action = function () {
      switch (task) {
        case None | Stats(_):
        Main.g.boardBT.toggle();
        deinit();
        case _:
      }
    };
    
    reset();
  }
  
  public function reset():Void {
    task = None;
    obj = null;
    objX = 0;
    objY = Main.H;
    objW = 0;
    objTX = 0;
    objTY = Main.H;
    knife =  null;
    knifeX = Main.W + 10;
    knifeY = Main.H;
    knifeTX = Main.W + 10;
    knifeTY = Main.H;
    knifeDip = 0;
    bpieces = new Array<Piece>();
    pieces = new List<Piece>();
    timer = 0;
    space = 0;
    spaceX = 0;
    spaceTX = 0;
    inventoryHover = -1;
    slotHover = -1;
    slotSelect = -1;
    pattyHover = -1;
    grill = [ for (i in 0...4) None ];
    slots = [ for (i in 0...3) new Burger() ];
    dropLayer = null;
    score = 0;
  }
  
  public function initTask(task:BoardTask):BoardTask {
    timer = 0;
    return (switch (task) {
        case CutCarrot(_): Sfx.play("knife");
        GUI.show("timer");
        score = 0;
        obj = as["carrot"];
        objW = obj.width;
        objTX = 40;
        objTY = 80;
        CutCarrot([ for (i in 1...6) {
            55 + i * 38 + FM.prng.nextMod(18);
          } ]);
        case CutCucumber(_): Sfx.play("knife");
        GUI.show("timer");
        score = 0;
        obj = as["cucumber"];
        objW = obj.width;
        objTX = 40;
        objTY = 80;
        CutCucumber([ for (i in 1...8) {
            65 + i * 25 + FM.prng.nextMod(18);
          } ]);
        case CutTomato:
        GUI.show("timer");
        score = 0;
        obj = as["tomato"];
        objW = obj.width;
        objTX = 100 + 19 - 1;
        objTY = 60 + 21 - 1;
        knifeTX = 100;
        knifeTY = 60;
        knife = GUI.as["turn"];
        task;
        case Tenderise:
        GUI.show("timer");
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
        task;
        case Stats(b):
        GUI.showStats(b.stats);
        if (b.layers.length > 1) GUI.show("trash");
        if (b.layers.length > 1) GUI.show("deploy");
        task;
        case Drop(l):
        dropLayer = slots[slotSelect].addLayer(l);
        dropLayer.z += 10;
        GUI.panels["drop"].bs[1] = GUI.dropArrow[0];
        GUI.show("trash");
        GUI.show("drop");
        task;
        case Put(l):
        if (l == Pepsalt) Sfx.play("pepsalt");
        if (l == Sauce) Sfx.play("sauce");
        dropLayer = slots[slotSelect].addLayer(l);
        deinit(); initTask(None);
        case SelectBurger(_) | SelectGrill(_):
        GUI.show("trash");
        task;
        case _: task;
      });
  }
  
  public function start(task:BoardTask) {
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
    GUI.hide("dropInfo");
    GUI.hide("trash");
    switch (task) {
      case CutCarrot(_) | CutCucumber(_) | CutTomato | Tenderise:
      GUI.hide("timer");
      objTX = 0;
      objTY = Main.H + 10;
      knifeX = Main.W + 10;
      knifeY = Main.H + 10;
      knifeTX = Main.W + 10;
      knifeTY = Main.H + 10;
      case Stats(_):
      GUI.hide("stats");
      GUI.hide("deploy");
      case Drop(_):
      var qual = Burger.angleQuality(timer);
      var qq = 0;
      if (qual == 0) qq = 15;
      else if (qual == 1) qq = 7;
      if (qq != 0) stars(platePosX[slotSelect] + 53 - Main.W, platePosY[slotSelect] + 40, qq);
      slots[slotSelect].restat();
      dropLayer.z -= 10;
      GUI.hide("drop");
      case Put(_):
      slots[slotSelect].restat();
      case _:
    }
    task = None;
    timer = 0;
  }
  
  public function render(to:Bitmap, y:Int, mx:Int, my:Int):Void {
    var doSizzle = false;
    for (i in 0...4) if (grill[i] != None) doSizzle = true;
    sizzle.tick(doSizzle, (1 - y / Main.H) * .7 + .3, -(640 - spaceX) / 640);
    
    // render logic
    switch (task) {
      case None:
      case CutCarrot(marks) | CutCucumber(marks):
      knifeTY = 40;
      if (timer == 5 || timer == 325) Sfx.play("cut-start");
      if (timer < 320) {
        knife = as["knife_ghost"];
        knifeTX = Main.W - timer;
        if (marks.indexOf(timer) != -1) {
          Sfx.play("cut1");
          knifeDip += 1;
        }
      } else {
        knife = as["knife"];
        knifeTX = Main.W - (timer - 320);
      }
      case CutTomato:
      var tgtX = (Main.W2 + Trig.cosAngle[score % Trig.densityAngle] * 50).floor();
      var tgtY = (Main.H2 - Trig.sinAngle[score % Trig.densityAngle] * 50).floor();
      if (mx.withinI(tgtX - 5, tgtX + 5) && my.withinI(tgtY - 5, tgtY + 5)) {
        objX += FM.prng.nextFloat(4) - 2;
        objY += FM.prng.nextFloat(4) - 2;
        score++;
      }
      case Tenderise:
      knifeTY = 50;
      case Drop(_):
      timer %= Trig.densityAngle;
      var ls = slots[slotSelect].layerAngles.length;
      slots[slotSelect].layerAngles[ls - 1] = timer;
      GUI.panels["drop"].bs[1] = GUI.dropArrow[timer];
      case _:
    }
    GUI.panels["timer"].bs[0] = GUI.as["timer" + timerFrames[timer % TASK_LENGTH]];
    
    if (y < Main.H) {
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
            GUI.cursor = Hover;
            GUI.tooltip = (switch (inventory[i]) {
                case Carrot: "Cut carrot";
                case Tomato: "Cut tomato";
                case Patty: "Prepare patty";
                case Cucumber: "Cut cucumber";
                case Lettuce: "Place lettuce";
                case Cheese: "Place cheese";
                case Sauce: "Add special sauce";
                case Pepsalt: "Add pepsalt";
              });
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
          GUI.cursor = Hover;
          GUI.tooltip = task == None ? "Select burger" : "Add to this burger";
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
      if (task == CutTomato) {
        to.blitAlpha(GUI.turnBit[score % Trig.densityAngle], (knifeX - space2X).floor(), knifeY.floor() + y);
      }
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
          GUI.cursor = Hover;
          GUI.tooltip = (switch [task, grill[i]] {
              case [None, None]: "Empty grill";
              case [None, First(_, _)]: "Flip patty";
              case [None, Second(_, _, _)]: "Take out patty";
              case [SelectGrill(_), None]: "Place patty here";
              case [SelectGrill(_), _]: "No room here";
              case _: "";
            });
          cury -= 2;
        }
        switch (grill[i]) {
          case First(ten, t):
          var s = pattyState(t);
          to.blitAlpha(as["patty_grill" + s], (pattyPosX[i] - space3X).floor(), cury);
          if (s == 2 && (t >> 4) % 2 == 1) to.blitAlpha(GUI.as["timerEx"], (pattyPosX[i] - space3X).floor(), cury);
          case Second(ten, f, t):
          var s = pattyState(t);
          to.blitAlpha(as["patty_grill_flip" + s], (pattyPosX[i] - space3X).floor(), cury);
          if (s == 2 && (t >> 4) % 2 == 1) to.blitAlpha(GUI.as["timerEx"], (pattyPosX[i] - space3X).floor(), cury);
          case _:
        }
      }
      
      if (mx < 10 && space > 0) {
        GUI.cursor = Left;
        GUI.tooltip = "Move left";
      }
      if (mx >= Main.W - 10 && space < 2) {
        GUI.cursor = Right;
        GUI.tooltip = "Move right";
      }
    }
    
    // logic
    switch (task) {
      case Starting(t, f):
      if (timer >= f) {
        task = initTask(t);
        timer = 0;
      }
      case CutCarrot(_): if (timer >= TASK_LENGTH) { deinit(); start(SelectBurger(Drop(rankScoreShow(Carrot, score, BASE_CARROT)))); }
      case CutCucumber(_): if (timer >= TASK_LENGTH) { deinit(); start(SelectBurger(Drop(rankScoreShow(Cucumber, score, BASE_CUCUMBER)))); }
      case CutTomato: if (timer >= TASK_LENGTH) { deinit(); start(SelectBurger(Drop(rankScoreShow(Tomato, score, BASE_TOMATO)))); }
      case Tenderise: if (timer >= TASK_LENGTH) { deinit(); GUI.showDropInfo("Raw patty", rankScore(score, BASE_TENDERISE)); start(SelectGrill(score)); }
      case _:
    }
    
    for (i in 0...4) grill[i] = (switch (grill[i]) {
        case First(ten, t): First(ten, t + 1);
        case Second(ten, f, t): Second(ten, f, t + 1);
        case None: None;
      });
    
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
  
  function stars(x:Float, y:Float, n:Int):Void {
    for (i in 0...n + FM.prng.nextMod(5)) {
      pieces.push({
           b: GUI.stars[FM.prng.nextMod(6)]
          ,bx: 0
          ,by: 0
          ,bw: 12
          ,bh: 12
          ,x: x - 2 + FM.prng.nextFloat(4)
          ,y: y - 2 + FM.prng.nextFloat(4)
          ,vx: -1 + FM.prng.nextFloat(2)
          ,vy: -0.5 - FM.prng.nextFloat(2.1)
        });
    }
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
      deinit(); start(switch (inventory[inventoryHover]) {
          case Carrot: CutCarrot(null);
          case Cucumber: CutCucumber(null);
          case Tomato: CutTomato;
          case Patty: Tenderise;
          case Lettuce: SelectBurger(Drop(rankScoreShow(Lettuce)));
          case Cheese: SelectBurger(Drop(rankScoreShow(Cheese)));
          case Sauce: SelectBurger(Put(rankScoreShow(Sauce)));
          case Pepsalt: SelectBurger(Put(rankScoreShow(Pepsalt)));
        });
      inventoryHover = -1;
      return true;
    }
    if (pattyHover != -1) {
      switch (task) {
        case SelectGrill(ten):
        switch (grill[pattyHover]) {
          case None: Sfx.play("sizzle-start");
          grill[pattyHover] = First(ten, 0);
          deinit();
          case _: // TODO: let player know
        }
        case None:
        switch (grill[pattyHover]) {
          case First(ten, t): Sfx.play("flip1"); grill[pattyHover] = Second(ten, t, 0);
          case Second(ten, f, t): Sfx.play("flip2"); grill[pattyHover] = None;
          deinit(); start(SelectBurger(Drop(rankPatty(ten, f, t))));
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
        Sfx.play("cut1");
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
        score += 50 - bestDist;
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
        if (bestFit != -1 && bestDist < 50) {
          stars(objX + objW, objY + 30, (50 - bestDist) >> 2);
          marks.splice(bestFit, 1);
        }
      }
      case Tenderise:
      score++;
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
      case Stats(_) | None:
      if (mx < 10 && space > 0) {
        space--;
        deinit();
      }
      if (mx >= Main.W - 10 && space < 2) {
        space++;
        deinit();
      }
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
        case [Space, Drop(_)]: deinit(); true;
        case [Space, _]: true; // TODO: warn about task
        case _: false;
      });
  }
}

enum BoardTask {
  None;
  CutCarrot(marks:Array<Int>);
  CutCucumber(marks:Array<Int>);
  CutTomato;
  Tenderise;
  
  Starting(t:BoardTask, f:Int);
  
  Stats(b:Burger);
  SelectBurger(t:BoardTask);
  SelectGrill(p:Int);
  Drop(i:BurgerLayer);
  Put(i:BurgerLayer);
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
