package lib;

class Grid {
  static inline var TILE_DIM:Int = 32;
  static inline var TILE_MARGIN:Int = 2;
  
  public var x:Int = 0;
  public var y:Int = 0;
  public var w:Int;
  public var h:Int;
  
  public var units:Vector<Unit>;
  
  public var renTiles:Vector<P3DPart>;
  
  var tileData:Vector<Int>;
  
  public function new(w:Int, h:Int) {
    this.w = w;
    this.h = h;
    units = new Vector<Unit>(w * h);
    renTiles = new Vector<P3DPart>(w * h);
    tileData = new Vector((TILE_DIM - 2 * TILE_MARGIN) * (TILE_DIM - 2 * TILE_MARGIN));
    for (vi in 0...tileData.length) tileData[vi] = -1;
    var vi = 0;
    for (y in 0...h) for (x in 0...w) {
      var tile = new P3DPart(null);
      tile.vert = false;
      tile.x = x * TILE_DIM + TILE_MARGIN;
      tile.y = y * TILE_DIM + TILE_MARGIN;
      tile.z = 1;
      tile.data = tileData;
      tile.w = TILE_DIM - TILE_MARGIN * 2;
      tile.h = TILE_DIM - TILE_MARGIN * 2;
      renTiles[vi++] = tile;
    }
  }
  
  public function render(to:Plot, p3d:P3D):Void {
    for (t in renTiles) p3d.render(to, t);
  }
}
