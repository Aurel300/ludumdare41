package lib;

import sk.thenet.bmp.manip.*;

class Board {
  static var as:Map<String, Bitmap>;
  
  public static function init(b:Bitmap):Void {
    var f = b.fluent;
    as = [
         "carrot" => f >> new Cut(0, 8, 232, 64)
        ,"tomato" => f >> new Cut(0, 72, 88, 80)
        ,"bun" => f >> new Cut(88, 72, 144, 80)
        ,"patty" => f >> new Cut(0, 152, 184, 72)
        ,"knife" => f >> new Cut(232, 16, 168, 48)
        ,"knife_ghost" => f >> new Cut(232, 64, 168, 48)
        ,"tenderiser" => f >> new Cut(232, 112, 168, 56)
      ];
  }
  
  public var task:BoardTask;
  public var obj:Bitmap;
  public var objX:Float = 0;
  public var objY:Float = 0;
  public var objW:Int;
  public var objTX:Float = 0;
  public var objTY:Float = 0;
  public var knife:Bitmap;
  public var knifeX:Float = Main.W + 10;
  public var knifeY:Float = 40;
  public var knifeTX:Float = Main.W + 10;
  public var knifeTY:Float = 40;
  public var knifeDip:Int = 0;
  public var bpieces:Array<Piece> = [];
  public var pieces:Array<Piece> = [];
  public var timer:Int;
  
  public function new() {
    //start(CutCarrot(null));
    start(Tenderise);
  }
  
  public function start(task:BoardTask) {
    bpieces = [];
    this.task = (switch (task) {
        case CutCarrot(_):
        CutCarrot([ for (i in 1...6) {
            55 + i * 38 + FM.prng.nextMod(18);
          } ]);
        case Tenderise:
        knifeTX = 160;
        knifeTY = 50;
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
        case _: task;
      });
    timer = 0;
  }
  
  public function render(to:Bitmap):Void {
    to.fill(Pal.reg[1]);
    var taskLen = 0;
    switch (task) {
      case None:
      knifeTX = Main.W + 10;
      knifeTY = 40;
      objTY = Main.H + 10;
      case CutCarrot(marks):
      obj = as["carrot"];
      if (timer == 0) objW = as["carrot"].width;
      objTX = 40;
      objTY = 80;
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
      taskLen = 640;
      case Tenderise:
      obj = null;
      objTX = 60;
      objTY = 120;
      knife = as["tenderiser"];
      taskLen = 640;
    }
    if (timer >= taskLen) {
      task = None;
      timer = 0;
    }
    for (p in bpieces) {
      to.blitAlphaRect(p.b, (objX + p.x).floor(), (objY + p.y).floor(), p.bx, p.by, p.bw, p.bh);
    }
    to.blitAlpha(knife, knifeX.floor(), knifeY.floor());
    if (obj != null) to.blitAlphaRect(obj, objX.floor(), objY.floor(), 0, 0, objW, obj.height);
    pieces = [ for (p in pieces) {
        if (p.y > Main.H) continue;
        to.blitAlphaRect(p.b, p.x.floor(), p.y.floor(), p.bx, p.by, p.bw, p.bh);
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.09;
        p;
      } ];
    objX.target(objTX, 19);
    objY.target(objTY, 19);
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
  
  public function click(mx, my) {
    switch (task) {
      case CutCarrot(marks):
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
             b: as["carrot"]
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
      knifeTX = 80 + FM.prng.nextMod(100);
      knifeTY = 50 + FM.prng.nextMod(30);
      knifeDip += 1;
      var ex = FM.prng.nextMod(6);
      var ey = FM.prng.nextMod(3);
      for (i in 0...ey + 1) {
        bpieces[ex + i * 6].y += 1;
      }
      case _:
    }
  }
}

enum BoardTask {
  None;
  CutCarrot(marks:Array<Int>);
  Tenderise;
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
