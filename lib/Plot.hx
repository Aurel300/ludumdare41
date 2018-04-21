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
  var ents:Vector<Entity>;
  var entIndex:Int;
  
  public function new() {
    zbuf = new Uint8ClampedArray(Main.WH);
    pbuf = new Uint8ClampedArray(Main.WH);
    ibuf = new Uint8ClampedArray(Main.WH);
    lbuf = new Uint8ClampedArray(Main.WH);
    renvec = new Vector<Colour>(Main.WH);
    ents = new Vector(256);
    entIndex = 1;
  }
  
  public function prerender():Void {
    untyped __js__("{0}.fill(0)", ibuf);
    entIndex = 1;
  }
  
  public function render(to:Bitmap):Void {
    for (vi in 0...Main.WH) renvec[vi] = Pal.light[pbuf[vi] + (lbuf[vi] << 5)];
    to.setVector(renvec);
    untyped __js__("{0}.fill(0)", zbuf);
    untyped __js__("{0}.fill(1)", pbuf);
    untyped __js__("{0}.fill(0)", lbuf);
  }
  
  public function registerEntity(e:Entity):Int {
    ents[entIndex] = e;
    return entIndex++;
  }
  
  public inline function plot(x:Int, y:Int, z:Int, col:Int, light:Int, ent:Int):Void {
    var i = x + y * Main.W;
    if (col == 0) return;
    if (z > zbuf[i]) {
      zbuf[i] = z;
      if (ent > 0) ibuf[i] = ent;
      if (col > 0) {
        pbuf[i] = col;
        lbuf[i] = light;
      } else {
        lbuf[i]++;
      }
    }
  }
  
  public function click(x:Int, y:Int):Void {
    var i = x + y * Main.W;
    if (ibuf[i] != 0) {
      ents[ibuf[i]].partClick();
    }
  }
}

#end
