package lib;

class Burger extends Unit {
  static var pattyMap = [
       0 => null
      ,1 => [
           17 => 7
          ,18 => 17
          ,19 => 18
        ]
      ,2 => [
           17 => 7
          ,18 => 23
          ,19 => 1
        ]
      ,3 => [
           17 => 7
          ,18 => 20
          ,19 => 21
        ]
    ];
  
  public var lastZ:Int = 0;
  
  public function new() {
    super();
  }
  
  public function addLayer(t:BurgerLayer, ?map:Map<Int, Int>):Void {
    var off = 0;
    var layer = P3DBuild.build(
        Anchor("")
        ,[Offset(switch (t) {
            case BunTop: off = 6; Unit.ss["bunTop"];
            case Tomato: off = 2; Unit.ss["tomato"];
            case Carrot: off = 2; Unit.ss["carrot"];
            case Cucumber: off = 2; Unit.ss["cucumber"];
            case Patty(cook): map = pattyMap[cook]; off = 4; Unit.ss["patty"];
            case Lettuce: off = 1; Unit.ss["lettuce"];
            case Cheese: off = 1; Unit.ss["cheese"];
            case BunBottom: off = 5; Unit.ss["bunBottom"];
          }, 0, 0, lastZ, lastZ % Trig.densityAngle)]
        ,null
      );
    if (map != null) {
      for (p in layer.parts) p.remap(map);
    }
    layers.push(layer);
    lastZ += off;
  }
}

enum BurgerLayer {
  BunTop;
  Tomato;
  Carrot;
  Cucumber;
  Patty(cook:Int);
  Lettuce;
  Cheese;
  BunBottom;
}
