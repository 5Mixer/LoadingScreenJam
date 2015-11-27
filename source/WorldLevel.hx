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
import msignal.Signal;


class WorldLevel extends TiledMap
{
	//Signal called when an object is being loaded in a tiled map.
	//The string arg is the ''TYPE'' of the object being loaded, in lowercase.
	//The second arg contains data about the Tiled object, eg the x and y.
	//TODO: Make mining sub state more generalised. How should NPC's in missions be handled?
	var sigLoadTiledObject = new Signal2<TiledObject,PlayState>();

	public var foregroundTileMap:FlxTypedGroup<FlxTilemap>; //Layer that contains foreground, collidable objects. Undestroyable.
	public var backgroundTiles:FlxTypedGroup<FlxTilemap>; //Layer with background objects, no collisions, undestroyable.
	public var destructableTilemaps:FlxTilemap; //Editable layer, collisions on, and destruction on.
	
	public var allTilemaps:FlxTypedGroup<FlxTilemap>; //Every layer
	private var collidableTileLayers:Array<FlxTilemap> = new Array<FlxTilemap>(); //Foreground and playerEditable layers
	private var deadlyTileLayers:Array<FlxTilemap> = new Array<FlxTilemap>(); //Foreground and playerEditable layers

	public function new(tiledLevel:Dynamic)
	{
		super(tiledLevel);


		//Setup default behaviour for loading Tiled objects.

		sigLoadTiledObject.add(function (tiledObject,state){
			if (tiledObject.type.toLowerCase() == 'abc'){
			}
		});

		//Initialise the different Tiled map groups.
		foregroundTileMap = new FlxTypedGroup<FlxTilemap>();
		backgroundTiles = new FlxTypedGroup<FlxTilemap>();
		allTilemaps = new FlxTypedGroup<FlxTilemap>();

		destructableTilemaps = new FlxTilemap();

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
			

			//Decide what type of layer it is.
			var hasCollisions = tileLayer.properties.contains("collisions");
			var isDestructable = tileLayer.properties.contains("destructable");
			var deadly = tileLayer.properties.contains("Deadly");

			allTilemaps.add(tilemap);

			if (hasCollisions)
			{
				collidableTileLayers.push (tilemap);
			}

			if (isDestructable) {
				destructableTilemaps = tilemap;
			}

			if (deadly){
				deadlyTileLayers.push(tilemap);
			}

			if (!hasCollisions && !isDestructable){
				backgroundTiles.add(tilemap);
			}
		}
	}

	public function loadObjects(state:PlayState)
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

	private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState)
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

	public function checkForDeaths(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (deadlyTileLayers != null)
		{
			for (map in deadlyTileLayers)
			{
				// IMPORTANT: Always collide the map with objects, not the other way around.
				//			  This prevents odd collision errors (collision separation code off by 1 px).
				return FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
			}
		}
		return false;
	}


	

	public function updateAllBuffers () {
		for (l in allTilemaps){
			l.updateBuffers();
		}
	}
}