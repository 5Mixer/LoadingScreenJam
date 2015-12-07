package ;

import flixel.FlxSprite;
import flixel.FlxG;

class LoadingBar extends FlxSprite {
	var world:WorldLevel;
	var state:PlayState;

	public var progress:Float=0;
	public var tween:flixel.tweens.FlxTween;

	public function new (X:Int,Y:Int,_state:PlayState){
		super(X,Y);

		world = _state.activeLevel;

		state=_state;

		scrollFactor.set();

		makeGraphic(FlxG.width,32,flixel.util.FlxColor.RED);
		origin.set(0,0);
		width = 0;
	}

	public function setProgressValue (value:Float) {
		progress = value;
		//width = Std.int(FlxG.width * (value/100));
		scale.x = value;
	}
	public function load (amount:Float){
		var newProgress = progress + amount;
		var start = progress;

		if (amount < 0.02){
			setProgressValue(progress + amount);
		}else{
			tween = flixel.tweens.FlxTween.num(start,newProgress,amount,null,setProgressValue);
		}
	}




	override public function update (){
		super.update();
	}
}

