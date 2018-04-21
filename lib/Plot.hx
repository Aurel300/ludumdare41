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
  public var lbuf:Uint8ClampedArray; // light value
  
  var renvec:Vector<Colour>;
  
  public function new() {
    zbuf = new Uint8ClampedArray(Main.WH);
    pbuf = new Uint8ClampedArray(Main.WH);
    ibuf = new Uint8ClampedArray(Main.WH);
    lbuf = new Uint8ClampedArray(Main.WH);
    renvec = new Vector<Colour>(Main.WH);
  }
  
  public function render(to:Bitmap):Void {
    for (vi in 0...Main.WH) renvec[vi] = Pal.light[pbuf[vi] + (lbuf[vi] << 5)];
    to.setVector(renvec);
    untyped __js__("{0}.fill(0)", zbuf);
    untyped __js__("{0}.fill(1)", pbuf);
    untyped __js__("{0}.fill(0)", lbuf);
    // untyped __js__("{0}.fill(0)", ibuf);
  }
  
  public inline function plot(x:Int, y:Int, z:Int, col:Int, light:Int):Void {
    var i = x + y * Main.W;
    if (col == 0) return;
    //if (x.withinI(0, Main.W - 1) && ey.withinI(0, Main.H - 1)) {
      if (z > zbuf[i]) {
        pbuf[i] = col;
        zbuf[i] = z;
        lbuf[i] = light;
      }
    //}
  }
}

#end
