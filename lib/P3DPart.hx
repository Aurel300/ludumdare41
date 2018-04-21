package lib;

import haxe.ds.Vector;
import sk.thenet.bmp.*;

class P3DPart {
  public var x:Int = 0;
  public var y:Int = 0;
  public var z:Int = 0;
  public var owner:Entity;
  public var sub:Array<P3DPart> = [];
  
  public var bitmap(never, set):Bitmap;
  private inline function set_bitmap(b:Bitmap):Bitmap {
    data = new Vector<Int>(b.width * b.height);
    for (vi in 0...data.length) {
      data[vi] = 1;
    }
    w = b.width;
    h = b.height;
    return b;
  }
  
  public var data:Vector<Int>;
  public var w:Int;
  public var h:Int;
  public var horizontal:Bool = true;
  public var angle:Int = 0;
  public var tilt:Int = 0;
  public var showA:Bool = true;
  public var showB:Bool = true;
  
  public function new(owner:Entity) {
    this.owner = owner;
  }
}
