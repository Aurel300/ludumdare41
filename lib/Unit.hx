package lib;

import sk.thenet.anim.*;
import sk.thenet.bmp.manip.*;
import lib.P3DBuild.P3DSkeleton;

class Unit {
  static var MOVE_TIME:Int = 30;
  static var ATTACK_TIME:Int = 30;
  static var ANGLES:Array<Array<Int>> = [[0, 27, 0], [18, 0, 0], [0, 9, 0]];
  
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
        ,"sauce" => [Offset([Floor(u >> new Cut(64, 128, 32, 32), 0, 0)], -16, -16, 0, 0)]
        ,"pepsalt" => [Offset([Floor(u >> new Cut(96, 128, 32, 32), 0, 0)], -16, -16, 0, 0)]
        ,"scorpion1" => [
             Offset([Floor(u >> new Cut(64, 8, 16, 24), 0, 1)], -8, -12, 2, 0)
            ,Offset([Floor(u >> new Cut(80, 8, 16, 24), 0, 29)], -13, -12, 14, 0)
            ,Offset([Floor(u >> new Cut(96, 8, 16, 24), 0, 35)], -12, -12, 12, 0)
          ]
        ,"scorpion2" => [
             Offset([Floor(u >> new Cut(64, 32, 16, 24), 0, 1)], -8, -12, 2, 0)
            ,Offset([Floor(u >> new Cut(80, 32, 16, 24), 0, 29)], -13, -12, 14, 0)
            ,Offset([Floor(u >> new Cut(96, 32, 16, 24), 0, 35)], -12, -12, 12, 0)
          ]
        ,"ufo1" => [
             Offset([P3DBuild.autoBox(u, 112, 8, 12, 12, 8)], -6, -6, 12, 0)
          ]
        ,"ufo2" => [
             Offset([P3DBuild.autoBox(u, 112, 32, 16, 16, 11)], -8, -8, 14, 0)
          ]
        ,"ufo3" => [
              Offset([P3DBuild.autoBox(u, 112, 32, 16, 16, 11)], -8, -8, 14, 0)
             ,Offset([P3DBuild.autoBox(u, 176, 8, 24, 24, 3)], -12, -12, 16, 0)
          ]
      ];
  }
  
  public var player:Bool = false;
  public var grid:Grid;
  public var gridX:Int = 0;
  public var gridY:Int = 0;
  public var subX:Int = 0;
  public var subY:Int = 0;
  public var anim:UnitAnimation = None;
  public var aiMoved:Bool = false;
  public var angle:Int = 0;
  
  public var stats:UnitStats;
  
  public var layers:Array<P3DBuild> = [];
  public var layerAngles:Array<Int> = [];
  
  public function new() {
    
  }
  
  public function update():Void {
    anim = (switch (anim) {
        case Walk(ox, oy, f, n):
        angle = ANGLES[oy + 1][ox + 1];
        subX = (Timing.quadInOut.getF(f / MOVE_TIME) * Grid.TILE_DIM * ox).floor();
        subY = (Timing.quadInOut.getF(f / MOVE_TIME) * Grid.TILE_DIM * oy).floor();
        if (f < MOVE_TIME - 1) Walk(ox, oy, f + 1, n);
        else {
          moveTo(gridX + ox, gridY + oy);
          n;
        }
        case Attack(ox, oy, f, n):
        angle = ANGLES[oy + 1][ox + 1];
        subX = (Timing.quadIn.getF(f / ATTACK_TIME) * Grid.TILE_HALF * ox).floor();
        subY = (Timing.quadIn.getF(f / ATTACK_TIME) * Grid.TILE_HALF * oy).floor();
        if (f < ATTACK_TIME - 1) Attack(ox, oy, f + 1, n);
        else {
          subX = subY = 0;
          n;
        }
        case Func(f, n): f(); n;
        case _: None;
      });
    for (li in 0...layers.length) {
      var l = layers[li];
      l.angle = layerAngles[li] + angle;
      l.x = gridX * Grid.TILE_DIM + Grid.TILE_HALF + subX;
      l.y = gridY * Grid.TILE_DIM + Grid.TILE_HALF + subY;
    }
  }
  
  function remove():Void {
    grid.units[gridX + gridY * grid.w] = null;
  }
  
  public function hit(dmg:Int):Void {
    stats.hp -= dmg;
    if (stats.hp <= 0) {
      remove();
    }
  }
  
  public function moveTo(x:Int, y:Int):Void {
    subX = subY = 0;
    remove();
    gridX = x;
    gridY = y;
    grid.units[gridX + gridY * grid.w] = this;
  }
}
