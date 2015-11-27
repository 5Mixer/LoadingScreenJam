package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

enum PlayMode {
	running;
	shooting;
}

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{

	var mode:PlayMode = PlayMode.running;
	var testLevel:WorldLevel;
	var player:Player;

	override public function create():Void
	{
		super.create();

		testLevel = new WorldLevel("assets/levels/TestLevel.tmx");
		add(testLevel.allTilemaps);

		player = new Player (40,40,testLevel);
		FlxG.camera.follow(player);
		add(player);

		
		FlxG.camera.zoom *= 5;
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();

	}
}