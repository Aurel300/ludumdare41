package lib;

#if js

import haxe.ds.Vector;
import js.html.Uint8ClampedArray;
import sk.thenet.bmp.*;

using sk.thenet.FM;

class Plot {
  public var zbuf:Uint8ClampedArray; // z coord
  public var pbuf:Uint8ClampedArray; // palette indices
  public var ibuf:Uint8ClampedArray; // entity / part id
  
  public var palette:Vector<Colour>;
  
  var renvec:Vector<Colour>;
  
  public function new() {
    zbuf = new Uint8ClampedArray(Main.WH);
    pbuf = new Uint8ClampedArray(Main.WH);
    ibuf = new Uint8ClampedArray(Main.WH);
    renvec = new Vector<Colour>(Main.WH);
    
    palette = Vector.fromArrayCopy([(0xFF000000:Colour), (0xFFAA0000:Colour)]);
  }
  
  public function render(to:Bitmap):Void {
    for (vi in 0...Main.WH) renvec[vi] = palette[pbuf[vi]];
    to.setVector(renvec);
    untyped __js__("{0}.fill(0)", zbuf);
    untyped __js__("{0}.fill(0)", pbuf);
    // untyped __js__("{0}.fill(0)", ibuf);
  }
  
  public inline function plot(x:Int, y:Int, z:Int, col:Int):Void {
    var i = x + (y - z) * Main.W;
    //if (x.withinI(0, Main.W - 1) && ey.withinI(0, Main.H - 1)) {
      if (z > zbuf[i]) {
        pbuf[i] = col;
        zbuf[i] = z;
      }
    //}
  }
}

#end
