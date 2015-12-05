package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.group.FlxTypedGroup;
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

	public var bombs = new FlxTypedGroup<Bomb>();

	public var activeLevel:WorldLevel;

	var loadingBar:LoadingBar;

	override public function create():Void
	{
		super.create();

		testLevel = new WorldLevel("assets/levels/TestLevel.tmx");
		add(testLevel.allTilemaps);

		loadingBar =  new LoadingBar(0,0,this);
		add(loadingBar);

		activeLevel = testLevel;

		add(bombs);


		FlxG.camera.follow(player);

		resetWorld();

	}

	public function resetWorld () {
		if (mode == PlayMode.running) startRunMode();
		if (mode == PlayMode.shooting) startShootingMode();
	}

	function startRunMode () {

		player = new Player (40,40,this);
		loadingBar.setProgressValue(0);
		FlxG.camera.follow(player,0);
		add(player);

	}

	function updateRunMode () {

	}
	function updateShootMode () {
		loadingBar.load((FlxG.elapsed )/5);

		if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed){
			var bomb = new Bomb(player.x,player.y,this);
			bomb.velocity.x = FlxG.mouse.x - player.x;
			bomb.velocity.y = FlxG.mouse.y - player.y;
			bombs.add(bomb);
		}

		if (loadingBar.progress > 1){
			player.kill();
			mode = PlayMode.running;
			resetWorld();
		}
	}

	function startShootingMode () {
		//Argh tired need to sleep lol.
		player.active = false;

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
		//Awful code. Not for educational research. Ever.
		if (mode == PlayMode.shooting) {
			updateShootMode();
		}else{
			updateRunMode();
		}

	}
}
