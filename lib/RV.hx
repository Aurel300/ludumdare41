package lib;

class RV extends Unit {
  public function new() {
    super();
    player = true;
    stats = {
         name: "RV"
        ,hp: 10, hpMax: 10
        ,ap: 0, apMax: 0
        ,mp: 1, mpMax: 1
        ,rank: null
        ,traits: []
        ,poison: 0
      };
    layers = [P3DBuild.build(Anchor(""), Unit.ss["rv"], null)];
    layerAngles = [ for (l in layers) l.angle ];
  }
}
