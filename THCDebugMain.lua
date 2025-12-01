Commands.thc = function(args)
    print("THC:: /thcdmhub [prints the dmhub object]")
    print("THC:: /thcdumpobj objName [prints the named global object]")
    print("THC:: /thctabletypes [prints the names of all registered tables]")
    print("THC:: /thcdumptable tableName [prints the named table's contents]")
    print("THC:: /thctableinfo tableName, findName [prints the table record with the matching name]")
    print("THC:: /thctokenprops [prints the selected token's info in several formats]")
end

Commands.thcdmhub = function(args)
    print("THC::", dmhub)
end

Commands.thcdumpobj = function(args)
    local o = _G[args]
    if o ~= nil then
        print("THC::", args, o)
        print("THC::", json(o))
    else
        print("THC:: /dumpobj objName")
    end
end

Commands.thctabletypes = function(args)
    local tableNames = dmhub.GetTableTypes()
    if tableNames and #tableNames > 0 then
        table.sort(tableNames)
        print("THC::", table.concat(tableNames, ", "))
    end
end

Commands.thclosemodal = function(args)
    gui.CloseModal()
end

Commands.thcdumptable = function(args)
    local t = dmhub.GetTable(args)
    if t ~= nil then
        print("THC:: ", json(t))
    else
        print(string.format("THC:: [%s] not found.", args))
    end
end

Commands.thctableinfo = function(args)
    local result = {}
    for w in args:gmatch("[^,]+") do
        table.insert(result, string.trim(w))
    end
    if #result ~= 2 then
        print("THC:: FORMAT /thctableinfo tableName, nameToFind")
    end
    local t = dmhub.GetTable(result[1]) or {}
    if t and next(t) then
        for id, row in pairs(t) do
            if string.lower(row.name) == string.lower(result[2]) then
                print("THC:: TABLE", result[1], "NAME", result[2], "ID", id, row)
                print("THC:: TABLE", json(row))
                break
            end
        end
    else
        print("THC:: EMPTYTABLE::", result[1])
    end
end

Commands.thctokenprops = function(args)
    if dmhub.currentToken then
        local c = dmhub.currentToken.properties
        print("THC:: TOKENPROPS:: TOK::", dmhub.currentToken)
        print("THC:: TOKENPROPS:: TOK:: ID::", dmhub.currentToken.id)
        print("THC:: TOKENPROPS:: TOK:: RETAINER::", dmhub.currentToken.properties:IsRetainer())
        print("THC:: TOKENPROPS:: OBJ::", c)
        print("THC:: TOKENPROPS:: JSON:: ", json(c))
        if c:IsMonster() then
            print("THC:: TOKENPROPS:: MGROUP::", c:MonsterGroup())
        end
        print("THC:: TOKENPROPS:: VECTOR::", type(dmhub.currentToken.portraitRect))
        print("THC:: TOKENPROPS:: saddlePositions::", type(dmhub.currentToken.saddlePositions))
    else
        print("THC:: TOKENPROPS:: Select a token.")
    end
end

Commands.thcalltoks = function(args)
    local s = "THC:: "
    for _, t in pairs(dmhub.allTokens) do
        s = s .. t.name .. " | "
    end
    print(s)
end

--- Fixes the missing category for skills missing them in Codex v 600.*
Commands.thcfsc = function(args)

    local function uploadTableItem(tableName, item)
        local opts = {
            deferUpload = false,
        }
        dmhub.SetAndUploadTableItem(LanguageRelation.tableName, item, opts)
    end

    local skillsToFix = {
        Alchemy = "crafting",
        Architecture = "crafting",
        Blacksmithing = "crafting",
        Climb = "exploration",
        Drive = "exploration",
        Fletching = "crafting",
        Forgery = "crafting",
        Jewelry = "crafting",
        Mechanics = "crafting",
        Tailoring = "crafting",
    }

    print("THC:: Fixing skill categories...")
    local t = dmhub.GetTable(Skill.tableName)
    if t then
        print("THC:: Got Table", Skill.tableName)
        for skillName, category in pairs(skillsToFix) do
            print("THC:: CHECKING::", skillName)
            for id, row in pairs(t) do
                if row.name == skillName then
                    if row:try_get("category") == nil then
                        print(string.format("THC:: SETTING %s cat to %s", skillName, category))
                        row.category = category
                        uploadTableItem(Skill.tableName, row)
                    end
                end
            end
        end
    else
        print("THC:: Can't get table ", Skill.tableName)
    end
end

--- DESTRUCTIVE. Removes (if not commented out) any records from the named
--- table that are hidden (soft-deleted)
Commands.thcremovehidden = function(args)
    local t = dmhub.GetTable(args)
    if t ~= nil then
        for k, i in pairs(t) do
            if i:try_get("hidden") and i.hidden then
                print(string.format("THC:: HIDDEN:: ITEMNAME:: %s HIDDEN:: %s, KEY:: %s", i.name, i.hidden, k))
                -- t[k] = nil
            end
        end
    else
        print(string.format("THC:: [%s] not found.", args))
    end
end

Commands.thcuiscale = function(args)
    print("THC:: UISCALE::", json(dmhub.uiscale))
end

Commands.thcfixmonsters = function(args)
    local bestiary = assets.monsters
    for k, m in pairs(bestiary) do
        local properties = m.properties
        if properties ~= nil and properties:has_key("monster_category") then
            if type(properties.monster_category) == "boolean" then
                print("THC::", m.description, m)
                m.properties.monster_category = nil
                m:Upload()
            end
        end
    end
end

Commands.thcmonsternode = function(args)
    local n = assets:GetMonsterNode(args or "")
    if n then 
        -- print("THC::", n, n.description)
        for _, n in pairs(n.children) do
            -- print("THC:: CHILD::", n, n.description)
            if "Retainers" == n.description then
                for _, m in pairs(n.children) do
                    if m.monster then
                        local m1 = m.monster.info
                        print("THC:: MONSTER::", m1.description, m1.monster)
                    end
                end
            end
        end
    end
end

Commands.thcdetest = function(args)
    local fl1 = {
        ["apple"] = true,
        ["pear"] = true,
        ["orange"] = true,
    }
    local fl2 = {
        ["orange"] = true,
        ["apple"] = true,
        ["pear"] = true,
    }
    local fl3 = {
        ["orange"] = true,
        ["apple"] = false,
        ["pear"] = true,
    }
    print(string.format("THC:: 1==2 ? [%s]", dmhub.DeepEqual(fl1, fl2)))
    print(string.format("THC:: 1==3 ? [%s]", dmhub.DeepEqual(fl1, fl3)))
end

Commands.thcglobalchars = function(args)
    local gameGlobal = game.GetGameGlobalCharacters()
    local chars = table.values(gameGlobal)
    local names = {}
    for _,t in ipairs(chars) do
        names[#names + 1] = t.name or "unnamed token"
    end
    table.sort(names)
    print("THC:: ALLCHARS::", table.concat(names, ", "))
end