package ;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;

class Bomb extends FlxSprite {
	var world:WorldLevel;
	var state:PlayState;

	public var timer = 3;

	public function new (X:Float,Y:Float,_state:PlayState){
		super(X,Y);

		world = _state.activeLevel;

		state=_state;

		velocity.x = 95;
		velocity.y += 10;


		loadGraphic("assets/images/Bomb.png",false,16,16);
		//animation.add("run",[0]);

		drag.set();
	}

	override public function update (){
		super.update();

		velocity.y += 1.5;


		if (world.collideWithLevel (this) || timer < 0) {
			//Hit something
			var bombTileX = Math.floor(x/16);
			var bombTileY = Math.floor(y/16);
			for (ex in -2...2){
				for (ey in -2...2){
					world.destroyDestructableTile(bombTileX+ex,bombTileY+ey);
				}
			}
			world.updateAllBuffers();
			kill();
		}
	}
}