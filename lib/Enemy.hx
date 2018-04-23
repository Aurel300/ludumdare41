package lib;

class Enemy extends Unit {
  public var type:EnemyType;
  
  public function new(type:EnemyType) {
    super();
    this.type = type;
    function makeStats(s:{name:String, hp:Int, ap:Int, mp:Int, ?traits:Array<UnitTrait>}):UnitStats {
      return {
           name: s.name
          ,hp: s.hp, hpMax: s.hp
          ,ap: s.ap, apMax: s.ap
          ,mp: s.mp, mpMax: s.mp
          ,rank: null
          ,traits: s.traits == null ? [] : s.traits
          ,poison: 0
        };
    }
    switch (type) {
      case Scorpion(t):
      stats = makeStats(t == 1 ? {
           name: "Scorpion"
          ,hp: 3
          ,ap: 2
          ,mp: 1
        } : {
           name: "Scorpicore"
          ,hp: 3
          ,ap: 2
          ,mp: 2
        });
      layers = [P3DBuild.build(
           Anchor("")
          ,Unit.ss["scorpion" + t]
          ,null
        )];
      case Ufo(t):
      stats = makeStats(switch (t) {
          case 1: {
             name: "UFO minor"
            ,hp: 2
            ,ap: 1
            ,mp: 4
          };
          case 2: {
             name: "UFO major"
            ,hp: 4
            ,ap: 4
            ,mp: 3
          };
          case _: {
             name: "UFO saucer"
            ,hp: 7
            ,ap: 4
            ,mp: 3
          };
        });
      layers = [P3DBuild.build(
           Anchor("")
          ,Unit.ss["ufo" + t]
          ,null
        )];
    }
    layerAngles = [ for (l in layers) l.angle ];
  }
  
  var timer:Int = 0;
  
  override public function update():Void {
    switch (type) {
      case Ufo(_):
      layers[0].z = [0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 1][timer % 11];
      case _:
    }
    timer++;
    super.update();
  }
}

enum EnemyType {
  Scorpion(t:Int);
  Ufo(t:Int);
}
