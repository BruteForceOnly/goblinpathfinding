local statemanager = {}




function statemanager.initStates()
	currentState = ""
	print("I did some initializing le states boss!")
end


function statemanager.setState(state)
	print("I make state to "..state)
	currentState = state
end


function statemanager.getState()
	return currentState
end




return statemanager