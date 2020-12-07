-- this is still a work in progress, you can download it if you want, but it wont produce anything usefull yet
 
--this program will tell the turtle to do pinwheel mining in an effective way with automatic refueling and placing items in a chest if -- inner inventory is full
local isInventoryFull = false
-- all locations are calculated from the left corner of the staircase with respect to the starting orientation
--                x, y, z
local position = {2, 1, 0} -- current position of the mining turtle initialized at the start 
local startingPosition = {2, 1, 0} -- the starting position of the mining turtle
local leftOfPosition = {0, 0, 0} -- the position the turtle left to get back to the origin or after reload of chunk
local chestLocation = {0, 0, 0}  --starts to detect a chest besides the turtle at the begining {0,0,0} means chest is not placed
local orientation = {0, 1}  -- x, y between -1 and 1 staerting looking north in its own system
local isRight = true
local staircaseMid = {1, 1, 3} -- position of the middle block of the staircase that the turtle is currently operating in
local corridor = "north" -- just the initial corridor orientation
local corridorArray = {"north", "east", "south", "west"} -- an array storing the corridor orientations to pick from
local corridorDiggedCount = 0

-- dont know if I can use this, as turtle.inspect() returns differen ids for each check on the same object
-- local corridorDistance = 2 -- the distance in blocks between a corridor, can be changed in the interface

local torch = turtle.getItemCount(1) -- How many items are in slot 1 (torch)
local chest = turtle.getItemCount(2) -- How many items are in slot 2 (chest)
local ItemFuel = turtle.getItemCount(3) -- How many items are in slot 3 (Fuel)
local Fuel = 0 -- if 2 then it is unlimited no fuel needed
local NeedFuel = 0 -- If Fuel Need Then 1 if not Then 0
local Error = 0 -- 0 = No Error and 1 = Error

local torchNeedsPlacing = false


-- Main -- 


 -- function to organise the digging of the corridors at current staircase level
function excavateLevel()
	generalCheck()
	digXDown(2)
    makeStaircase()
	local corridorIndex = 1
    for i = 1, 4 do 
    	corridor = corridorArray[i]
    	moveToCorridorDiggingPosition()
    	digCorridor(8)
    	corridorDiggedCount = corridorDiggedCount + 1
    end
end

-- just for testing the corridor digging to verify that it is working correctly
function testing()
	checkForChest()
end


-- Movement --


-- move turtle to dig the corridor from staircase
function moveToCorridorDiggingPosition()
	if corridorDiggedCount == 0 then
		moveXForward(2)
	elseif corridorDiggedCount == 1 then
		turnRight()
		moveForward()
	elseif corridorDiggedCount == 2 then
		turnAround()
		moveForward()
	else
		turnLeft()
		moveXForward(2)
	end
end

-- moves the turtle back to the corridor 
function backToMainCorridor()
	turnAround()
	if corridor == "north" or corridor == "south" then
		while position[1] ~= startingPosition[1] do
			moveForward()
		end
	else
		while position[2] ~= startingPosition[2] do 
			moveForward()
		end
	end
	print("back in main corridor")
end

-- moves the turtle back to the stiarcase, might be useless as it is probably covert by returnFromMiningTunnel
function goBackToStaircase()
	turnLeft()
	if position[1] < 0 or position[2] < 0 then
		if position[1] < position[2] then
			while position[1] ~= startingPosition[1] do
				moveForward()
			end
		else
			while position[2] ~= startingPosition[2] do 
				moveForward()
			end
		end
	else
		if position[1] > position[2] then
			while position[1] ~= startingPosition[1] do
				moveForward()
			end
		else
			while position[2] ~= startingPosition[2] do 
				moveForward()
			end
		end
	end
	print("back in staircase")
end

-- return the turtle to the middle of the staircase for staircase building
function toMidOfStaircase()
	digForward()
	turnLeft()
	digForward()
	turnRight()
end

-- returns the turtle from its current porsiton in the mine to the middle of the stiarcase
function returnFromMiningTunnel(corridor)
	turnAround()
	if corridor == "north" or corridor == "south" then
		while position[2] ~= startingPosition[2] do
			moveForward()
		end
		turnLeft()
		while position[1] ~= startingPosition[1] do
			moveForward()
		end
	else
		while position[1] ~= startingPosition[1] do 
			moveForward()
		end
		turnLeft()
		while position[2] ~= startingPosition[2] do
			moveForward()
		end
	end
end

-- turtle returns to origin (place where a chest might be)
function backToOrigiFromStaircase(origin)
	local x, y, z = position[1], position[2], position[3]
	local startingPosition = position 

end


-- Digging --


-- the turtle digs in a spiral form the stairtcase
function makeStaircase()
    for i=1, 2 do
    	local X = 4
    	local Y = 4
    	local x = 0
	    local y = 0
	    local dx = 0
	    local dy = -1
        for j = 0, sqrt(max(X, Y)) do
            if (-X/2 < x and x <= X/2) and (-Y/2 < y and y <= Y/2) then
            	digForward()
            end
            if x == y or (x < 0 and x == -y) or (x > 0 and x == 1-y) then
            	turnLeft()
            	if i % 2 == 0 and (x == 2 or y == 2 or x == 0 or y == 0) then
            		placeTorch()
            	end
                tempX = dx
                dx = -dy
                dy = tempX
            end
            x = x + dx
            y = y + dy
        end
        toMidOfStaircase()
        if i % 2 == 1 then
        	digDown()
        end
    end
    staircaseMid = position
end

-- dig the corridor according to gamepedias pinwheel mining
function digCorridor(length)
	for i = 1, length do
		isRight = i % 2 == 1
		if i % 4 == 0 then
			torchNeedsPlacing = i%5 == 0
			dig2x2()
			turnRight()
			for j = 1, length + 1 do
				isRight = j % 2 == 0
				torchNeedsPlacing = j % 5 == 0
				if torchNeedsPlacing then
					placeTorch()
				end
				dig2x2()
			end
			checkFuel()
			print("corridor done")
			backToMainCorridor()
			if i ~= length then
				turnRight()
				moveForward()
			end
		else
			dig2x2()
		end
	end
	print("Main corrdiro done")
	goBackToStaircase()
	turnAround()
end

-- starts to dig the block infront and then mines a 2x2 area
function dig2x2()
	if isRight then
		digForward()
		turtle.digUp()
		turnLeft()
		digForward()
		turtle.digUp()
		turnRight()
	else
		digForward()
		turtle.digUp()
		turnRight()
		digForward()
		turtle.digUp()
		turnLeft()
	end
	if turtle.getItemCount(16) == 64 then
		transferItemsToInventoryChest()
	end
end


-- Checks --


-- Checking for essentials in the beginning
function generalCheck()
	if torch == 0 then
		print("There are no torch's in Turtle")
		Error = 1
	else
		print("There are torch's in the turtle")
	end
	if chest == 0 then
		print("There are no chests")
		Error = 1
	else
		print("There are chests in the turtle")
	end
	if ItemFuel == 0 then
		print("No Fuel Items")
		Error = 1
	else
		print("There is fuel")
	end
	-- if checkForChest() then 
	-- 	print("Your chest is on my "..orientationVectorAsString(chestPosition))
	-- else
	-- 	print("You have not placed a chest in reach :(")
	-- end
	repeat
		checkFuel()
	until NeedFuel == 0
end
 
-- Recheck if user forget something turtle will check after 15 sec
function recheck()
	torch = turtle.getItemCount(1)
	chest = turtle.getItemCount(2)
	ItemFuel = turtle.getItemCount(3)
	Error = 0
end

-- check if the turtle has fuel
function checkFuel()
	if turtle.getFuelLevel() == "unlimited" then 
			print("NO NEED FOR FUEL")
			Needfuel = 0
	elseif turtle.getFuelLevel() < 100 then
		turtle.select(3)
		turtle.refuel(8)
		Needfuel = 1
		ItemFuel = ItemFuel - 1
	elseif NeedFuel == 1 then
		Needfuel = 0
	end
end

-- check if there is a chest besides the turtle, saving it in a vairiable and returns its findings
-- can only check for "normal" chest and chests from iron chests
function checkForChest()
	for i = 1, 4 do 
		if turtle.inspect() ~= false then 
			inspection =  {turtle.inspect()}
			tableString = tostring(inspection[2])
			item = string.sub(tableString, 7)
			print(item)
			if contains(chestIDs, item) then
				chestPosition = convertOrientationIntoVector()
				printArray(chestPosition)
				return true
			end
		end
		turnLeft()
	end
end


-- Mining Fundamentals --


-- places torches infront and marks that a torch has been planted
function placeTorch()
	local currentSlot = turtle.getSelectedSlot()
	turtle.select(1)
	if isRight then
		turnRight()
		turtle.placeUp()
		turnLeft()
	else
		turnLeft()
		turtle.placeUp()
		turnRight()
	end
	turtle.select(currentSlot)
	torchNeedsPlacing = false
	print("torch placed")
end

-- transfers the items in all slots except the fir 3 into the chest it is carrying in its inventory
function transferItemsToInventoryChest()
	for i = 4, 16 do 
		turtle.select(i)
		turtle.transferTo(2)
	end
end

-- changes the position value according to the orientation after the turtle moved forward
function changePositionValueXY()
 	if orientation[1] ~= 0 then 
 		position[1] = position[1] + orientation[1]
 	else
 		position[2] = position[2] + orientation[2]
 	end
end

-- changes the orientation of the turtle accordingly after a left turn
function changeOrientationTurnLeft()
	if orientation[1] ~= 0 then
		if orientation[1] == 1 then
			orientation[1], orientation[2] = orientation[1] - 1, orientation[2] - 1
		else
			orientation[1], orientation[2] = orientation[1] + 1, orientation[2] + 1
		end
	else
		if orientation[2] == 1 then
			orientation[1], orientation[2] = orientation[1] + 1, orientation[2] - 1
		else
			orientation[1], orientation[2] = orientation[1] - 1, orientation[2] + 1
		end
	end
end

-- changes the orientation of the turtle accordingly after a right turn
function changeOrientationTurnRight()
	if orientation[1] ~= 0 then
		if orientation[1] == 1 then
			orientation[1], orientation[2] = orientation[1] - 1, orientation[2] + 1
		else
			orientation[1], orientation[2] = orientation[1] + 1, orientation[2] - 1
		end
	else
		if orientation[2] == 1 then
			orientation[1], orientation[2] = orientation[1] - 1, orientation[2] - 1
		else
			orientation[1], orientation[2] = orientation[1] + 1, orientation[2] + 1
		end
	end
end
 
-- refuels the turtle if needed by the optimal amount
function Fuel()
    if turtle.getFuelLevel() == "unlimited" and turtle.getItemCount(fuelSlot) ~= 0 then
        while turtle.getFuelLevel() ~= turtle.getFuelLimit() do
            turtle.refuel(1)
        end
    end
end
 
-- move the turtle one forward and increases the x coordinat of its position
function moveForward()
    turtle.forward()
    changePositionValueXY()
end

-- move the turtle x blocks forward
function moveXForward(steps)
	for i = 1, steps do 
		moveForward()
	end
end

-- turns the turtle left and changes the orientation value accordingly
function turnLeft()
	turtle.turnLeft()
	changeOrientationTurnLeft()
end

-- turns the turle by 180 degrees 
function turnAround()
	turnLeft()
	turnLeft()
end

-- turns the turtle right and changes the orientation value accordingly
function turnRight()
	turtle.turnRight()
	changeOrientationTurnRight()
end
 
-- moves the turtle one down and decreases the z coordinat of its position
function moveDown()
    turtle.down()
    position[3] = position[3] - 1
end

-- moves the turtle down by x steps
function moveXDown(steps)
	for i = 1, steps do
		moveDown()
	end
end

-- moves the turtle one down and increases the z coordinat of its position
function moveUp()
    turtle.up()
    position[3] = position[3] + 1
end
 
-- moves the turtle up by x steps
function moveXUp(steps)
	for i = 1, steps do
		moveUp()
	end
end

-- dig block forward and move one block forward
function digForward()
	if turtle.detect() then
    	turtle.dig()
    end
    moveForward()
end

-- dig x block forward and move forward
function digXForwad(steps)
	for i = 1, steps do
		digForward()
	end
end
 
-- digg block below and move to that spot
function digDown()
	if turtle.detectDown() then
    	turtle.digDown()
    end
    moveDown()
end

-- dig x blocks below and move down
function digXDown(steps)
	for i = 1, steps do
		digDown()
	end
end

-- dig block in uptop and move to that spot
function digUp()
	if turtle.detectUp() then
    	turtle.digUp()
    end
    moveUp()
end

-- dig x blocks below and move Up
function digXUp(steps)
	for i = 1, steps do 
		digUp()
	end
end

-- converts the orientation into a position vector with respect to the current position
function convertOrientationIntoVector()
	local orientationVector = {0, 0, 0}
	if orientation[1] ~= 0 then
		orientationVector[1] = orientationVector[1] + orientation[1]
		return orientationVector
	else
		orientationVector[2] = orientationVector[2] + orientation[2]
		return orientationVector
	end
	orientationVector[3] = position[3]
end

-- function orientationVector into a string representing a compass direction
function orientationVectorAsString(orientationVector)
	if orientationVector[1] ~= 0 then
		if orientationVector[1] == 1 then
			return "east"
		else
			return "west"
		end
	else
		if orientationVector[2] == 1 then
			return "north"
		else
			return "south"
		end
	end
end



-- fundamental functions --


-- tests if to arrays are equal
function equal(arr1, arr2)
 	local isEqual = true
 	if #arr1 == #arr2 then
 		for i = 1, #arr1 do
 			if isEqual == false then return false
 			else
 				if arr1[i] ~= arr2[i] then isEqual = false end
 			end
 		end
 	end
 	return true
 end

 -- simple squaring function
function sqrt(x)
    return x * x
end
 
-- simple max function
function max(x, y)
    if x > y then
        return x
    end
    return y
end

-- function to absolute a value
function abs(value)
	if value < 0 then
		return value * -1
	else
		return value
	end
end

-- prints a 1dim array the way youd expect it to be printed
function printArray(arr)
	text = "{"
	for i = 1, #arr do 
		if i == 1 then text = text..tostring(arr[i])
		else
			text = text..", "..tostring(arr[i])
		end
	end
	text = text.."}"
	print(text) 
 end

-- checks if a value is contained in the array
 function contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

excavateLevel()
-- testing()