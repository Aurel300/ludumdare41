package lib;

import haxe.ds.Vector;

class Trig {
  public static inline var densityAngle:Int = 36;
  public static inline var densityTilt:Int = 9;
  
  public static var cosAngle:Vector<Float>;
  public static var sinAngle:Vector<Float>;
  public static var cosTilt:Vector<Float>;
  public static var sinTilt:Vector<Float>;
  
  
  public static function init():Void {
    cosAngle = new Vector<Float>(densityAngle);
    sinAngle = new Vector<Float>(densityAngle);
    for (i in 0...densityAngle) {
      var a = (i / densityAngle) * Math.PI * 2;
      cosAngle[i] = Math.cos(a);
      sinAngle[i] = Math.sin(a);
    }
    cosTilt = new Vector<Float>(densityTilt);
    sinTilt = new Vector<Float>(densityTilt);
    for (i in 0...densityTilt) {
      var a = (i / (densityTilt - 1)) * Math.PI / 2;
      cosTilt[i] = Math.cos(a);
      sinTilt[i] = Math.sin(a);
    }
  }
}
