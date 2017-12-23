local mapmanagermodule = require("mapmanager")
local cameramodule = require ("camera")
local statemanagermodule = require("statemanager")
local entitymanagermodule = require("entitymanager")

function love.load()
	screenHeight = love.graphics.getHeight()
	screenWidth = love.graphics.getWidth()
	
	--instructions image
	instructions = love.graphics.newImage('assets/instructions.png')
	
	--goblin image
	gobjii = love.graphics.newImage('assets/goblin_old.png')
	gobjiiQuestion = love.graphics.newImage('assets/goblin_old_confused.png')
	
	--bag of gold image
	goldBag = love.graphics.newImage('assets/bagofgold.png')
	
	--load tiles
	mapmanagermodule.loadTiles()

	--create starting maps
	mapmanagermodule.initMap()
	
	--setup camera
	cameramodule.initCamera()
	
	--setup entities
	entitymanagermodule.initEntities()
	
	--fps counter
	fps = 0
	frames = 0
	lastFrameTime = love.timer.getTime()
	
	--font
	default = love.graphics.newFont(12)
	love.graphics.setFont(default)
	
	--state stuff
	statemanagermodule.initStates()
	
	--mouse cursors
	cursorHammer = love.mouse.newCursor('assets/hammer.png', 0, 27)
	cursorWater = love.mouse.newCursor('assets/water.png', 0, 0)
	cursorGold = love.mouse.newCursor('assets/bogcursor.png', 0, 0)
	
	--test
	--thereisapath = false
	
end


function love.update(dt)
	--record fps
	currentTime = love.timer.getTime()
	if currentTime - lastFrameTime > 1 then
		fps = frames
		lastFrameTime = currentTime
		frames = 0
	else
		frames = frames + 1
	end
	
	--quit with esc
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	--camera movement
	if love.keyboard.isDown('up','w') then
		cameramodule.move(0, -dt)
	end
	if love.keyboard.isDown('down','s') then
		cameramodule.move(0, dt)
	end
	if love.keyboard.isDown('left','a') then
		cameramodule.move(-dt, 0)
	end
	if love.keyboard.isDown('right','d') then
		cameramodule.move(dt, 0)
	end
	
	--mouse adjustment due to camera
	adjustedX = cameramodule.adjustMouseX(love.mouse.getX())
	adjustedY = cameramodule.adjustMouseY(love.mouse.getY())
	
	--testing state changes with number keys 0-9 (it's temporary, i swear!)
	--testing tile editing
	if love.keyboard.isDown('1') then
		statemanagermodule.setState("editingTile")
		love.mouse.setCursor(cursorWater)
	end
	
	--testing open new areas
	if love.keyboard.isDown('2') then
		statemanagermodule.setState("openningArea")
		love.mouse.setCursor(cursorHammer)
	end
	
	--place a bag of gold
	if love.keyboard.isDown('3') then
		statemanagermodule.setState("placingGold")
		love.mouse.setCursor(cursorGold)
	end
	
	
	--testing global position calculation
	if love.keyboard.isDown('0') then
		statemanagermodule.setState("testtest")
	end
	
	--testing my AI
	for k=0,numEntities-1 do
		if (entities[k].eType == "goblin") then
			entitymanagermodule.AI(entities[k], dt)
		end
	end
	
	
end


function love.draw(dt)
	--things affected by camera movement
	cameramodule.activate()

	
	--draw the tile maps
	--[[
	for z,lemap in ipairs(mapMetaData),mapMetaData,-1 do
		--IF THE TILEMAP IS ON THE SCREEN, DRAW IT << add this check in to reduce draws
		for k=1,mapNumRows do
			for j=1,mapNumCols do
				love.graphics.draw(tiles[lemap.tileMap[k][j] ], lemap.mapX+(j-1)*tileWidth, lemap.mapY+(k-1)*tileHeight)
				--love.graphics.draw(tiles[tileMap[k][j] ], mapX+(j-1)*tileWidth-(k-1)*offsetX, mapY+(k-1)*tileHeight)
			end
		end
	
	end--]]
	
	
	for z,lemap in pairs(mapMetaData) do
		--IF THE TILEMAP IS ON THE SCREEN, DRAW IT << add this check in to reduce draws
		for k=1,mapNumRows do
			for j=1,mapNumCols do
				love.graphics.draw(tiles[lemap.tileMap[k][j]], lemap.mapX+(j-1)*tileWidth, lemap.mapY+(k-1)*tileHeight)
				--love.graphics.draw(tiles[tileMap[k][j]], mapX+(j-1)*tileWidth-(k-1)*offsetX, mapY+(k-1)*tileHeight)
			end
		end
	
	end
	
	
	--draw entities
	for q=0,numEntities-1 do
		--...as goblins
		if (entities[q].eType == "goblin") then
			if(entities[q].confused == true) then
				love.graphics.draw(gobjiiQuestion, entities[q].x, entities[q].y)
			else			
				love.graphics.draw(gobjii, entities[q].x, entities[q].y)
			end
		end
	end
	
	
	--draw bag of gold...if it was placed
	if (bog ~= nil) then
		love.graphics.draw(goldBag, bog.x, bog.y, 0, 0.8)
	end
	
	
	cameramodule.deactivate()

	
	--things relative to your screen
	
	--fps
	love.graphics.print(fps, screenWidth - 50, 0)
	
	--instructions
	love.graphics.draw(instructions, 0, screenHeight - 100)
	
end


function love.mousereleased(x, y, button, istouch)

	
	--get the correct map and tile of that  map
	local mapIndex = mapmanagermodule.getMapIndex(adjustedX, adjustedY)
	local mapRow, mapCol = mapmanagermodule.getTileIndexes(adjustedX, adjustedY)
	
	if(button == 1) then
		--change the tile to WATUR
		if(statemanagermodule.getState() == "editingTile") then
			if(mapMetaData[mapIndex].state == "open") then
				mapmanagermodule.setTile(mapIndex, mapRow, mapCol, 2)
			end
		end
		
		--open new area
		if(statemanagermodule.getState() == "openningArea") then
			if(mapMetaData[mapIndex].state == "closed") then
				mapmanagermodule.openArea(mapIndex)
			end
		end
		
		--place down a bag of gold
		if (statemanagermodule.getState() == "placingGold") then
			entitymanagermodule.placeGold(adjustedX, adjustedY)
		end
		
		
		--testing area
		if(statemanagermodule.getState() == "testtest" ) then
			--if(mapMetaData[mapIndex].state == "open") then
				mapmanagermodule.isPathable(mapIndex, mapRow, mapCol)
			--end
		end
		
		
	end
	

end