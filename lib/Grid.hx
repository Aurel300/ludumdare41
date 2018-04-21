package lib;

class Grid {
  public static inline var TILE_DIM:Int = 32;
  public static inline var TILE_MARGIN:Int = 2;
  public static var tileData:Vector<Int> = {
      var ret = new Vector((TILE_DIM - 2 * TILE_MARGIN) * (TILE_DIM - 2 * TILE_MARGIN));
      for (vi in 0...ret.length) ret[vi] = -1;
      ret;
    };
  
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
  }
  
  public function render(to:Plot, p3d:P3D):Void {
    for (t in renTiles) p3d.render(to, t);
  }
}

class GridTile implements Entity {
  public var part:P3DPart;
  
  public function new(x:Int, y:Int) {
    part = new P3DPart(null);
    part.vert = false;
    part.x = x * Grid.TILE_DIM + Grid.TILE_MARGIN;
    part.y = y * Grid.TILE_DIM + Grid.TILE_MARGIN;
    part.z = 1;
    part.data = Grid.tileData;
    part.w = Grid.TILE_DIM - Grid.TILE_MARGIN * 2;
    part.h = Grid.TILE_DIM - Grid.TILE_MARGIN * 2;
    part.entity = this;
  }
  
  public function partClick():Void {
    trace("?");
    part.z += 5;
  }
}
