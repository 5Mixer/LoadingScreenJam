package ;

import flixel.FlxSprite;
import flixel.FlxG;

class Ball extends FlxSprite {
	var world:WorldLevel;
	var state:PlayState;

	public function new (X:Int,Y:Int,_state:PlayState){
		super(X,Y);

		world = _state.activeLevel;

		state=_state;

		velocity.x = 95;
		velocity.y += 10;


		makeGraphic(flixel.util.FlxColor.GRAY,16,16);
		drag.set();
	}

	override public function update (){
		super.update();

		animation.play("run");



		if (world.checkForDeaths (this) || velocity.x == 0) {
			//Hit something deadly
			trace("Restarting");
			state.mode = PlayState.PlayMode.shooting;
			state.resetWorld();
			//this.x = (40);
			//this.y = (40);
		}

		velocity.x = 95;
		velocity.y += 10;

		if (world.collideWithLevel(this)){
			if (FlxG.keys.pressed.SPACE){

				velocity.y = -250;
			}
		}
	}
}
