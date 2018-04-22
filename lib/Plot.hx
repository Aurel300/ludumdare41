package lib;

#if js

import haxe.ds.Vector;
import js.html.Uint8ClampedArray;
import sk.thenet.bmp.*;

using sk.thenet.FM;

class Plot {
  var zbuf:Uint8ClampedArray; // z coord
  var pbuf:Uint8ClampedArray; // palette indices
  var ibuf:Uint8ClampedArray; // entity / part id
  var lbuf:Uint8ClampedArray; // light value
  var renvec:Vector<Colour>;
  var ents:Vector<Entity>;
  var entIndex:Int;
  var lastHover:Entity;
  
  public var w:Int;
  public var h:Int;
  public var wh:Int;
  
  public function new(w:Int, h:Int) {
    this.w = w;
    this.h = h;
    wh = w * h;
    zbuf = new Uint8ClampedArray(wh);
    pbuf = new Uint8ClampedArray(wh);
    ibuf = new Uint8ClampedArray(wh);
    lbuf = new Uint8ClampedArray(wh);
    renvec = new Vector<Colour>(wh);
    ents = new Vector(256);
    entIndex = 1;
  }
  
  public function prerender(alpha:Bool):Void {
    untyped __js__("{0}.fill(0)", ibuf);
    if (alpha) {
      untyped __js__("{0}.fill(0)", pbuf);
    } else {
      untyped __js__("{0}.fill(1)", pbuf);
    }
    entIndex = 1;
  }
  
  public function render(to:Bitmap, x:Int, y:Int):Void {
    var vec = to.getVector();
    if (x != 0 || y != 0 || w != to.width || h != to.height) {
      var vi = 0;
      for (ry in 0...h) for (rx in 0...w) {
        if ((x + rx).withinI(0, to.width - 1) && (y + ry).withinI(0, to.height - 1)) {
          vec[x + rx + (y + ry) * to.width] = Pal.light[pbuf[vi] + (lbuf[vi] << 5)];
        }
        vi++;
      }
    } else {
      for (vi in 0...wh) vec[vi] = Pal.light[pbuf[vi] + (lbuf[vi] << 5)];
    }
    to.setVector(vec);
    /*
    for (vi in 0...wh) renvec[vi] = Pal.light[pbuf[vi] + (lbuf[vi] << 5)];
    to.setVectorRect(x, y, w, h, renvec);
    */
    untyped __js__("{0}.fill(0)", zbuf);
    untyped __js__("{0}.fill(0)", lbuf);
  }
  
  public function renderAlpha(to:Bitmap, x:Int, y:Int):Void {
    var vec = to.getVector();
    if (x != 0 || y != 0 || w != to.width || h != to.height) {
      var vi = 0;
      for (ry in 0...h) for (rx in 0...w) {
        if ((x + rx).withinI(0, to.width - 1) && (y + ry).withinI(0, to.height - 1)) {
          if (pbuf[vi] != 0) vec[x + rx + (y + ry) * to.width] = Pal.light[pbuf[vi] + (lbuf[vi] << 5)];
        }
        vi++;
      }
    } else {
      for (vi in 0...wh) if (pbuf[vi] != 0) vec[vi] = Pal.light[pbuf[vi] + (lbuf[vi] << 5)];
    }
    to.setVector(vec);
    untyped __js__("{0}.fill(0)", zbuf);
    untyped __js__("{0}.fill(0)", lbuf);
  }
  
  public function registerEntity(e:Entity):Int {
    ents[entIndex] = e;
    return entIndex++;
  }
  
  public inline function plot(x:Int, y:Int, z:Int, col:Int, light:Int, ent:Int):Void {
    var i = x + y * w;
    if (col == 0) return;
    if (z > zbuf[i] || zbuf[i] == 0) {
      zbuf[i] = z;
      if (ent > 0) ibuf[i] = ent;
      if (col > 0) {
        pbuf[i] = col;
        lbuf[i] = light;
      } else {
        lbuf[i] -= col;
      }
    }
  }
  
  public function mouseMove(x:Int, y:Int):Void {
    var i = x + y * w;
    var curHover = (ibuf[i] != 0 ? ents[ibuf[i]] : null);
    if (lastHover != null && lastHover != curHover) lastHover.partMLeave();
    lastHover = curHover;
    if (curHover != null) {
      curHover.partMOver();
    }
  }
  
  public function click(x:Int, y:Int):Bool {
    var i = x + y * w;
    if (ibuf[i] != 0) {
      ents[ibuf[i]].partClick();
      return true;
    }
    return false;
  }
}

#end
