package ;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import flixel.group.FlxGroup;

class AimNode extends FlxSprite {
	var world:WorldLevel;
	var state:PlayState;

	public var timer = 3;

	public function new (X:Float,Y:Float,_state:PlayState){
		super(X,Y);

		world = _state.activeLevel;

		state=_state;

		velocity.x = 95;
		velocity.y += 10;


		loadGraphic("assets/images/Node.png",false,8,8);
		//animation.add("run",[0]);

		drag.set();
	}

	public function move (multiplier):Bool{
		super.update();

		velocity.y += 1.5*multiplier;



		if (world.collideWithLevel (this) || timer < 0) {
			return false;
			kill();
		}
		return true;
	}
}