package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxMath;

import hxColorToolkit.*; //Lol worst code ever
using hxColorToolkit.ColorToolkit;


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
	var player:Player;

	public var bombs = new FlxGroup();
	public var aimNodes = new FlxTypedGroup<AimNode>();

	public var activeLevel:WorldLevel;

	var foreground:FlxSprite;
	var background:FlxSprite;

	var loadingBar:LoadingBar;
	var foregroundHSLColor:hxColorToolkit.spaces.HSL;
	var backgroundHSLColor:hxColorToolkit.spaces.HSL;

	var level:Int = 0;

	var runtime:Float = 0;

	override public function create():Void
	{
		super.create();

		backgroundHSLColor = new hxColorToolkit.spaces.HSL(Math.floor(Math.random()*360), 100, 50); //construct a color in HSL space
		foregroundHSLColor = backgroundHSLColor;
		foregroundHSLColor.hue += 60;

		background = new FlxSprite (0,0);
		background.scrollFactor.set();
		background.color = backgroundHSLColor.getColor(); //0xFF0000 the hex color value;
		background.scale.set(2,2);
		background.loadGraphic("assets/images/Background_Background.png");

		foreground=new FlxSprite(0,50);
		foreground.scrollFactor.set(0.85,0.1);
		foreground.color = foregroundHSLColor.getColor();
		foreground.loadGraphic("assets/images/Background_Foreground.png");
		foreground.scale.set(2,2);

		add(background);
		add(foreground);

		loadingBar =  new LoadingBar(0,0,this);

		
		activeLevel = new WorldLevel("assets/levels/"+level+".tmx");
		add(activeLevel.allTilemaps);


		
		add(loadingBar);


		add(bombs);

		add(aimNodes);
		FlxG.camera.follow(player);

		resetWorld();

	}


	public function resetWorld () {
		aimNodes.clear();

		foregroundHSLColor = new hxColorToolkit.spaces.HSL(Math.floor(Math.random()*360), 60, 10+Math.floor(Math.random()*35));
		foreground.color = foregroundHSLColor.getColor();

		backgroundHSLColor = foregroundHSLColor;
		backgroundHSLColor.hue += 60;
		backgroundHSLColor.lightness += 10;
		background.color = backgroundHSLColor.getColor();

		
		if (mode == PlayMode.running) startRunMode(foregroundHSLColor);
		if (mode == PlayMode.shooting) startShootingMode();
	}

	function startRunMode (hslColor:hxColorToolkit.spaces.HSL) {
		runtime = 0;

		player = new Player (40,40,this);
		loadingBar.setProgressValue(0);
		if (loadingBar.tween != null )loadingBar.tween.cancel();
		FlxG.camera.follow(player,0);

		if (hslColor.lightness > 55){
			player.color = hxColorToolkit.CssColor.Black;
		}else{
			player.color = hxColorToolkit.CssColor.White;
		}



		add(player);

	}

	function updateRunMode () {
		runtime += FlxG.elapsed;

		foregroundHSLColor.hue += FlxG.elapsed*14;
		foreground.color = foregroundHSLColor.getColor();

		backgroundHSLColor = foregroundHSLColor.clone();
		backgroundHSLColor.hue += 60;
		backgroundHSLColor.lightness += 10;
		background.color = backgroundHSLColor.getColor();		

		if (activeLevel.checkForNewLevel(player)){
			newLevel();
		}

		if (FlxG.keys.justPressed.R){
			newLevel();
		}
	}

	public function newLevel(){
		if (level == 2){
			FlxG.switchState(new WinState());
			return;
		}

		level++;
		


		if (activeLevel != null)
			for (map in activeLevel.allTilemaps)
				map.kill();

		activeLevel=null;

		activeLevel = new WorldLevel("assets/levels/"+level+".tmx");
		add(activeLevel.allTilemaps);

		player.destroy();
		player = new Player (40,40,this);
		add(player);
		FlxG.camera.follow(player);

		
	}

	function updateShootMode () {
		loadingBar.load((FlxG.elapsed )/5);

		aimNodes.clear();

		var dummyNode = new AimNode(player.x,player.y,this);
		dummyNode.velocity.x = (FlxG.mouse.x - player.x)*10;
		dummyNode.velocity.y = (FlxG.mouse.y - player.y)*10;
		for (i in 1...6){
			if (dummyNode.move(40) == false) break;
			aimNodes.add(new AimNode(dummyNode.x,dummyNode.y,this));
		}

		if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed){
			var bomb = new Bomb(player.x,player.y,this);
			bomb.velocity.x = (FlxG.mouse.x - player.x)*2;
			bomb.velocity.y = (FlxG.mouse.y - player.y)*2;
			bombs.add(bomb.exhaustParticles);
			bombs.add(bomb);

			loadingBar.load((Math.random()*20)/100);
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
