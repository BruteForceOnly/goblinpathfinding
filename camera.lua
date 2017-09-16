local camera = {}




function camera.initCamera()
	cameraX = -love.graphics.getWidth()/2
	cameraY = -love.graphics.getHeight()/2
	cameraSpeed = 600
end


function camera.move(dx, dy)
	cameraX = cameraX + dx * cameraSpeed
	cameraY = cameraY + dy * cameraSpeed
end


function camera.activate()
	love.graphics.push()
	
	love.graphics.translate(-cameraX, -cameraY)
end


function camera.deactivate()
	love.graphics.pop()
end


function camera.adjustMouseX(xpos)
--only does translation right now
	return xpos + cameraX
end


function camera.adjustMouseY(ypos)
--only does translation right now
	return ypos + cameraY
end




return camera