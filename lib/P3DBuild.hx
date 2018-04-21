package lib;

import haxe.ds.Vector;
import sk.thenet.bmp.Bitmap;

class P3DBuild {
  public static function build(s:P3DSkeleton):P3DBuild {
    return null;
    /*
    var ret:Array<P3DPart> = [];
    function subBuild(root:P3DPart, s:P3DSkeleton):Void {
      switch (s) {
        case Box(top, sides):
        
      }
    }
    subBuild(null, s);
    return new P3DBuild(Vector.fromArrayCopy(ret));
    */
  }
  
  public var parts:Vector<P3DPart>;
  public var angle:Int;
  public var tilt:Int;
  
  public function new(parts:Array<P3DPart>) {
    this.parts = Vector.fromArrayCopy(parts);
  }
}

enum P3DSkeleton {
  Box(top:Bitmap, sides:Array<Bitmap>);
}
