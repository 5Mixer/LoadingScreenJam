package ;

import openfl.Assets;
import haxe.io.Path;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;
import states.MiningSubState;
import msignal.Signal;


class WorldLevel extends TiledMap
{
	//Signal called when an object is being loaded in a tiled map.
	//The string arg is the ''TYPE'' of the object being loaded, in lowercase.
	//The second arg contains data about the Tiled object, eg the x and y.
	//TODO: Make mining sub state more generalised. How should NPC's in missions be handled?
	var sigLoadTiledObject = new Signal2<TiledObject,states.MiningSubState>();

	// Array of tilemaps used for collision
	public var foregroundTileMap:FlxTilemap;
	public var lavaTileMap:FlxTilemap;
	public var backgroundTiles:FlxTypedGroup<FlxTilemap>;
	public var allTilemaps:FlxTypedGroup<FlxTilemap>;
	public var wallTiles:FlxTypedGroup<FlxTilemap>;
	private var collidableTileLayers:Array<FlxTilemap>;


	public var playerEditableTilemap:FlxTilemap;

	private var playerReference:entities.Player;

	//Mining stuff
	private var timerCountUp:Float = 0;
	private var miningTime:Float = 0.6;

	public var lightMap:FlxTilemap;

	public function new(tiledLevel:Dynamic, player:entities.Player)
	{
		super(tiledLevel);

		playerReference = player;

		//Setup default behaviour for loading Tiled objects.

		sigLoadTiledObject.add(function (tiledObject,state){
			if (tiledObject.type.toLowerCase() == 'astronaut'){
				state.NPCAstronauts.add(new entities.Astronaut(tiledObject.x,tiledObject.y));
			}
		});

		//Initialise the different Tiled map groups.
		wallTiles = new FlxTypedGroup<FlxTilemap>();
		backgroundTiles = new FlxTypedGroup<FlxTilemap>();
		allTilemaps = new FlxTypedGroup<FlxTilemap>();

		lightMap=new FlxTilemap();

		//Limit the cameras movement.
		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);


		// Load Tile Maps
		for (tileLayer in layers)
		{

			var tileSheetName:String = tileLayer.properties.get("tileset");


			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";

			var tileSet:TiledTileSet = null;

			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}

			if (tileSet == null)
				throw "Tileset '" + tileSheetName + " not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";

			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= "assets/images/" + imagePath.file + "." + imagePath.ext;

			var tilemap:FlxTilemap = new FlxTilemap();
			tilemap.auto=FlxTilemap.OFF;

			tilemap.widthInTiles = width;
			tilemap.heightInTiles = height;


			tilemap.loadMap(tileLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);
			allTilemaps.add(tilemap);

			//Decide what type of layer it is.
			if (tileLayer.properties.contains("isWall")){
				wallTiles.add(tilemap);
				backgroundTiles.add(tilemap);
			} else if (tileLayer.properties.contains("nocollide"))
			{
				backgroundTiles.add(tilemap);


			} else if (tileLayer.properties.contains("lava")) {
				lavaTileMap = tilemap;
			} else if (tileLayer.properties.contains("LightMap")) {
				lightMap=(tilemap);
			} else {
				foregroundTileMap=(tilemap);
			}
		}

		//Scale the lightmap
		lightMap.scale.set(16,16);
	}

	public function loadObjects(state:MiningSubState)
	{
		//TODO: Be aware these may be null...


		for (group in objectGroups)
		{

			for (o in group.objects)
			{
				loadObject(o, group, state);

			}
		}
	}

	private function loadObject(o:TiledObject, g:TiledObjectGroup, state:MiningSubState)
	{

		var x:Int = o.x;
		var y:Int = o.y;

		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;

		//Dispatch the signal regarding a Tiled object being loaded.
		sigLoadTiledObject.dispatch(o,state);

		switch (o.type.toLowerCase())
		{

			case "":
				//Do something. Generally, this should be handled by the signal.

		}
	}

	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers != null)
		{
			for (map in collidableTileLayers)
			{
				// IMPORTANT: Always collide the map with objects, not the other way around.
				//			  This prevents odd collision errors (collision separation code off by 1 px).
				return FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
			}
		}
		return false;
	}

	public function mineWithMouse () : Int {

		var id:Int = 0;
		if (FlxG.mouse.pressed){

				if (this.foregroundTileMap.getTile(Std.int(FlxG.mouse.x/16),Std.int(FlxG.mouse.y/16)) != 0
				&& this.foregroundTileMap.getTile(Std.int(FlxG.mouse.x/16),Std.int(FlxG.mouse.y/16)) != 21){
					if (FlxG.mouse.distanceTo(playerReference.getMidpoint()) < 150){

					//They are eligble to mine a block, (over it, in range, and mouse down). Increase timer.
					timerCountUp += FlxG.elapsed;

					if (timerCountUp > miningTime){

						id=foregroundTileMap.getTile(Std.int(FlxG.mouse.x/16),Std.int(FlxG.mouse.y/16));
						foregroundTileMap.setTile(Std.int(FlxG.mouse.x/16),Std.int(FlxG.mouse.y/16),0);

						findWalls();

						timerCountUp=0; //They are mined the block, restart their wait.
					}
				}else{
					timerCountUp = 0;
				}
			}else{
				timerCountUp = 0;
			}
		}else{
			timerCountUp = 0;
		}
		return id; //return the type of block that was mined. 0 if nothing was mined
	}


	public function findWalls () {
		for (x in 0...foregroundTileMap.widthInTiles){
			for (y in 0...foregroundTileMap.heightInTiles){

				if (foregroundTileMap.getTile(x,y) != 0 &&  foregroundTileMap.getTile(x,y+1) == 0){

					wallTiles.members[0].setTile(x,y+1,11,true);

				}else{
					wallTiles.members[0].setTile(x,y+1,0,true);
				}
			}
		}
	}

	public function updateAllBuffers () {
		for (l in allTilemaps){
			l.updateBuffers();
		}
	}


	var coveredPoints:Array<LightNode> = new Array<LightNode>();
	var toBeCheckedPoints:Array<LightNode> = new Array<LightNode>();
	public function floodFill (it:Int){


		clear(coveredPoints);
		clear(toBeCheckedPoints);

		//Make a 2d dimensional array of points that apply to that Array.
		for (x in 0...30){
			for (y in 0...30){
				if (foregroundTileMap.getTile(Std.int(x-playerReference.x),Std.int(y-playerReference.y)) != 20){

					//var light = approx_distance(Std.int(playerReference.x/16-x),Std.int(playerReference.y/16-y));
					var light = approx_distance(Std.int(playerReference.x/16-x),Std.int(playerReference.y/16-y))/1.4;

					if (foregroundTileMap.getTile(x,y) != 0){
							light+=8;
					}else{
					}

					lightMap.setTile(x,y,Std.int(light+1));
				}
			}
		}


	}
	public function containsPoint (array:Array<LightNode>,point:LightNode){
		for (pt in array) if (point.x == pt.x && point.y == pt.y) return true;
		return false;
	}
	public function removePoint  (array:Array<LightNode>,point:LightNode){
		for (pt in array) {
			if (point.x == pt.x && point.y == pt.y)
				array.remove(pt);
				return;
		}
	}

	private function approx_distance(dx, dy )
	{
	   var min, max;

	   if ( dx < 0 ) dx = -dx;
	   if ( dy < 0 ) dy = -dy;

	   if ( dx < dy )
	   {
	      min = dx;
	      max = dy;
	   } else {
	      min = dy;
	      max = dx;
	   }
		//return min;
	   // coefficients equivalent to ( 123/128 * max ) and ( 51/128 * min )
	   return ((( max << 8 ) + ( max << 3 ) - ( max << 4 ) - ( max << 1 ) +
	          ( min << 7 ) - ( min << 5 ) + ( min << 3 ) - ( min << 1 )) >> 8 );
	}

	public inline static function clear(arr:Array<Dynamic>){
       #if (cpp||php)
          arr.splice(0,arr.length);
       	#else
          untyped arr.length = 0;
       #end
   }
}

class LightNode extends FlxPoint{
	public var light:Int = 1;
	public function setLight (l:Int){
		light = l;
		return this;
	}
}
