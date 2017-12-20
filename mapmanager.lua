local mapmanager = {}




function mapmanager.loadTiles()
	numTiles = 3
	tiles = {}
	for k=0,numTiles-1 do
		tiles[k] = love.graphics.newImage('assets/tile'..k..'.png')
	end
	
end


function mapmanager.initMap()
	--info for tile maps
	mapNumRows = 16
	mapNumCols = 16
	tileWidth = 40
	tileHeight = 40

	tileMapWidth = mapNumCols * tileWidth
	tileMapHeight = mapNumRows * tileHeight
	
	--table containing all maps
	mapMetaData = {}
	numMaps = 0
	
	--create starting tile map
	mapmanager.openArea(0)
	
end


function mapmanager.getMapIndex(x, y)
--returns the index of the map in the mapMetaData table

	for k=0,numMaps-1 do
		if (x >= mapMetaData[k].mapX and x < mapMetaData[k].mapX + tileMapWidth) and 
		(y >= mapMetaData[k].mapY and y < mapMetaData[k].mapY + tileMapHeight) then
			--print(k)
			return k
		end
	
	end

	
--[[
	--print("Function getMapIndex()")
	--print("x,y: "..x..","..y)

	local adjustedMapX, adjustedMapY
	local finalKey
	
	--adjust x value for key generation
	if(x < 0) then
		adjustedMapX =  x - (x % 640)
	else
		adjustedMapX = x - (x % 640)
	end
	
	--adjust y value for key generation
	if(y < 0) then
		adjustedMapY = y - (y % 640)
	else
		adjustedMapY = y - (y % 640)
	end
	
	--print("adjusted values x,y: "..adjustedMapX..","..adjustedMapY)
	
	--combine the keys to get final key
	finalKey = mapmanager.generateMapKey(adjustedMapX, adjustedMapY)
	
	--print("final key: "..finalKey)
	
	return finalKey
--]]	
	--invalid index when not found
	print(-1)
	return -1
	
end


function mapmanager.getTileIndexes(x, y)
	
	local row = -1
	local col = -1
	
	--the index of the map in mapMetaData
	local mapIndex = mapmanager.getMapIndex(x,y)
		
	--check if the map area exists
	local outofbounds = mapmanager.mapIndexOutOfBounds(mapIndex)

	if(not outofbounds) then
		
		local thisMapX = mapMetaData[mapIndex].mapX
		local thisMapY = mapMetaData[mapIndex].mapY

		row = math.floor( (y - thisMapY)/tileHeight ) + 1
		col = math.floor( (x - thisMapX)/tileWidth ) + 1
	
	end
	
	--print(row..","..col)
	return row, col
	
end


function mapmanager.getTileGlobalPosition(mapIndex, row, col)
--return the x,y position of a tile in the global coordinate scheme...

	local xpos = mapMetaData[mapIndex].mapX + (col - 1) * tileWidth
	local ypos = mapMetaData[mapIndex].mapY + (row - 1) * tileHeight
	
	return xpos, ypos

end


function mapmanager.setTile(map, row, col, newTile)
--map parameter is an integer specifying the index of the map in mapMetaData
--row, col parameters are relative to the map
--newTile paramater is an integer specific to the desired tile

	mapMetaData[map].tileMap[row][col] = newTile

end


function mapmanager.openArea(index)


	--this is for the initial map setup
	if(index == 0) then
		mapMetaData[0] = {}
		numMaps = numMaps + 1
		mapMetaData[0].mapX = 0
		mapMetaData[0].mapY = 0
	end

	--open the map and change tiles to the default editable tiles
	mapMetaData[index].state = "open"
	mapMetaData[index].tileMap = 
	{
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	}
	
	--create closed areas
	local thisMapX = mapMetaData[index].mapX
	local thisMapY = mapMetaData[index].mapY
	--check 'border' areas that surround the newly openned areas
	for y=-tileMapHeight, tileMapHeight, tileMapHeight do
		for x=-tileMapWidth, tileMapWidth, tileMapWidth do
			
			--find whether or not a map exists in the table already
			local exists = false
			--[[
			local newMapKey = mapmanager.generateMapKey(x,y)
			if(mapMetaData[newMapKey] ~= nil) then
				exists = true
			else
				exists = false
			end
			--]]
			
			for k=0, numMaps-1 do
				if( (x+thisMapX == mapMetaData[k].mapX) and (y+thisMapY == mapMetaData[k].mapY) ) then
					exists = true
				end
			end
			
			--add a new map if one does not exist
			if(exists == false) then
				local newMapIndex = numMaps
				mapMetaData[newMapIndex] = {}
				numMaps = numMaps + 1
				
				mapMetaData[newMapIndex].mapX = x + thisMapX
				mapMetaData[newMapIndex].mapY = y + thisMapY
				mapMetaData[newMapIndex].state = "closed"
				mapMetaData[newMapIndex].tileMap = 
				{
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				}
				
				--print("I made a map at index:"..newMapKey)
				--print("This map's x,y is: "..mapMetaData[newMapKey].mapX..","..mapMetaData[newMapKey].mapY)
			end
		
		end
	end

	
end


function mapmanager.isPathable(mapIndex, row, col)
--currently based on the tilemap
--making a different 'collisionmap' or something may simplify things in the long run

	--HOW ABOUT U THINK ABOUT A BETTER WAY TO CHECK...MAKE A LIST OR SOMETHING? derp
	if(mapMetaData[mapIndex].tileMap[row][col] == 2 ) then
		--print("false")
		return false
	elseif(mapMetaData[mapIndex].tileMap[row][col] == 0) then
		--print("false")
		return false
	else
		--print("true")
		return true
	end
	
end


function mapmanager.generateMapKey(mapx, mapy)
--we assume a max of 15 maps in the positive x/y direction
--we assume a max of 15 maps in the negative x/y direction
--so, -15 to 15 is 30 maps in 1 direction
--total number of maps is therefore: 30*30 = 900...wow
--a negative x/y key value is identified by appending 5 to the front of the key value
--mapx, mapy will be multiples of 640 (16 tiles * 40 pixels)

	--should add checks for stopping more than 15 maps...?
	--maybe here, maybe somewhere else~

	local xkey, ykey
	local finalKey
	
	--convert mapx into part of the key
	--the plan: mapx / 10 * 10000
	if(mapx < 0) then
		xkey = 50000000 + math.abs( mapx * 1000 ) 
	else
		xkey = mapx * 1000
	end

	--convert mapy into part of the key
	if(mapy < 0) then
		ykey = 5000 + math.abs( mapy / 10 )
	else
		ykey = mapy / 10
	end
	
	finalKey = xkey + ykey

	return finalKey

end


function mapmanager.mapIndexOutOfBounds(mapindex)
--checks if you're out of bounds
--pretty much the map area doesn't exist

	if( mapindex ~= -1 ) then
		return false
	else
		return true
	end

end

return mapmanager