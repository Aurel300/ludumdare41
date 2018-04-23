package lib;

import sk.thenet.bmp.manip.*;
import lib.P3DBuild.P3DSkeleton;

class Unit {
  public static var as:Map<String, Bitmap>;
  public static var ss:Map<String, Array<P3DSkeleton>>;
  
  public static function init(u:FluentBitmap):Void {
    as = new Map();
    ss = [
         "bunTop" => [Offset([P3DBuild.autoBox(u, 0, 8, 16, 16, 6)], -8, -8, 0, 0)]
        ,"bunBottom" => [Offset([P3DBuild.autoBox(u, 0, 32, 16, 16, 5)], -8, -8, 0, 0)]
        ,"tomato" => [Offset([P3DBuild.autoBox(u, 0, 56, 18, 18, 2)], -9, -9, 0, 0)]
        ,"carrot" => [Offset([P3DBuild.autoBox(u, 0, 80, 16, 16, 2)], -8, -8, 0, 0)]
        ,"cucumber" => [Offset([P3DBuild.autoBox(u, 64, 80, 16, 16, 2)], -8, -8, 0, 0)]
        ,"patty" => [Offset([P3DBuild.autoBox(u, 0, 104, 19, 15, 4)], -10, -7, 0, 0)]
        ,"lettuce" => [Offset([Floor(u >> new Cut(0, 128, 32, 32), 0, 0)], -16, -16, 0, 0)]
        ,"cheese" => [Offset([Floor(u >> new Cut(32, 128, 32, 32), 0, 0)], -16, -16, 0, 0)]
      ];
  }
  
  public var player:Bool;
  public var grid:Grid;
  public var gridX:Int = 0;
  public var gridY:Int = 0;
  public var anim:UnitAnimation = None;
  
  public var stats:UnitStats;
  
  public var layers:Array<P3DBuild> = [];
  
  public function new() {
    
  }
  
  public function update():Void {
    for (l in layers) {
      l.x = gridX * Grid.TILE_DIM + Grid.TILE_HALF;
      l.y = gridY * Grid.TILE_DIM + Grid.TILE_HALF;
    }
  }
  
  public function moveTo(x:Int, y:Int):Void {
    grid.units[gridX + gridY * grid.w] = null;
    gridX = x;
    gridY = y;
    grid.units[gridX + gridY * grid.w] = this;
  }
}

enum UnitAnimation {
  None;
  Idle(v:Int, t:Int);
}
