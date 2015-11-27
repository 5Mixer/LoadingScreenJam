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

	public var mode:PlayMode = PlayMode.running;
	var testLevel:WorldLevel;
	var player:Player;

	public var activeLevel:WorldLevel;

	override public function create():Void
	{
		super.create();
		FlxG.camera.zoom = 5;

		testLevel = new WorldLevel("assets/levels/TestLevel.tmx");
		add(testLevel.allTilemaps);

		activeLevel = testLevel;

		resetWorld();
		
	}

	public function resetWorld () {
		if (mode == PlayMode.running) startRunMode();
		if (mode == PlayMode.shooting) startShootingMode();
	}

	function startRunMode () {
		player = new Player (40,40,this);
		FlxG.camera.follow(player);
		add(player);
	}

	function startShootingMode () {
		//Argh tired need to sleep lol.
		player.kill();
		
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