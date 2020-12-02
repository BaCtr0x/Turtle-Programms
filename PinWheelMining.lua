-- this is obviously not done yet, just for testing on my server
 
--this program will tell the turtle to do pinwheel mining in an effective way with automatic refueling and placing items in a chest if -- inner inventory is full
local isInventoryFull = false
-- all locations are calculated from the left corner of the staircase with respect to the starting orientation
--                x, y, z
local position = {1, 1, 0} -- current position of the mining turtle initialized at the start 
local startingPosition = {1, 1, 0} -- the starting position of the mining turtle
local leftOfPosition = {0, 0, 0} -- the position the turtle left to get back to the origin or after reload of chunk
local chestLocation = {0, 0, 0}  --starts to detect a chest besides the turtle at the begining {0,0,0} means chest is not placed
local orientation = {0, 1}  -- x, y between -1 and 1
local staircaseMid = {1, 1, 3} -- position of the middle block of the staircase that the turtle is currently operating in
local corridor = "east" -- just the initial corridor orientation
local corridorArray = {"east", "south", "west", "north"} -- an array storing the corridor orientations to pick from

local corridorDistance = 2 -- the distance in blocks between a corridor, can be changed in the interface

local torch = turtle.getItemCount(1) -- How many items are in slot 1 (torch)
local chest = turtle.getItemCount(2) -- How many items are in slot 2 (chest)
local ItemFuel = turtle.getItemCount(3) -- How many items are in slot 3 (Fuel)
local Fuel = 0 -- if 2 then it is unlimited no fuel needed
local NeedFuel = 0 -- If Fuel Need Then 1 if not Then 0
local Error = 0 -- 0 = No Error and 1 = Error

 -- function to organise the digging of the corridors at current staircase level
function excavateLevel()
	local corridorIndex = 1
    for i = 1, 4 do 
    	corridor = corridorArray[i]
    	digCorridor()
    end
end

function testcorridordgigging()
	makeStaircase()
	digCorridor(4)
end

-- dig the corridor according to gamepedias pinwheel mining
function digCorridor(length)
	printArray(orientation)
	for i = 1, length do
		if i % 4 == 0 then
			turnRight()
			moveForward()
			for j = 1, length + 1 do
				dig2x2()
			end
			backToMainCorridor()
		else
			dig2x2()
		end
	end
	goBackToStaircase()
end

-- moves the turtle back to the stiarcase, might be useless as it is probably covert by returnFromMiningTunnel
function goBackToStaircase()
	turnLeft()
	turnleft()
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

-- starts to dig the block infront and then mines a 2x2 area
function dig2x2()
	digForwad()
	digUp()
	turnLeft()
	digForwad()
	digForwad()
	digDown()
	turnLeft()
	turnLeft()
	moveForward()
	turnLeft()
end

-- returns the turtle from its current porsiton in the mine to the middle of the stiarcase
function returnFromMiningTunnel(corridor)
	turnLeft()
	turnLeft()
	if corridor == "west" or corridor == "east" then
		while position[1] ~= startingPosition[1] do
			moveForward()
		end
		turnLeft()
		while position[2] ~= startingPosition[2] do
			moveForward()
		end
	else
		while position[2] ~= startingPosition[2] do 
			moveForward()
		end
		turnLeft()
		while position[1] ~= startingPosition[1] do
			moveForward()
		end
	end
end

-- turtle returns to origin (place where a chest might be)
function backToOrigiFromStaircase(origin)
	local x, y, z = position[1], position[2], position[3]
	local startingPosition = position 
end

--Checking
local function Check()
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
	repeat
		if turtle.getFuelLevel() == "unlimited" then 
			print("NO NEED FOR FUEL")
			Needfuel = 0
		elseif turtle.getFuelLevel() < 100 then
			turtle.select(3)
			turtle.refuel(1)
			Needfuel = 1
			ItemFuel = ItemFuel - 1
		elseif NeedFuel == 1 then
			Needfuel = 0
		end
	until NeedFuel == 0
end
 
-- Recheck if user forget something turtle will check after 15 sec
local function Recheck()
	torch = turtle.getItemCount(1)
	chest = turtle.getItemCount(2)
	ItemFuel = turtle.getItemCount(3)
	Error = 0
end


-- the turtle digs in a spiral form the stairtcase
function makeStaircase()
    digDown()
    digDown()
    for i=1, 2 do
    	local X = 4
    	local Y = 4
    	local x = 0
	    local y = 0
	    local dx = 0
	    local dy = -1
        for j = 0, sqrt(max(X, Y)) do
            if (-X/2 < x and x <= X/2) and (-Y/2 < y and y <= Y/2) then
            	digForwad()
            end
            if x == y or (x < 0 and x == -y) or (x > 0 and x == 1-y) then
            	turnLeft()
                tempX = dx
                dx = -dy
                dy = tempX
            end
            x = x + dx
            y = y + dy
        end
        toMidOfStaircase()
    end
    staircaseMid = position
end

-- return the turtle to the middle of the staircase is staircase building
function toMidOfStaircase()
	digForwad()
	turnLeft()
	digForwad()
	turnRight()
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
			orientation[1], orientation[2] = orientation[1] + 1, orientation[2] + 1
		else
			orientation[1], orientation[2] = orientation[1] - 1, orientation[2] - 1
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

-- turns the turtle left and changes the orientation value accordingly
function turnLeft()
	turtle.turnLeft()
	changeOrientationTurnLeft()
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

-- moves the turtle one down and increases the z coordinat of its position
function moveUp()
    turtle.up()
    position[3] = position[3] + 1
end
 
-- dig block below and move one block down
function digForwad()
	if turtle.detect() then
    	turtle.dig()
    end
    moveForward()
end
 
-- digg block below and move to that spot
function digDown()
	if turtle.detectDown() then
    	turtle.digDown()
    end
    moveDown()
end

-- digg block in uptop and move to that spot
function digUp()
	if turtle.detectUp() then
    	turtle.digUp()
    end
    moveUp()
end



-- fundamental functions
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
 
testcorridordgigging()