package lib;

class Grid {
  public static inline var TILE_DIM:Int = 32;
  public static inline var TILE_HALF:Int = 16;
  public static inline var TILE_MARGIN:Int = 2;
  public static var tileData:Vector<Int> = Vector.fromArrayCopy([-1]);
  public static var tileDataHover:Vector<Int> = Vector.fromArrayCopy([-3]);
  
  public var x:Int = 0;
  public var y:Int = 0;
  public var w:Int;
  public var h:Int;
  
  public var units:Vector<Unit>;
  public var renTiles:Vector<P3DPart>;
  
  var renEnts:Vector<GridTile>;
  
  public function new(w:Int, h:Int) {
    this.w = w;
    this.h = h;
    units = new Vector(w * h);
    renEnts = new Vector(w * h);
    renTiles = new Vector(w * h);
    var vi = 0;
    for (y in 0...h) for (x in 0...w) {
      renEnts[vi] = new GridTile(x, y);
      renTiles[vi] = renEnts[vi].part;
      vi++;
    }
    
    var b = new Burger();
    b.grid = this;
    b.gridX = 2;
    b.gridY = 2;
    b.addLayer(BunBottom);
    b.addLayer(Tomato);
    b.addLayer(Carrot);
    b.addLayer(Patty(1));
    b.addLayer(Cheese);
    b.addLayer(Cucumber);
    b.addLayer(Lettuce);
    b.addLayer(BunTop);
    units[2 + 2 * 5] = b;
  }
}

class GridTile implements Entity {
  public var part:P3DPart;
  
  public function new(x:Int, y:Int) {
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
    
  }
  
  public function partMOver():Void {
    part.z = 3;
    part.data = Grid.tileDataHover;
  }
  
  public function partMLeave():Void {
    part.z = 1;
    part.data = Grid.tileData;
  }
}
