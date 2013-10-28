-- Copyright (C) 2013 Corona Inc. All Rights Reserved.
-- File: newTableView unit test.

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

--Forward reference for test function timer
local testTimer = nil

local USE_ANDROID_THEME = false
local USE_IOS7_THEME = widget.isSeven()
local isGraphicsV1 = ( 1 == display.getDefault( "graphicsCompatibility" ) )

local tableSeparatorColor = { 0.86, 0.86, 0.86, 1 }

if isGraphicsV1 then
	widget._convertColorToV1( tableSeparatorColor )
end

local tableView

function scene:createScene( event )
	local group = self.view
	
	-- Test android theme
	if USE_ANDROID_THEME then
		widget.setTheme( "widget_theme_android" )
	end

	--Display an iOS style background
	local background
	
	local xAnchor, yAnchor
	
	if not isGraphicsV1 then
		xAnchor = display.contentCenterX
		yAnchor = display.contentCenterY
	else
		xAnchor = 0
		yAnchor = 0
	end
	
	if USE_IOS7_THEME then
		background = display.newRect( xAnchor, yAnchor, display.contentWidth, display.contentHeight )
	else
		background = display.newImage( "unitTestAssets/background.png" )
		background.x, background.y = xAnchor, yAnchor
	end
	
	group:insert( background )
	
	if USE_IOS7_THEME then
		-- create a white background, 40px tall, to mask / hide the scrollView
		local topMask = display.newRect( 0, 0, display.contentWidth, 40 )
		topMask:setFillColor( 235, 235, 235, 255 )
		group:insert( topMask )
	end
	
	local backButtonPosition = 5
	local backButtonSize = 52
	local fontUsed = native.systemFont
	local textFontUsed = native.systemFontBold
	
	
	if USE_IOS7_THEME then
		backButtonPosition = 0
		backButtonSize = 40
		fontUsed = "HelveticaNeue-Light"
		textFontUsed = "HelveticaNeue-Light"
	end
	
	-- Button to return to unit test listing
	local returnToListing = widget.newButton
	{
	    id = "returnToListing",
	    left = 0,
	    top = backButtonPosition,
	    label = "Exit",
		labelAlign = "center",
		fontSize = 18,
	    width = 200, height = backButtonSize,
	    cornerRadius = 8,
	    onRelease = function() storyboard.gotoScene( "unitTestListing" ) end;
	}
	returnToListing.x = display.contentCenterX
	group:insert( returnToListing )
	
	----------------------------------------------------------------------------------------------------------------
	--										START OF UNIT TEST
	----------------------------------------------------------------------------------------------------------------
	
	--Toggle these defines to execute tests. NOTE: It is recommended to only enable one of these tests at a time
	local TEST_SCROLL_TO_Y = false
	local TEST_SCROLL_TO_INDEX = false
	local TEST_DELETE_SINGLE_ROW = false
	local TEST_DELETE_ALL_ROWS = false
	local TEST_GET_CONTENT_POSITION = false
	local TEST_REMOVE_AND_RECREATE = false
		
	-- Listen for tableView events
	local function tableViewListener( event )
		local phase = event.phase
		local direction = event.direction
		
		if "began" == phase then
			--print( "Began" )
		elseif "moved" == phase then
			--print( "Moved" )
		elseif "ended" == phase then
			--print( "Ended" )
		end
		
		if event.limitReached then
			if "up" == direction then
				print( "Reached Top Limit" )
			elseif "down" == direction then
				print( "Reached Bottom Limit" )
			elseif "left" == direction then
				print( "Reached Left Limit" )
			elseif "right" == direction then
				print( "Reached Right Limit" )
			end
		end
				
		return true
	end


	local noCategories = 0

	-- Handle row rendering
	local function onRowRender( event )
		local phase = event.phase
		local row = event.row
				
		--print( "Rendering row with id:", row.id )
		--print( #tableView._view._rows )
		local rowTitleText = "Row " .. row.index
		
		if row.isCategory then
			noCategories = noCategories + 1
			rowTitleText = "Category"
		end
		
		local rowTitle
		if USE_IOS7_THEME and not row.isCategory then
			rowTitle = display.newText( row, rowTitleText, 0, 0, "HelveticaNeue-Light", 17 )
		elseif USE_IOS7_THEME and row.isCategory then
			rowTitle = display.newText( row, rowTitleText, 0, 0, "HelveticaNeue", 14 )
		else
			rowTitle = display.newText( row, rowTitleText, 0, 0, nil, 14 )
		end

		rowTitle.x = 38
		
		local rowY = row.contentHeight * 0.4
		
		if isGraphicsV1 then
			rowY = row.contentHeight * 0.5
		end
		
		if row.isCategory then
			rowY = row.contentHeight * 0.3
		end
		
		rowTitle.y = rowY
		
		rowTitle:setFillColor( 0, 0, 0 )
		
		if not row.isCategory then
			--print( row.index )
			local spinner = widget.newSpinner{}
			spinner.x = row.x + ( row.contentWidth ) - 20
			spinner.y = row.contentHeight * 0.5
			spinner:scale( 0.5, 0.5 )
			row:insert( spinner ) 
			--spinner:start()
		end
		
		
		
	end

	
	-- Handle touches on the row
	local function onRowTouch( event )
		local phase = event.phase
		local row = event.target
		
		if "swipeRight" == phase then
			print( "Swiped right on row with index: ", row.index )
		elseif "swipeLeft" == phase then
			print( "Swiped left on row with id: ", row.id )
		elseif "tap" == phase then
			print( "Tapped on row with id:", row.id )
		elseif "press" == phase then
			print( "Pressed row with id: ", row.id )
			
			-- Set the row's default/over color's
			--row:setRowColor( { default = { 255, 0, 0 }, over = { 0, 0, 255 } } )
			print( row.params.rowIdentifier )
						
		elseif "cancelled" == phase then
			print( "Cancelled event on row with index: ", row.index )	
		
		elseif "release" == phase then
			print( "Released row with index: ", row.index )
			
			-- Test removing all rows and re-adding 20 more
			if TEST_REMOVE_AND_RECREATE then
				timer.performWithDelay( 500, function()
					tableView:deleteAllRows()
					
					-- Create 100 rows
					for i = 1, 20 do
						local isCategory = false
						local rowHeight = 40
						local rowColor = 
						{ 
							default = { 255, 255, 255 }
						}
						local lineColor = { 0.86, 0.86, 0.86, 1 }

						-- Make some rows categories
						if i == 8 or i == 25 or i == 50 or i == 75 then
							isCategory = true
							rowHeight = 24
							rowColor = 
							{
								default = { 150, 160, 180, 200 },
							}
						end

						-- Insert the row into the tableView
						tableView:insertRow
						{
							id = "row:" .. i,
							isCategory = isCategory,
							rowHeight = rowHeight,
							rowColor = rowColor,
							lineColor = lineColor,
						}
					end
				end)
			end
		end
	end
	
	-- Create a tableView
	tableView = widget.newTableView
	{
		top = 40,
		left = 0,
		width = display.contentWidth, 
		--height = 300,
		height = display.contentHeight - 40,
		--listener = tableViewListener,
		--isLocked = true,
		--hideBackground = true,
		onRowRender = onRowRender,
		onRowTouch = onRowTouch,
	}
	group:insert( tableView )
	
	-- Create 200 rows
	for i = 1, 200 do
		local isCategory = false
		local rowHeight = 40
		local rowColor = nil
		
		if not widget.isSeven() then
			rowColor = { 
				default = { 255, 255, 255 },
				over = { 217, 217, 217 },
			}
		end

		local lineColor = tableSeparatorColor;
		
		-- Make some rows categories
		---[[
		if i == 1 or i == 4 or i == 8 or i == 22 or i == 28 or i == 35 or i == 45 then
			isCategory = true
			
			rowHeight = 24
			--rowHeight = 47
			
			if not widget.isSeven() then
				rowColor = 
				{ 
					default = { 150, 160, 180, 200 },
				}
			end
			
		end
		--]]
		local rowParams = {
		rowIdentifier = "testing"..i,
		}
		-- Insert the row into the tableView
		tableView:insertRow
		{
			id = "row:" .. i,
			isCategory = isCategory,
			rowHeight = rowHeight,
			rowColor = rowColor,
			lineColor = lineColor,
			params = rowParams
		}
	end

	----------------------------------------------------------------------------------------------------------------
	--											TESTS
	----------------------------------------------------------------------------------------------------------------			
	
	-- Test to scroll list to Y position
	if TEST_SCROLL_TO_Y then
		testTimer = timer.performWithDelay( 1000, function()
			tableView:scrollToY{ y = -300, time = 6000 }
		end, 1 )
	end
	
	-- Test getting the content position
	if TEST_GET_CONTENT_POSITION then
		local function getPosition()
			print( "tableView content position is: ", tableView:getContentPosition() )
		end
		
		tableView:scrollToY{ y = - 300, time = 600, onComplete = getPosition }
	end
	
	-- Test to scroll list to index
	if TEST_SCROLL_TO_INDEX then
		local currentIndex = 1
		local testIndexes = { 31, 1, 7, 168, 4, 14, 2, 8 }
	
		local function scrollToNextIndex()
			print( "Scrolled to row index:", testIndexes[currentIndex] )
			
			if currentIndex < #testIndexes then
				currentIndex = currentIndex + 1
			end
			
			timer.performWithDelay( 1500, function()
				tableView:scrollToIndex( testIndexes[currentIndex], 1000, scrollToNextIndex )
			end)
		end
		
		testTimer = timer.performWithDelay( 1000, function()
			tableView:scrollToIndex( testIndexes[currentIndex], 1000, scrollToNextIndex )
		end)
	end
	
	-- Test deleting single row
	if TEST_DELETE_SINGLE_ROW then
		testTimer = timer.performWithDelay( 1000, function()			
			tableView:deleteRow( 5 ) --Delete Row 5
		end, 1 )
	end
	
	-- Test delete all rows
	if TEST_DELETE_ALL_ROWS then
		testTimer = timer.performWithDelay( 1000, function()			
			tableView:deleteAllRows() --No rows after execution
		end, 1 )
	end
end

function scene:didExitScene( event )
	--Cancel test timer if active
	if testTimer ~= nil then
		timer.cancel( testTimer )
		testTimer = nil
	end
	
	storyboard.removeAll()
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "didExitScene", scene )

return scene
