package ;

import flixel.FlxSprite;
import flixel.FlxG;

class Player extends FlxSprite {
	var world:WorldLevel;
	var state:PlayState;

	public function new (X:Int,Y:Int,_state:PlayState){
		super(X,Y);

		world = _state.activeLevel;

		state=_state;

		velocity.x = 95;
		velocity.y += 10;


		loadGraphic("assets/images/Player.png",true,16,16);
		animation.add("run",[0,1,2,3,4,5],20);
		animation.add("slide",[10,11],2);
		animation.add("fall",[20,21,22,23,24],10);
		animation.add("takeoff",[30,31,32,33,34,35],10);

		drag.set();
	}

	override public function update (){
		super.update();

		var animationState = "";
		



		if (world.checkForDeaths (this)) {
			//Hit something deadly
			state.mode = PlayState.PlayMode.shooting;
			state.resetWorld();
		}

		
		velocity.y += 10;

		if (world.collideWithLevel(this)){
			if (velocity.x < 3 || velocity.x == 0) {
				//Hit something deadly
				state.mode = PlayState.PlayMode.shooting;
				state.resetWorld();
			} 

			if (FlxG.keys.pressed.SPACE){
				animationState = "takeoff";

				velocity.y = -250;
			}else {

				if (FlxG.keys.pressed.SHIFT){
					animationState = ("slide");
					velocity.x *= 0.98;
				}else{
					animationState = "run";
					velocity.x = 95;
				}
			}
		}

		if (velocity.y > 10){
			animationState = "fall";
		}



		if (animationState != "") animation.play(animationState);
	}
}