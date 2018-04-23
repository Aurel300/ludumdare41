package lib;

class Enemy extends Unit {
  public var type:EnemyType;
  
  public function new(type:EnemyType) {
    super();
    this.type = type;
    switch (type) {
      case Scorpion(t):
      stats = t == 1 ? {
           name: "Scorpion"
          ,hp: 3, hpMax: 3
          ,ap: 2
          ,mp: 1, mpMax: 1
          ,rank: null
          ,traits: []
        } : {
           name: "Scorpicore"
          ,hp: 3, hpMax: 3
          ,ap: 2
          ,mp: 2, mpMax: 2
          ,rank: null
          ,traits: []
        };
      layers = [P3DBuild.build(
           Anchor("")
          ,Unit.ss["scorpion" + t]
          ,null
        )];
      case Ufo(t):
      stats = (switch (t) {
          case 1: {
             name: "UFO minor"
            ,hp: 2, hpMax: 2
            ,ap: 1
            ,mp: 4, mpMax: 4
            ,rank: null
            ,traits: []
          };
          case 2: {
             name: "UFO major"
            ,hp: 4, hpMax: 4
            ,ap: 4
            ,mp: 3, mpMax: 3
            ,rank: null
            ,traits: []
          };
          case _: {
             name: "UFO saucer"
            ,hp: 7, hpMax: 7
            ,ap: 4
            ,mp: 3, mpMax: 3
            ,rank: null
            ,traits: []
          };
        });
      layers = [P3DBuild.build(
           Anchor("")
          ,Unit.ss["ufo" + t]
          ,null
        )];
    }
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
