package ;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitterExt;
import flixel.group.FlxTypedGroup;

class Bomb extends FlxSprite {
	var world:WorldLevel;
	var state:PlayState;

	public var exhaustParticles:FlxEmitterExt;

	public var timer = 3;

	public function new (X:Float,Y:Float,_state:PlayState){
		super(X,Y);

		world = _state.activeLevel;

		exhaustParticles = new FlxEmitterExt();
		exhaustParticles.setRotation(4, 40);
		exhaustParticles.makeParticles("assets/images/effects/ExhaustParticles.png",50,32,true);
		exhaustParticles.setAlpha(0.8, 0.6, 0.1, 0.1); //fade out
		exhaustParticles.setScale(0.5,0.7,0.1,0.3); //Make them skrink, and start with different sizes.

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

		exhaustParticles.setPosition(getMidpoint().x,getMidpoint().y);
		exhaustParticles.setMotion(angle+90-(34/2),20,1,34,4,5);
		exhaustParticles.start(false,0.2,0.01,1,0.5);


		if (world.collideWithLevel (this) || timer < 0) {
			//Hit something
			var bombTileX = Math.floor(x/16);
			var bombTileY = Math.floor(y/16);
			for (ex in -2...2){
				for (ey in -2...2){
					var tx = bombTileX+ex;
					var ty = bombTileY+ey;

					
					world.destroyDestructableTile(tx,ty);
				}
			}
			world.updateAllBuffers();
			kill();
		}
	}
}