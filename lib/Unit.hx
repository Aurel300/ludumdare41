package lib;

import lib.P3DBuild.P3DSkeleton;

class Unit {
  public static var as:Map<String, Bitmap>;
  public static var ss:Map<String, Array<P3DSkeleton>>;
  
  public static function init(u:Bitmap):Void {
    as = new Map();
    ss = [
         "bunTop" => [Offset([P3DBuild.autoBox(u, 0, 8, 16, 16, 6)], -8, -8, 0, 0)]
        ,"bunBottom" => [Offset([P3DBuild.autoBox(u, 0, 32, 16, 16, 5)], -8, -8, 0, 0)]
        ,"tomato" => [Offset([P3DBuild.autoBox(u, 0, 56, 18, 18, 2)], -9, -9, 0, 0)]
      ];
  }
  
  public var player:Bool;
  public var grid:Grid;
  public var gridX:Int = 0;
  public var gridY:Int = 0;
  public var anim:UnitAnimation = None;
  
  public var layers:Array<P3DBuild> = [];
  
  public function new() {
    
  }
  
  public function update():Void {
    for (l in layers) {
      l.x = gridX * Grid.TILE_DIM + Grid.TILE_HALF;
      l.y = gridY * Grid.TILE_DIM + Grid.TILE_HALF;
    }
  }
}

enum UnitAnimation {
  None;
  Idle(v:Int, t:Int);
}
