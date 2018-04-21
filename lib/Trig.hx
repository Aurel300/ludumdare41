package lib;

import haxe.ds.Vector;

class Trig {
  public static inline var densityAngle:Int = 36;
  
  public static var cosAngle:Vector<Float>;
  public static var sinAngle:Vector<Float>;
  
  public static function init():Void {
    cosAngle = new Vector<Float>(densityAngle);
    sinAngle = new Vector<Float>(densityAngle);
    for (i in 0...densityAngle) {
      var a = (i / densityAngle) * Math.PI * 2;
      cosAngle[i] = Math.cos(a);
      sinAngle[i] = Math.sin(a);
    }
    cosAngle[0] = 1;
    sinAngle[0] = 0;
    cosAngle[9] = 0;
    sinAngle[9] = 1;
    cosAngle[18] = -1;
    sinAngle[18] = 0;
    cosAngle[27] = 0;
    sinAngle[27] = -1;
  }
}
