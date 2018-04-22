package lib;

import haxe.ds.Vector;
import sk.thenet.bmp.*;
import sk.thenet.FM;

class P3DPart {
  public var x:Int = 0;
  public var y:Int = 0;
  public var z:Int = 0;
  public var entity:Entity;
  public var sub:Array<P3DPart> = [];
  
  public var bitmap(never, set):Bitmap;
  private inline function set_bitmap(b:Bitmap):Bitmap {
    var vec = b.getVector();
    data = new Vector<Int>(b.width * b.height);
    for (vi in 0...data.length) {
      if (vec[vi].isTransparent) data[vi] = 0;
      else data[vi] = Colour.quantise(vec[vi], Pal.reg);
    }
    dw = w = b.width;
    dh = h = b.height;
    return b;
  }
  
  public var display:Bool = true;
  public var data:Vector<Int>;
  public var dw:Int;
  public var dh:Int;
  public var w:Int;
  public var h:Int;
  public var vert:Bool = true;
  public var angle:Int = 0;
  public var lightAngle:Int = 0;
  public var tilt:Int = 0;
  public var showA:Bool = true;
  public var showB:Bool = true;
  
  public function new(entity:Entity) {
    this.entity = entity;
  }
  
  public function remap(map:Map<Int, Int>):Void {
    if (data == null) return;
    for (i in 0...data.length) {
      if (map.exists(data[i])) {
        data[i] = map[data[i]];
      }
    }
  }
}
