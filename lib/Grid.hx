package lib;

class Grid {
  public static inline var TURN_TIME:Int = 2 * 60;
  
  public static inline var TILE_DIM:Int = 32;
  public static inline var TILE_HALF:Int = 16;
  public static inline var TILE_MARGIN:Int = 2;
  public static var tileData:Vector<Int> = Vector.fromArrayCopy([-1]);
  public static var tileDataSelect:Vector<Int> = Vector.fromArrayCopy([-3]);
  public static var tileDataHover:Vector<Int> = Vector.fromArrayCopy([-5]);
  public static var tileDataMove:Vector<Int> = Vector.fromArrayCopy([11]);
  public static var tileDataAttack:Vector<Int> = Vector.fromArrayCopy([8]);
  
  public var x:Int = 0;
  public var y:Int = 0;
  public var w:Int;
  public var h:Int;
  
  public var units:Vector<Unit>;
  public var renTiles:Vector<P3DPart>;
  
  public var state:GridState = Turn(true, TURN_TIME);
  public var turn:TurnState = Idle;
  
  var renEnts:Vector<GridTile>;
  
  public function new(w:Int, h:Int) {
    this.w = w;
    this.h = h;
    units = new Vector(w * h);
    renEnts = new Vector(w * h);
    renTiles = new Vector(w * h);
    var vi = 0;
    for (y in 0...h) for (x in 0...w) {
      renEnts[vi] = new GridTile(this, x, y);
      renTiles[vi] = renEnts[vi].part;
      vi++;
    }
    
    var b = new Burger();
    b.player = true;
    b.grid = this;
    b.gridX = 2;
    b.gridY = 2;
    b.addLayer(Tomato);
    b.addLayer(Carrot);
    b.addLayer(Patty(1));
    b.addLayer(Cheese);
    b.addLayer(Cucumber);
    b.addLayer(Lettuce);
    b.addLayer(BunTop);
    units[2 + 2 * 5] = b;
    
    b = new Burger();
    b.player = false;
    b.grid = this;
    b.gridX = 3;
    b.gridY = 3;
    b.addLayer(Lettuce);
    b.addLayer(BunTop);
    units[3 + 3 * 5] = b;
  }
  
  inline function c2i(x:Int, y:Int):Int return x + y * w;
  
  function clearUnits(player:Bool):Void {
    for (vi in 0...units.length) {
      if (units[vi] == null) continue;
      if (units[vi].player != player) continue;
      units[vi].aiMoved = false;
      units[vi].stats.mp = units[vi].stats.mpMax;
    }
  }
  
  function ai(u:Unit, allies:Array<Unit>, enemies:Array<Unit>):AIOutcome {
    var space = bfs(u);
    if (enemies.length == 0 || space.length == 0) return space[0];
    var hpf = u.stats.hp / u.stats.hpMax;
    for (s in space) {
      var damage = 0.0;
      if (s.attack) {
        var tgt = units[s.ati];
        damage += u.stats.ap;
        if (u.stats.ap < tgt.stats.hp) {
          damage -= tgt.stats.ap * .3;
        }
      }
      var closest = null;
      var closestDist = 0;
      for (e in enemies) {
        var dist = (e.gridX - u.gridX).absI() + (e.gridY - u.gridY).absI();
        if (closest == null || dist < closestDist) {
          closest = e;
          closestDist = dist;
        }
      }
      var proxMod = 1 / (hpf * u.stats.ap * closestDist);
      closest = null;
      closestDist = 0;
      for (e in allies) {
        var dist = (e.gridX - u.gridX).absI() + (e.gridY - u.gridY).absI();
        if (closest == null || dist < closestDist) {
          closest = e;
          closestDist = dist;
        }
      }
      var distMod = (1 - hpf) * closestDist;
      s.score = damage + proxMod + distMod;
    }
    space.sort((a, b) -> a.score < b.score ? 1 : -1);
    var i = 0;
    while (i < space.length - 1 && FM.prng.nextMod(3) == 0) i++;
    u.aiMoved = true;
    return space[i];
  }
  
  public function update():Void {
    state = (switch [state, turn] {
        case [_, WaitFor(u)]: turn = (u.anim == None ? initTurn(Idle) : turn); state;
        case [Turn(false, _), _]:
        var them = [];
        var us = [ for (u in units) {
            if (u == null) continue; 
            if (u.player) { them.push(u); continue; }
            if (u.aiMoved) continue;
            u;
          } ];
        if (us.length == 0) {
          initTurn(Idle);
          clearUnits(true);
          Turn(true, TURN_TIME);
        } else {
          var tu = FM.prng.nextElement(us);
          us.remove(tu);
          act(tu, ai(tu, us, them).ati);
          turn = WaitFor(tu);
          Turn(false, 1);
        }
        case [Turn(p, t), _]:
        if (t > 0) Turn(p, t - 1);
        else {
          initTurn(Idle);
          clearUnits(!p);
          Turn(!p, TURN_TIME);
        }
        case _: state;
      });
    var selVi = (switch [state, turn] {
        case [_, WaitFor(u)]: turn = (u.anim == None ? Idle : turn); -1;
        case [Turn(true, t), Inspect(s) | Select(s)]: c2i(s.gridX, s.gridY);
        case _: GUI.hide("stats"); -1;
      });
    var vi = 0;
    for (y in 0...h) for (x in 0...w) {
      renTiles[vi].data = renEnts[vi].mouse
        ? tileDataHover : (vi == selVi
          ? tileDataSelect : (renEnts[vi].move
            ? tileDataMove : (renEnts[vi].attack
              ? tileDataAttack : tileData)));
      vi++;
    }
  }
  
  function clearMove():Void {
    for (vi in 0...renEnts.length) {
      renEnts[vi].move = false;
      renEnts[vi].attack = false;
      renEnts[vi].moveFX = 0;
      renEnts[vi].moveFY = 0;
      renEnts[vi].moveDist = -1;
    }
  }
  
  function bfs(sel:Unit):Array<AIOutcome> {
    var ret:Array<AIOutcome> = [];
    clearMove();
    var queue = [{fx: sel.gridX, fy: sel.gridY, x: sel.gridX, y: sel.gridY, dist: 0}];
    while (queue.length > 0) {
      var cur = queue.shift();
      if (!cur.x.withinI(0, w - 1) || !cur.y.withinI(0, h - 1)) continue;
      var i = c2i(cur.x, cur.y);
      var cent = renEnts[i];
      if (units[i] != null && units[i] != sel) {
        if (units[i].player != sel.player) {
          ret.push({
               score: 0
              ,ati: i
              ,attack: true
            });
          cent.attack = true;
          cent.moveFX = cur.fx - cur.x;
          cent.moveFY = cur.fy - cur.y;
          cent.moveDist = cur.dist;
        }
        continue;
      }
      // if (!cent.walkable) continue;
      if (cent.moveDist == -1 || cur.dist < cent.moveDist) {
        ret.push({
             score: 0
            ,ati: i
            ,attack: false
          });
        cent.move = true;
        cent.moveFX = cur.fx - cur.x;
        cent.moveFY = cur.fy - cur.y;
        cent.moveDist = cur.dist;
      }
      if (cur.dist < sel.stats.mp) {
        for (off in [
             {x: -1, y: 0}
            ,{x: 1, y: 0}
            ,{x: 0, y: -1}
            ,{x: 0, y: 1}
          ]) {
          queue.push({fx: cur.x, fy: cur.y, x: cur.x + off.x, y: cur.y + off.y, dist: cur.dist + 1});
        }
      }
    }
    return ret;
  }
  
  function act(sel:Unit, ati:Int):Void {
    if (ati == c2i(sel.gridX, sel.gridY)) return;
    var curi = ati;
    var cur = renEnts[ati];
    var canim:UnitAnimation = None;
    if (renEnts[ati].attack) {
      canim = Func(() -> {
          units[ati].hit(sel.stats.ap);
          sel.stats.mp = 0;
        }, None);
    }
    var first = true;
    while (cur.moveFX != 0 || cur.moveFY != 0) {
      canim = (renEnts[ati].attack && first
        ? Attack(-cur.moveFX, -cur.moveFY, 0, canim)
        : Walk(-cur.moveFX, -cur.moveFY, 0, canim));
      curi += c2i(cur.moveFX, cur.moveFY);
      cur = renEnts[curi];
      sel.stats.mp--;
      first = false;
    }
    sel.anim = canim;
  }
  
  function initTurn(turn:TurnState):TurnState {
    this.turn = turn;
    switch (turn) {
      case Select(sel): bfs(sel);
      case _: clearMove();
    }
    return turn;
  }
  
  public function gridClick(x:Int, y:Int):Void {
    var ati = c2i(x, y);
    switch (state) {
      case Turn(true, _):
      var showStats = false;
      var atGrid = units[ati];
      turn = (switch (turn) {
          case Idle:
          if (atGrid != null) {
            showStats = true;
            atGrid.player ? Select(atGrid) : Inspect(atGrid);
          } else Idle;
          case Inspect(_):
          if (atGrid != null) {
            showStats = true;
            atGrid.player ? Select(atGrid) : Inspect(atGrid);
          } else Idle;
          case Select(sel):
          if (atGrid == sel) Idle;
          else if (renEnts[ati].move || renEnts[ati].attack) {
            act(sel, ati);
            WaitFor(sel);
          } else if (atGrid == null) Idle;
          else if (atGrid.player) {
            showStats = true;
            Select(atGrid);
          }
          else Idle;
          case _: turn;
        });
      if (showStats) GUI.showStats(atGrid.stats);
      else GUI.hide("stats");
      initTurn(turn);
      case _:
    }
  }
}

class GridTile implements Entity {
  public var grid:Grid;
  public var part:P3DPart;
  public var x:Int;
  public var y:Int;
  public var mouse:Bool = false;
  public var move:Bool = false;
  public var attack:Bool = false;
  public var moveFX:Int;
  public var moveFY:Int;
  public var moveDist:Int;
  
  public function new(grid:Grid, x:Int, y:Int) {
    this.grid = grid;
    this.x = x;
    this.y = y;
    part = new P3DPart(this);
    part.vert = false;
    part.x = x * Grid.TILE_DIM + Grid.TILE_MARGIN;
    part.y = y * Grid.TILE_DIM + Grid.TILE_MARGIN;
    part.z = 1;
    part.data = Grid.tileData;
    part.w = part.h = Grid.TILE_DIM - Grid.TILE_MARGIN * 2;
    part.dw = part.dh = 1;
  }
  
  public function partClick():Void grid.gridClick(x, y);
  public function partMOver():Void mouse = true;
  public function partMLeave():Void mouse = false;
}

enum GridState {
  // intro, win, loss?
  
  Turn(player:Bool, time:Int);
}

enum TurnState {
  Idle;
  Inspect(u:Unit);
  Select(u:Unit);
  WaitFor(u:Unit);
}

typedef AIOutcome = {
     score:Float
    ,ati:Int
    ,attack:Bool
  };
