package lib;

class Grid {
  public static inline var TILE_DIM:Int = 32;
  public static inline var TILE_HALF:Int = 16;
  public static inline var TILE_MARGIN:Int = 2;
  public static var tileData:Vector<Int> = Vector.fromArrayCopy([-1]);
  public static var tileDataSelect:Vector<Int> = Vector.fromArrayCopy([-2]);
  public static var tileDataHover:Vector<Int> = Vector.fromArrayCopy([-3]);
  
  public var x:Int = 0;
  public var y:Int = 0;
  public var w:Int;
  public var h:Int;
  
  public var units:Vector<Unit>;
  public var renTiles:Vector<P3DPart>;
  
  public var state:GridState = Turn(true);
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
  
  public function update():Void {
    
  }
  
  public function gridClick(x:Int, y:Int):Void {
    switch (state) {
      case Turn(true):
      var atGrid = units[x + y * w];
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
            sel.moveTo(x, y);
            Idle;
          } else if (atGrid.player) Select(atGrid);
          else Idle;
          case _: turn;
        });
      case _:
    }
  }
}

class GridTile implements Entity {
  public var grid:Grid;
  public var part:P3DPart;
  public var x:Int;
  public var y:Int;
  
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
  
  public function partClick():Void {
    grid.gridClick(x, y);
  }
  
  public function partMOver():Void {
    part.data = Grid.tileDataHover;
  }
  
  public function partMLeave():Void {
    part.data = Grid.tileData;
  }
}

enum GridState {
  // intro, win, loss?
  
  Turn(player:Bool);
}

enum TurnState {
  Idle;
  Inspect(u:Unit);
  Select(u:Unit);
  WaitFor(u:Unit);
}
