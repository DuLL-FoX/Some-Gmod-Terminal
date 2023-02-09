local gamePanel

local function endGame(result)
    hook.Remove("Think", "MoveRows")
    hook.Remove("Think", "CatchNumber")
    gamePanel:Remove()

    if result then
        MainScreen(true)
    else
        local hackFailed = vgui.Create("DLabel", TerminalFrame)
        hackFailed:SetFont("Default")
        hackFailed:SetText("Hack failed!")
        hackFailed:SetTextColor(Color(255, 0, 0))
        hackFailed:SizeToContents()
        hackFailed:Dock(TOP)

        timer.Simple(1, function()
            hackFailed:Remove()
        end)

        PasswordEnterScreen(1)
    end
end

function startHack()
    -- Main loop
    PasswordEnterScreen(2)
    numbers = {}
    speed = 0.1
    currentRow = 1
    lastMoveTime = 0
    createRows()
    currentNumber = numbers[1]
    gamePanel = vgui.Create("DPanel", TerminalFrame)

    function gamePanel:Paint(w, h)
        drawRows(w, h)
    end

    gamePanel:Dock(FILL)
    local timerStart = CurTime() + 60 -- Timer for 60 seconds

    hook.Add("Think", "MoveRows", function()
        if (CurTime() - lastMoveTime) > speed then
            moveRows()
            lastMoveTime = CurTime()
        end

        -- Check if timer has reached 60 seconds
        if CurTime() > timerStart then
            endGame(false)
        end
    end)

    hook.Add("Think", "CatchNumber", function()
        if input.IsKeyDown(KEY_SPACE) then
            catchNumber()
        end

        catchNumber()

        -- Check if all numbers have been caught
        if #numbers == currentRow - 1 then
            endGame(true)
        end
    end)
end

function generateNumbers()
    for i = 1, 5 do
        numbers[i] = math.random(30)
    end
end

-- Create the rows with numbers
function createRows()
    rows = {}
    generateNumbers()

    for i = 1, #numbers do
        row = {}

        for j = 1, 9 do
            table.insert(row, math.random(30))
        end

        table.insert(row, numbers[i])
        table.insert(rows, row)
    end
end

-- Move the rows down
function moveRows()
    for i = 1, #rows do
        if i < currentRow then
            rows[i][#rows[i]] = rows[i][#rows[i]]
        else
            for j = 1, #rows[i] - 1 do
                rows[i][j] = rows[i][j + 1]
            end

            rows[i][#rows[i]] = math.random(50)
        end
    end
end

-- Draw the rows on the screen
function drawRows(w, h)
    for i = 1, #rows do
        rowString = ""

        for j = 1, #rows[i] do
            if rows[i][j] == currentNumber then
                rowString = rowString .. " " .. string.format("%02d", rows[i][j])
            else
                rowString = rowString .. " " .. string.format("%02d", rows[i][j])
            end
        end

        if i < currentRow then
            draw.SimpleText(rowString, "Default", w / 2, i * 20 + h / 2, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif i == currentRow then
            draw.SimpleText(rowString, "Default", w / 2, i * 20 + h / 2, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(rowString, "Default", w / 2, i * 20 + h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

-- Catch the specified number
function catchNumber()
    if rows[currentRow][#rows[currentRow]] == currentNumber and #numbers >= currentRow then
        -- You caught the number!
        currentRow = currentRow + 1
        currentNumber = numbers[currentRow]
    end
end