local mapmanagermodule = require("mapmanager")

local entitymanager = {}




function entitymanager.initEntities()
	numEntities = 0


	print("mud")
	entities = {}
	
	for k=0,0 do
		--make some jameses (goblins)
		local james = {}
		james.x = k * 100 + 100
		james.y = k * 100 + 100
		james.width = 50
		james.height = 50
		james.speed = 40
		james.path = {}
		james.pathUpdateRequired = false
		james.eType = "goblin"
		
		entities[numEntities] = james
		numEntities = numEntities + 1
	end
	
	print("horse")
	
	--the bag of gold
	--there is always only one
	bog = nil

end


function entitymanager.AI(entity, dt)
--currently it just moves towards my mouse
--adjustedX and adjustedY are global and located in main() btw

	local currentTime = love.timer.getTime()
	--print("Mouse location: "..adjustedX..","..adjustedY)

	
	--if(currentTime - entity.lastUpdate > 10) then
		--entity.pathUpdateRequired = true
	--end
	
	
	--if a bag of gold exists
	if (bog ~= nil) then
	
		if(entity.pathUpdateRequired == true) then
			local testTime1 = love.timer.getTime()
			entitymanager.findPath(bog.x, bog.y, entity)
			local testTime2 = love.timer.getTime()
			print("finding path time is:"..testTime2-testTime1)
			
			--thereisapath = true
			for u,menodes in ipairs(entity.path) do
				print(entity.path[u].id)
			end
			
		end
		if(entity.path ~= nil) then
			entitymanager.followPath(entity, dt)
		end
	
	end
	
	
end


function entitymanager.xMovementIsPathable(newX, startingY, entity)
--for movement to adjacent cells only!
--return true/false for whether the change in an entity's x direction is possible
--based on whether they need to step over any unpathable tiles or not
	
	local targetPointX = newX
	local targetPointY = startingY
	
	local mapIndexTarget = mapmanagermodule.getMapIndex(targetPointX, targetPointY)
	local mapRowTarget, mapColTarget = mapmanagermodule.getTileIndexes(targetPointX, targetPointY)
	--check top corner
	if(mapmanagermodule.isPathable(mapIndexTarget, mapRowTarget, mapColTarget) ) then
		local middleCellsPathable = true
		--check cells between the top and bottom of image
		while(targetPointY < startingY + entity.height) do
			
			mapIndexTarget = mapmanagermodule.getMapIndex(targetPointX, targetPointY)
			mapRowTarget, mapColTarget = mapmanagermodule.getTileIndexes(targetPointX, targetPointY)
			if( mapmanagermodule.isPathable(mapIndexTarget, mapRowTarget, mapColTarget) == false ) then
				middleCellsPathable = false
				break
			end
			targetPointY = targetPointY + tileHeight
			
		end
		targetPointY = startingY + entity.height
		mapIndexTarget = mapmanagermodule.getMapIndex(targetPointX, targetPointY)
		mapRowTarget, mapColTarget = mapmanagermodule.getTileIndexes(targetPointX, targetPointY)
		--check bottom corner
		if(mapmanagermodule.isPathable(mapIndexTarget, mapRowTarget, mapColTarget) ) then
			if(middleCellsPathable) then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end

end


function entitymanager.yMovementIsPathable(newY, startingX, entity)
--for movement to adjacent cells only!
--return true/false for whether the change in an entity's y direction is possible
--based on whether they need to step over any unpathable tiles or not
	
	local targetPointY = newY
	local targetPointX = startingX
	
	local mapIndexTarget = mapmanagermodule.getMapIndex(targetPointX, targetPointY)
	local mapRowTarget, mapColTarget = mapmanagermodule.getTileIndexes(targetPointX, targetPointY)
	--check left corner
	if(mapmanagermodule.isPathable(mapIndexTarget, mapRowTarget, mapColTarget) ) then
		local middleCellsPathable = true
		--check cells between the left and right of image
		while(targetPointX < startingX + entity.width) do
			
			mapIndexTarget = mapmanagermodule.getMapIndex(targetPointX, targetPointY)
			mapRowTarget, mapColTarget = mapmanagermodule.getTileIndexes(targetPointX, targetPointY)
			if( mapmanagermodule.isPathable(mapIndexTarget, mapRowTarget, mapColTarget) == false ) then
				middleCellsPathable = false
				break
			end
			targetPointX = targetPointX + tileWidth
			
		end
		targetPointX = startingX + entity.width
		mapIndexTarget = mapmanagermodule.getMapIndex(targetPointX, targetPointY)
		mapRowTarget, mapColTarget = mapmanagermodule.getTileIndexes(targetPointX, targetPointY)
		--check right corner
		if(mapmanagermodule.isPathable(mapIndexTarget, mapRowTarget, mapColTarget) ) then
			if(middleCellsPathable) then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end

end


function entitymanager.creep(targetX, targetY, entity, dt)
--slowly creep towards the targetX and targetY
--print("Trying to creep now...")
	--positive is right/down, negative is left/up
	--why don't you make a class for constants later...idiot
	local xdirection = 0
	local ydirection = 0

	--if it's close enough, then just set it to the target value
	if( math.abs(entity.x-targetX) < 1 ) then
		entity.x = targetX
	end
	if( math.abs(entity.y-targetY) < 1 ) then
		entity.y = targetY
	end	
	
	--determine x direction
	if(entity.x > targetX) then
		xdirection = -1
	elseif(entity.x < targetX) then
		xdirection = 1
	end
	--determine y direction
	if(entity.y > targetY) then
		ydirection = -1
	elseif(entity.y < targetY) then
		ydirection = 1
	end

	--check if you're not creeping anywhere
	--[[if(xdirection == 0 and ydirection == 0) then
		print("i should be removing from my path...")
		table.remove(entity.path, 1)
		return
	end	--]]
	
	local targetPointX = entity.x
	local targetPointY = entity.y
	
	
	--determine x target
	if(xdirection == -1) then
		targetPointX = entity.x + xdirection * entity.speed * dt
	elseif(xdirection == 1) then
		targetPointX = entity.x + entity.width + xdirection * entity.speed * dt
	end
	--check x target is pathable
	if( entitymanager.xMovementIsPathable(targetPointX, entity.y, entity) == true ) then
		entity.x = entity.x + xdirection * entity.speed * dt
	else
		entity.pathUpdateRequired = true
	end

	--determine y target
	if(ydirection == -1) then
		targetPointY = entity.y + ydirection * entity.speed * dt
	elseif(ydirection == 1) then
		targetPointY = entity.y + entity.height + ydirection * entity.speed * dt
	end
	--check y target is pathable
	if( entitymanager.yMovementIsPathable(targetPointY, entity.x, entity) == true ) then
		entity.y = entity.y + ydirection * entity.speed * dt
	else
		entity.pathUpdateRequired = true
	end

	
end


function entitymanager.findPath(locationX, locationY, entity)
--find a path to the location
--create a sequence of integers for the route representing: mapindex, row, col
--store this in an entity's path{}

	print("trying to find new path")
	--this is for removing all old path nodes?
	for p in pairs(entity.path) do
		entity.path[p] = nil
	end
	entity.lastUpdate = love.timer.getTime()
	
	--starting location
	local startX = entity.x
	local startY = entity.y
	local endX = locationX
	local endY = locationY
	
	print("the starting x,y are:"..startX..","..startY)
	
	--flag to tell when to stop
	local endSearch = false

	--the cells which have already been included in some path
	--each cell is represented by: row, col, mapindex, parent (for path reconstruction)
	local usedNodes = {}
	local numUsedNodes = 0
	
	--the cells which are the current frontier nodes
	--each cell is represented by: row, col, mapindex
	--should be used as a queue structure
	local frontierNodes = {}
	local numFrontierNodes = 0
	
	--setup starting node
	local nMap = mapmanagermodule.getMapIndex(startX, startY)
	local nRow, nCol = mapmanagermodule.getTileIndexes(startX, startY)
	
	print("starting node's map, row, col:"..nMap..","..nRow..","..nCol)
	
	local sNode = {}
	numUsedNodes = numUsedNodes + 1	
	numFrontierNodes = numFrontierNodes + 1
	--a node's id should also be its position in the usedNodes table
	--so, REMEMBER to INCREMENT numUsedNodes BEFORE assigning a node's id
	--sNode.id = numUsedNodes
	sNode.id = 10000*nMap + 100*nRow + nCol
	sNode.mapIndex = nMap
	sNode.row = nRow
	sNode.col = nCol
	--no node has id zero so this is as good as having no parent
	sNode.parentid = 0
	
	--table.insert(usedNodes, sNode)
	usedNodes[sNode.id] = sNode
	
	table.insert(frontierNodes, sNode)
	
	
	--map info for the destination node
	dNodeMap = mapmanagermodule.getMapIndex(endX, endY)
	dNodeRow, dNodeCol = mapmanagermodule.getTileIndexes(endX, endY)
	
	local destinationNodeFound = false
	local counter = 1
	
	--because of the starting node
	local numNewFrontierNodes = 1
	
	while(numFrontierNodes > 0 and destinationNodeFound == false) do
		
		print("iteration: "..counter)
		
		
		
		local numOldFrontierNodes = numNewFrontierNodes
		numNewFrontierNodes = 0
		
		--print()
		
		
		
		--ADD NEW FRONTIER NODES
		--discontinue a chain if it goes to a closed map
		--discontinue if already used
		
		--for each frontier node
		for f=1,numFrontierNodes do
			local cNode = frontierNodes[f]
			--get the global position of the current node
			 local nodegx, nodegy = mapmanagermodule.getTileGlobalPosition(cNode.mapIndex, cNode.row, cNode.col)
			--print("my global coordinates for this iteration are:"..nodegx..","..nodegy)
			
			--check if it's the destination node
			if(cNode.mapIndex == dNodeMap and cNode.row == dNodeRow and cNode.col == dNodeCol) then
				local currentid = cNode.id
				while(currentid ~= 0) do
					if(usedNodes[currentid].parentid == 0) then
						pathdone = true
					end
					table.insert(entity.path, 1, usedNodes[currentid])
					currentid = usedNodes[currentid].parentid
				end
				
				destinationNodeFound = true
				entity.pathUpdateRequired = false
				break
			end
			
			
			--check cells around the current cell
			for colshift=-1,1,1 do
				for rowshift=-1,1,1 do
					--get an adjacent cell's x,y
					borderCellX = nodegx + colshift * tileWidth
					borderCellY = nodegy + rowshift * tileHeight
					
					--check that the node is pathable
					local xmovegood,ymovegood
					local xdiagmovegood, ydiagmovegood
					local targetCheckX, targetCheckY
					
					--x direction check
					if(colshift == 0) then
						xmovegood = true
					elseif(colshift == -1) then
						targetCheckX = borderCellX
						xmovegood = entitymanager.xMovementIsPathable(targetCheckX, nodegy, entity)
					elseif(colshift == 1) then
						targetCheckX = borderCellX + entity.width
						xmovegood = entitymanager.xMovementIsPathable(targetCheckX, nodegy, entity)
					end
					
					--y direction check
					if(rowshift == 0) then
						ymovegood = true
					elseif(rowshift == -1) then
						targetCheckY = borderCellY
						ymovegood = entitymanager.yMovementIsPathable(targetCheckY, nodegx, entity)
					elseif(rowshift == 1) then
						targetCheckY = borderCellY + entity.height
						ymovegood = entitymanager.yMovementIsPathable(targetCheckY, nodegx, entity)
					end
					
					--do diagonal checks
					if(rowshift ~= 0 and colshift ~=0) then
						xdiagmovegood = entitymanager.xMovementIsPathable(targetCheckX, targetCheckY, entity)
						ydiagmovegood = entitymanager.yMovementIsPathable(targetCheckY, targetCheckX, entity)
					else
						xdiagmovegood = true
						ydiagmovegood = true
					end
					
					
					if(xmovegood and ymovegood and xdiagmovegood and ydiagmovegood) then
						--get necessary map cell info
						nMap = mapmanagermodule.getMapIndex(borderCellX, borderCellY)
						nRow, nCol = mapmanagermodule.getTileIndexes(borderCellX, borderCellY)
					
						--check that the node hasn't already been used
						local alreadyUsed
						
						local myKey = 10000*nMap + 100*nRow + nCol
						if(usedNodes[myKey] == nil) then
							alreadyUsed = false
						elseif(usedNodes[myKey].id == myKey) then
							alreadyUsed = true
						end
						

						if(not alreadyUsed) then
							--create the node
							local newNode = {}
							numUsedNodes = numUsedNodes +  1
							--newNode.id = numUsedNodes
							newNode.id = myKey
							newNode.mapIndex = nMap
							newNode.row = nRow
							newNode.col = nCol
							newNode.parentid = cNode.id
						
							--add to frontier
							table.insert(frontierNodes, newNode)
							--numNewFrontierNodes = numNewFrontierNodes + 1
							numNewFrontierNodes = numNewFrontierNodes + 1
							numFrontierNodes = numFrontierNodes + 1
							--add to used
							--table.insert(usedNodes, newNode)
							usedNodes[myKey] = newNode
							
						end
					end
					
				end
			end
			
		
		end
		
		--numFrontierNodes = numFrontierNodes + numNewFrontierNodes
		
		--DELETE OLD FRONTIER NODES
		for k=1,numOldFrontierNodes do
			--print("about to remove a node")
			table.remove(frontierNodes, 1)
			--print("removed.")
			numFrontierNodes = numFrontierNodes - 1
		end
		
		
		
		
	
		counter = counter + 1
	end
	


end


function entitymanager.followPath(entity, dt)
--print("trying to follow path rn...")

	--print(entity.x..","..entity.y)

	if(entity.path[1] ~= nil) then
		
		local targetMap = entity.path[1].mapIndex
		local targetRow = entity.path[1].row
		local targetCol = entity.path[1].col
		local targetX, targetY = mapmanagermodule.getTileGlobalPosition(targetMap, targetRow, targetCol)

		if(  ( math.abs(targetX - entity.x ) < 1 ) and ( math.abs(targetY - entity.y) < 1 )  ) then
			--print("I'M GONNA REMOVE FROM PATH")
			table.remove(entity.path, 1)
		end
		
		entitymanager.creep(targetX, targetY, entity, dt)
	
	end
	
end


function entitymanager.placeGold(x, y)
--set location for the bag of gold
	
	--place bag of gold on the closest tile
	local index = mapmanagermodule.getMapIndex(x, y)
	local row, col = mapmanagermodule.getTileIndexes(x, y)
	
	--only change position of bag of gold if new location is in a pathable cell
	if(mapmanagermodule.isPathable(index, row, col)) then
		bog = {}
		bog.x, bog.y = mapmanagermodule.getTileGlobalPosition(index, row, col)
		
		--location of gold bag has been changed, so every goblin needs to search for it
		for k=0, numEntities-1 do
			entities[k].pathUpdateRequired = true
		end
	
	end	

end




return entitymanager