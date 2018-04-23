package lib;

class Scorpion extends Unit {
  public function new() {
    super();
    stats = {
         name: "Scorpion"
        ,hp: 1, hpMax: 1
        ,ap: 1
        ,mp: 1, mpMax: 1
        ,rank: null
        ,traits: []
      };
    layers = [P3DBuild.build(
         Anchor("")
        ,Unit.ss["scorpion2"]
        ,null
      )];
  }
}
