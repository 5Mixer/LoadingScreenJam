package ;

import flixel.FlxSprite;
import flixel.FlxG;

class Player extends FlxSprite {
	var world:WorldLevel;

	public function new (X:Int,Y:Int,level:WorldLevel){
		super(X,Y);

		world = level;


		loadGraphic("assets/images/Player.png",true,16,16);
		animation.add("run",[0]);

		drag.set();
	}

	override public function update (){
		super.update();

		animation.play("run");

		velocity.x = 95;
		velocity.y += 9;

		if (world.checkForDeaths (this)) {
			//Hit something deadly
			trace("Restarting");
			this.x = (40);
			this.y = (40);
		}

		if (world.collideWithLevel(this)){
			if (FlxG.keys.justPressed.SPACE){

				velocity.y = -230;
			}
		}
	}
}