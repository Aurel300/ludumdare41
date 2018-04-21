package lib;

import haxe.ds.Vector;
import sk.thenet.bmp.Bitmap;

class P3DBuild {
  public static function build(s:P3DSkeleton):P3DBuild {
    return null;
  }
  
  public var parts:Vector<P3DPart>;
  
  public function new(parts:Array<P3DPart>) {
    this.parts = Vector.fromArrayCopy(parts);
  }
}

enum P3DSkeleton {
  Box(top:Bitmap, sides:Array<Bitmap>);
}
