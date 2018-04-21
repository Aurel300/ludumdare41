package lib;

#if js

import haxe.ds.Vector;
import js.html.Uint8ClampedArray;
import sk.thenet.bmp.*;

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
  }
}

#end
