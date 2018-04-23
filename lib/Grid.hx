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
  }
  
  inline function c2i(x:Int, y:Int):Int return x + y * w;
  
  function clearUnits(player:Bool):Void {
    for (vi in 0...units.length) {
      if (units[vi] == null) continue;
      if (units[vi].player != player) continue;
      units[vi].stats.mp = units[vi].stats.mpMax;
    }
  }
  
  public function update():Void {
    state = (switch [state, turn] {
        case [_, WaitFor(u)]: turn = (u.anim == None ? initTurn(Idle) : turn); state;
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
        case [Turn(true, t), Inspect(s) | Select(s)]:
        c2i(s.gridX, s.gridY);
        case _: -1;
      });
    var vi = 0;
    for (y in 0...h) for (x in 0...w) {
      renTiles[vi].data = renEnts[vi].mouse
        ? tileDataHover : (vi == selVi
          ? tileDataSelect : (renEnts[vi].move
            ? tileDataMove
            : tileData));
      vi++;
    }
  }
  
  function clearMove():Void {
    for (vi in 0...renEnts.length) {
      renEnts[vi].move = false;
      renEnts[vi].moveFX = 0;
      renEnts[vi].moveFY = 0;
      renEnts[vi].moveDist = -1;
    }
  }
  
  function initTurn(turn:TurnState):TurnState {
    this.turn = turn;
    switch (turn) {
      case Select(sel):
      clearMove();
      var queue = [{fx: sel.gridX, fy: sel.gridY, x: sel.gridX, y: sel.gridY, dist: 0}];
      while (queue.length > 0) {
        var cur = queue.shift();
        if (!cur.x.withinI(0, w - 1) || !cur.y.withinI(0, h - 1)) continue;
        var i = c2i(cur.x, cur.y);
        if (units[i] != null && units[i] != sel) continue;
        var cent = renEnts[i];
        // if (!cent.walkable) continue;
        if (cent.moveDist == -1 || cur.dist < cent.moveDist) {
          cent.move = true;
          cent.moveFX = cur.fx - cur.x;
          cent.moveFY = cur.fy - cur.y;
          cent.moveDist = cur.dist;
        }
        if (cur.dist < sel.stats.mp) {
          queue.push({fx: cur.x, fy: cur.y, x: cur.x - 1, y: cur.y, dist: cur.dist + 1});
          queue.push({fx: cur.x, fy: cur.y, x: cur.x + 1, y: cur.y, dist: cur.dist + 1});
          queue.push({fx: cur.x, fy: cur.y, x: cur.x, y: cur.y - 1, dist: cur.dist + 1});
          queue.push({fx: cur.x, fy: cur.y, x: cur.x, y: cur.y + 1, dist: cur.dist + 1});
        }
      }
      case _: clearMove();
    }
    return turn;
  }
  
  public function gridClick(x:Int, y:Int):Void {
    var ati = c2i(x, y);
    switch (state) {
      case Turn(true, _):
      var atGrid = units[ati];
      turn = (switch (turn) {
          case Idle:
          if (atGrid != null) {
            atGrid.player ? Select(atGrid) : Inspect(atGrid);
          } else Idle;
          case Inspect(_):
          if (atGrid != null) {
            atGrid.player ? Select(atGrid) : Inspect(atGrid);
          } else Idle;
          case Select(sel):
          if (atGrid == sel) Idle;
          else if (atGrid == null) {
            if (renEnts[ati].move) {
              var curi = ati;
              var cur = renEnts[ati];
              var canim:UnitAnimation = None;
              while (cur.moveFX != 0 || cur.moveFY != 0) {
                canim = Walk(-cur.moveFX, -cur.moveFY, 0, canim);
                curi += c2i(cur.moveFX, cur.moveFY);
                cur = renEnts[curi];
                sel.stats.mp--;
              }
              sel.anim = canim;
              WaitFor(sel);
            } else Idle;
          } else if (atGrid.player) Select(atGrid);
          else Idle;
          case _: turn;
        });
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
