package lib;

class Burger extends Unit {
  public var lastZ:Int = 0;
  
  public function new() {
    super();
  }
  
  public function addLayer(t:BurgerLayer):Void {
    lastZ += 1;
    var off = 0;
    layers.push(P3DBuild.build(
        Anchor("")
        ,[Offset(switch (t) {
            case BunTop: off = 6; Unit.ss["bunTop"];
            case Tomato: off = 2; Unit.ss["tomato"];
            case BunBottom: off = 5; Unit.ss["bunBottom"];
          }, 0, 0, lastZ, 0)]
        ,null
      ));
    lastZ += off;
  }
}

enum BurgerLayer {
  BunTop;
  Tomato;
  BunBottom;
}
