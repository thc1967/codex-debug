local mod = dmhub.GetModLoading()

--- Character Sheet Builder Tab for building a character step by step
CSBuilder = RegisterGameType("DSBuilder")

--[[
    Constants
]]

local DEBUG_PANEL_BG = false

CSBuilder.ROOT_CHAR_SHEET_CLASS = "characterSheetHarness"

CSBuilder.COLORS = {
    BLACK = "#000000",
    CREAM = "#BC9B7B",
    GOLD = "#966D4B",
    GRAY2 = "#666663",
    PANEL_BG = "#080B09",
}

CSBuilder.SIZES = {
    ACTION_BUTTON_WIDTH = 225,
    ACTION_BUTTON_HEIGHT = 45,
    BUTTON_SPACING = 12,
}
CSBuilder.SIZES.BUTTON_PANEL_WIDTH = CSBuilder.SIZES.ACTION_BUTTON_WIDTH + 60
CSBuilder.SIZES.CHARACTER_PANEL_WIDTH = math.floor(1.4 * CSBuilder.SIZES.BUTTON_PANEL_WIDTH)
CSBuilder.SIZES.CENTER_PANEL_WIDTH = "100%-" .. (30 + CSBuilder.SIZES.BUTTON_PANEL_WIDTH + CSBuilder.SIZES.CHARACTER_PANEL_WIDTH)

CSBuilder.STRINGS = {}
CSBuilder.STRINGS.ANCESTRY = {}
CSBuilder.STRINGS.ANCESTRY.OVERVIEW = [[
Fantastic peoples inhabit the worlds of Draw Steel. Among them are devils, dwarves, elves, time raiders--and of course humans, whose culture and history dominates many worlds.

Ancestry describes how you were born. Culture (part of Chapter 4: Background) describes how you grew up. If you want to be a wode elf who was raised in a forest among other wode elves, you can do that! If you want to play a wode elf who was raised in an underground city of dwarves, humans, and orcs, you can do that too!

Your hero is one of these folks! The fantastic ancestry you choose bestows benefits that come from your anatomy and physiology. This choice doesn't grant you cultural benefits, such as crafting or lore skills, though. While many game settings have cultures made of mostly one ancestry, other cultures and worlds have a cosmopolitan mix of peoples.]]

--[[
    Register selectors
]]

CSBuilder.Selectors = {}

function CSBuilder.ClearBuilderTabs()
    CSBuilder.Selectors = {}
end

function CSBuilder.RegisterSelector(selector)
    CSBuilder.Selectors[#CSBuilder.Selectors+1] = selector
    table.sort(CSBuilder.Selectors, function(a,b) return a.ord < b.ord end)
end

--[[
    Styles
]]

function CSBuilder._baseStyles()
    return {
        {
            selectors = {"builder-base"},
            fontSize = 14,
            fontFace = "Newzald",
            color = Styles.textColor,
            bold = false,
        },
        {
            selectors = {"font-black", "builder-base"},
            color = "#000000",
        },
    }
end

function CSBuilder._panelStyles()
    return {
        {
            selectors = {"panel-base", "builder-base"},
            height = "auto",
            width = "auto",
            pad = 2,
            margin = 2,
            bgimage = DEBUG_PANEL_BG and "panels/square.png",
            borderWidth = 1,
            border = DEBUG_PANEL_BG and 1 or 0
        },
        {
            selectors = {"bordered", "panel-base", "builder-base"},
            bgimage = true,
            borderColor = CSBuilder.COLORS.CREAM,
            border = 2,
            cornerRadius = 10,
        },
        {
            selectors = {"builderPanel", "panel-base", "builder-base"},
            bgcolor = CSBuilder.COLORS.PANEL_BG,
        }
    }
end

function CSBuilder._labelStyles()
    return {
        {
            selectors = {"label", "builder-base"},
            textAlignment = "center",
            fontSize = 14,
            color = Styles.textColor,
            bold = false,
        },
    }
end

function CSBuilder._buttonStyles()
    return {
        {
            selectors = {"button", "builder-base"},
            border = 1,
            borderWidth = 1,
        },
        {
            selectors = {"category", "button", "builder-base"},
            width = CSBuilder.SIZES.ACTION_BUTTON_WIDTH,
            height = CSBuilder.SIZES.ACTION_BUTTON_HEIGHT,
            halign = "center",
            valign = "top",
            bmargin = 20,
            fontSize = 24,
            cornerRadius = 5,
            textAlignment = "left",
        },
        {
            selectors = {"available", "button", "builder-base"},
            borderColor = CSBuilder.COLORS.CREAM,
            color = CSBuilder.COLORS.GOLD,
        },
        {
            selectors = {"unavailable", "button", "builder-base"},
            borderColor = CSBuilder.COLORS.GRAY2,
            color = CSBuilder.COLORS.GRAY2,
        }
    }
end

function CSBuilder._inputStyles()
    return {
        {
            selectors = {"text-entry", "builder-base"},
            bgcolor = "#191A18",
            borderColor = "#666663",
        },
        {
            selectors = {"primary", "text-entry", "builder-base"},
            height = 48,
        },
        {
            selectors = {"secondary", "text-entry", "builder-base"},
            height = 36,
        },
    }
end

function CSBuilder._getStyles()
    local styles = {}

    local function mergeStyles(sourceStyles)
        for _, style in ipairs(sourceStyles) do
            styles[#styles + 1] = style
        end
    end

    mergeStyles(CSBuilder._baseStyles())
    mergeStyles(CSBuilder._panelStyles())
    mergeStyles(CSBuilder._labelStyles())
    mergeStyles(CSBuilder._buttonStyles())
    mergeStyles(CSBuilder._inputStyles())

    return styles
end


--[[
    Utilities
]]

function CSBuilder._inCharSheet(element)
    return element:FindParentWithClass(CSBuilder.ROOT_CHAR_SHEET_CLASS) ~= nil
end

function CSBuilder._toArray(t)
    local a = {}
    for _,item in pairs(t) do
        a[#a+1] = item
    end
    return a
end

--[[
    User Interface
]]

function CSBuilder._ancestrySelectorPanel()

    local ancestrySelectorPanel
    local ancestryButtons = {}

    local ancestries = CSBuilder._toArray(dmhub.GetTableVisible(Race.tableName))
    table.sort(ancestries, function(a,b) return a.name < b.name end)
    for _,item in pairs(ancestries) do
        ancestryButtons[#ancestryButtons+1] = gui.SelectorButton{
            valign = "top",
            tmargin = CSBuilder.SIZES.BUTTON_SPACING,
            text = item.name,
            data = { id = item.id },
            available = true,
            create = function(element)
                if CSBuilder._inCharSheet(element) then
                    local creature = CharacterSheet.instance.data.info.token.properties
                    local ancestry = creature:Race()
                    if ancestry then
                        element:FireEvent("setSelected", ancestry.id == element.data.id)
                    end
                end
            end,
            click = function(element)
                print("THC:: ANCESTRY:: CLICK::", element.text, element.data.id)
            end,
        }
    end

    ancestrySelectorPanel = gui.Panel {
        classes = {"collapsed"},
        width = "90%",
        height = "auto",
        valign = "top",
        halign = "right",
        flow = "vertical",
        data = { selector = "ancestry", },
        selectorChange = function(element, selector)
            print(string.format("THC:: SELPANEL:: ANCESTRY:: %s SELCHANGE:: %s", element.data.selector, selector))
            element:SetClass("collapsed", selector ~= element.data.selector)
        end,
        children = ancestryButtons,
    }

    return ancestrySelectorPanel
end

function CSBuilder._careerSelectorPanel()

    local careerSelectorPanel
    local careerButtons = {}

    local careers = CSBuilder._toArray(dmhub.GetTableVisible(Background.tableName))
    table.sort(careers, function(a,b) return a.name < b.name end)
    for _,item in pairs(careers) do
        careerButtons[#careerButtons+1] = gui.SelectorButton{
            valign = "top",
            tmargin = CSBuilder.SIZES.BUTTON_SPACING,
            text = item.name,
            data = { id = item.id },
            available = true,
            create = function(element)
                if CSBuilder._inCharSheet(element) then
                    local creature = CharacterSheet.instance.data.info.token.properties
                    local career = creature:Background()
                    if career then
                        element:FireEvent("setSelected", career.id == element.data.id)
                    end
                end
            end,
            click = function(element)
                print("THC:: CAREER:: CLICK::", element.text, element.data.id)
            end,
        }
    end

    careerSelectorPanel = gui.Panel {
        classes = {"collapsed"},
        width = "90%",
        height = "auto",
        valign = "top",
        halign = "right",
        flow = "vertical",
        data = { selector = "career", },
        selectorChange = function(element, selector)
            print(string.format("THC:: SELPANEL:: CAREER:: %s SELCHANGE:: %s", element.data.selector, selector))
            element:SetClass("collapsed", selector ~= element.data.selector)
        end,
        children = careerButtons,
    }

    return careerSelectorPanel
end

function CSBuilder._classSelectorPanel()

    local classSelectorPanel
    local classButtons = {}

    local classes = CSBuilder._toArray(dmhub.GetTableVisible(Class.tableName))
    table.sort(classes, function(a,b) return a.name < b.name end)
    for _,item in pairs(classes) do
        classButtons[#classButtons+1] = gui.SelectorButton{
            valign = "top",
            tmargin = CSBuilder.SIZES.BUTTON_SPACING,
            text = item.name,
            data = { id = item.id },
            available = true,
            create = function(element)
                if CSBuilder._inCharSheet(element) then
                    local creature = CharacterSheet.instance.data.info.token.properties
                    local class = creature:GetClass()
                    if class then
                        element:FireEvent("setSelected", class.id == element.data.id)
                    end
                end
            end,
            click = function(element)
                print("THC:: CLASS:: CLICK::", element.text, element.data.id)
            end,
        }
    end

    classSelectorPanel = gui.Panel {
        classes = {"collapsed"},
        width = "90%",
        height = "auto",
        valign = "top",
        halign = "right",
        flow = "vertical",
        data = { selector = "class", },
        selectorChange = function(element, selector)
            print(string.format("THC:: SELPANEL:: CLASS:: %s SELCHANGE:: %s", element.data.selector, selector))
            element:SetClass("collapsed", selector ~= element.data.selector)
        end,
        children = classButtons,
    }

    return classSelectorPanel
end

function CSBuilder._selectorsPanel()

    local selectors = {}
    for _,selector in ipairs(CSBuilder.Selectors) do
        selectors[#selectors+1] = selector.selector()
    end

    local selectorsPanel = gui.Panel{
        classes = {"selectorsPanel", "panel-base", "builder-base"},
        width = CSBuilder.SIZES.BUTTON_PANEL_WIDTH,
        height = "99%",
        halign = "left",
        valign = "top",
        flow = "vertical",
        vscroll = true,
        borderColor = "blue",
        data = {
            currentSelector = "",
        },

        selectorClick = function(element, selector)
            if element.data.currentSelector ~= selector then
                local builderPanel = element:FindParentWithClass("builderPanel")
                if builderPanel then
                    builderPanel:FireEventTree("selectorChange", selector)
                end
                element.data.currentSelector = selector
            end
        end,

        children = selectors,
    }

    return selectorsPanel
end

function CSBuilder._ancestryPanel(detailPanel)
    local ancestryPanel

    local function makeCategoryButton(options)
        options.valign = "top"
        options.bmargin = 16
        options.width = CSBuilder.SIZES.ACTION_BUTTON_WIDTH
        return gui.SelectorButton(options)
    end

    local overview = makeCategoryButton{
        text = "Overview",
        data = { selector = "overview" },
        click = function(element)
        end,
    }
    local lore = makeCategoryButton{
        text = "Lore",
        data = { selector = "lore" },
        click = function(element)
        end,
    }
    local features = makeCategoryButton{
        text = "Features",
        data = { selector = "features" },
        click = function(element)
        end,
    }
    local traits = makeCategoryButton{
        text = "Traits",
        data = { selector = "traits" },
        click = function(element)
        end,
    }
    local change = makeCategoryButton{
        text = "Change Ancestry",
        data = { selector = "change" },
        click = function(element)
        end,
    }

    local selectorsPanel = gui.Panel{
        classes = {"selectorsPanel", "panel-base", "builder-base"},
        width = CSBuilder.SIZES.BUTTON_PANEL_WIDTH,
        height = "99%",
        valign = "top",
        vpad = CSBuilder.SIZES.ACTION_BUTTON_HEIGHT,
        flow = "vertical",
        vscroll = true,
        borderColor = "teal",
        data = {
            openPanel = "",
        },

        selectorClick = function(element, selector)
            if element.data.openPanel ~= selector then
                element.data.openPanel = selector
                ancestryPanel.FireEvent("selectorChange", selector)
            end
        end,

        overview,
        lore,
        features,
        traits,
        change,
    }

    local ancestryOverviewPanel = gui.Panel{
        id = "ancestryOverviewPanel",
        classes = {"ancestryOverviewPanel", "bordered", "panel-base", "builder-base"},
        width = "96%",
        height = "99%",
        valign = "center",
        halign = "center",
        bgcolor = "#667788",
        
        gui.Panel{
            width = "100%-2",
            height = "auto",
            valign = "bottom",
            vmargin = 32,
            flow = "vertical",
            bgimage = true,
            bgcolor = "#333333cc",
            vpad = 8,
            gui.Label{
                classes = {"builder-base"},
                width = "100%",
                height = "auto",
                hpad = 12,
                fontSize = 40,
                text = "ANCESTRY",
                textAlignment = "left",
            },
            gui.Label{
                classes = {"label", "builder-base"},
                width = "100%",
                height = "auto",
                hpad = 12,
                bold = false,
                fontSize = 18,
                textAlignment = "left",
                text = CSBuilder.STRINGS.ANCESTRY.OVERVIEW,
            }
        }
    }

    local ancestryDetailPanel = gui.Panel{
        id = "ancestryDetailPanel",
        classes = {"ancestryDetailpanel", "panel-base", "builder-base"},
        width = "80%-" .. CSBuilder.SIZES.BUTTON_PANEL_WIDTH,
        height = "99%",
        valign = "center",
        halign = "center",
        borderColor = "teal",

        ancestryOverviewPanel,
    }

    ancestryPanel = gui.Panel{
        id = "ancestryPanel",
        classes = {"ancestryPanel", "panel-base", "builder-base"},
        width = "100%",
        height = "100%",
        flow = "horizontal",
        valign = "center",
        halign = "center",
        borderColor = "yellow",

        selectorChange = function(element, newSelector)
        end,

        selectorsPanel,
        ancestryDetailPanel,
    }

    return ancestryPanel
end

function CSBuilder._detailPanel(builderPanel)
    local detailPanel

    local ancestryPanel = CSBuilder._ancestryPanel(detailPanel)

    detailPanel = gui.Panel{
        id = "detailPanel",
        classes = {"detailPanel", "panel-base", "builder-base"},
        width = CSBuilder.SIZES.CENTER_PANEL_WIDTH,
        height = "99%",
        valign = "center",
        borderColor = "blue",

        ancestryPanel,
    }

    return detailPanel
end

function CSBuilder._characterPanel(builderPanel)

    local characterPanel

    local popoutAvatar = gui.Panel {
        classes = { "hidden" },
        interactable = false,
        width = 800,
        height = 800,
        halign = "center",
        valign = "center",
        bgcolor = "white",
    }

    local avatar = gui.IconEditor {
        library = cond(dmhub.GetSettingValue("popoutavatars"), "popoutavatars", "Avatar"),
        restrictImageType = "Avatar",
        allowPaste = true,
        borderColor = Styles.textColor,
        borderWidth = 2,
        cornerRadius = 75,
        width = 150,
        height = 150,
        autosizeimage = true,
        halign = "center",
        valign = "top",
        tmargin = 20,
        bgcolor = "white",

        children = { popoutAvatar, },

        thinkTime = 0.2,
        think = function(element)
            element:FireEvent("imageLoaded")
        end,

        updatePopout = function(element, ispopout)
            if not ispopout then
                popoutAvatar:SetClass("hidden", true)
            else
                popoutAvatar:SetClass("hidden", false)
                popoutAvatar.bgimage = element.value
                popoutAvatar.selfStyle.scale = .25
                element.bgimage = false --"panels/square.png"
            end

            local parent = element:FindParentWithClass("avatarSelectionParent")
            if parent ~= nil then
                parent:SetClassTree("popout", ispopout)
            end
        end,

        imageLoaded = function(element)
            if element.bgsprite == nil then
                return
            end

            local maxDim = max(element.bgsprite.dimensions.x, element.bgsprite.dimensions.y)
            if maxDim > 0 then
                local yratio = element.bgsprite.dimensions.x / maxDim
                local xratio = element.bgsprite.dimensions.y / maxDim
                element.selfStyle.imageRect = { x1 = 0, y1 = 1 - yratio, x2 = xratio, y2 = 1 }
            end
        end,

        refreshAppearance = function(element, info)
            print("APPEARANCE:: Set avatar", info.token.portrait)
            element.SetValue(element, info.token.portrait, false)
            element:FireEvent("imageLoaded")
            element:FireEvent("updatePopout", info.token.popoutPortrait)
        end,
        change = function(element)
            -- local info = CharacterSheet.instance.data.info
            -- info.token.portrait = element.value
            -- info.token:UploadAppearance()
            -- CharacterSheet.instance:FireEvent("refreshAll")
            -- element:FireEvent("imageLoaded")
        end,
    }

    local characterName = gui.Label {
        classes = {"label", "builder-base"},
        text = "calculating...",
        width = "98%",
        height = "auto",
        halign = "center",
        valign = "top",
        textAlignment = "center",
        tmargin = 12,
        fontSize = 24,
        editable = true,
        data = {
            inCharSheet = false,
        },
        create = function(element)
            element.data.inCharSheet = CSBuilder._inCharSheet(element) and CharacterSheet.instance and CharacterSheet.instance.data and CharacterSheet.instance.data.info and CharacterSheet.instance.data.info.token
            if element.data.inCharSheet then
                element.text = CharacterSheet.instance.data.info.token.name or "Unnamed Character"
            end
        end,
        change = function(element)
            if element.data.inCharSheet then
                if element.text ~= CharacterSheet.instance.data.info.token.name then
                    CharacterSheet.instance.data.info.token.name = element.text
                    CharacterSheet.instance:FireEventTree("refreshToken", CharacterSheet.instance.data.info)
                end
            end
        end,
    }

    characterPanel = gui.Panel{
        id = "characterPanel",
        classes = {"characterPanel", "bordered", "panel-base", "builder-base"},
        width = CSBuilder.SIZES.CHARACTER_PANEL_WIDTH,
        height = "99%",
        valign = "center",
        -- halign = "right",
        flow = "vertical",

        avatar,
        characterName,
    }

    return characterPanel
end

function CSBuilder.CreatePanel()

    local builderPanel

    local selectorsPanel = CSBuilder._selectorsPanel(builderPanel)
    local detailPanel = CSBuilder._detailPanel(builderPanel)
    local characterPanel = CSBuilder._characterPanel(builderPanel)

    builderPanel = gui.Panel{
        id = "builderPanel",
        styles = CSBuilder._getStyles(),
        classes = {"builderPanel", "panel-base", "builder-base"},
        width = "99%",
        height = "99%",
        halign = "center",
        valign = "center",
        flow = "horizontal",
        borderColor = "red",

        selectorChange = function(element, newSelector)
        end,

        selectorsPanel,
        detailPanel,
        characterPanel,
    }

    return builderPanel
end

function CSBuilder._makeSelectorButton(options)
    options.valign = "top"
    options.tmargin = CSBuilder.SIZES.BUTTON_SPACING
    options.available = true
    if options.click == nil then
        options.click = function(element)
            local selectorsPanel = element:FindParentWithClass("selectorsPanel")
            if selectorsPanel then
                selectorsPanel:FireEvent("selectorClick", element.data.selector)
            end
        end
    end
    if options.selectorChange == nil then
        options.selectorChange = function(element, selector)
            element:FireEvent("setSelected", selector == element.data.selector)
        end
    end
    return gui.ActionButton(options)
end

function CSBuilder._backSelector()
    return CSBuilder._makeSelectorButton{
        text = "BACK",
        data = { selector = "back" },
        create = function(element)
            element:SetClass("collapsed", CSBuilder._inCharSheet(element))
        end,
        click = function(element)
            print("THC:: TODO:: Not in CharSheet. Close the window, probably?")
        end,
    }
end

function CSBuilder._characterSelector()
    return CSBuilder._makeSelectorButton{
        text = "Character",
        data = { selector = "character" },
    }
end

function CSBuilder._ancestrySelector()

    local selectorButton = CSBuilder._makeSelectorButton{
        text = "Ancestry",
        data = { selector = "ancestry" },
        selectorChange = function(element, selector)
            local selfSelected = selector == element.data.selector
            local parentPane = element:FindParentWithClass("ancestry-selector")
            if parentPane then
                element:FireEvent("setSelected", selfSelected)
                parentPane:FireEvent("showDetail", selfSelected)
            end
        end,
    }

    local selector = gui.Panel{
        classes = {"ancestry-selector"},
        width = "100%",
        height = "auto",
        pad = 0,
        margin = 0,
        flow = "vertical",
        data = { detailPane = nil },

        showDetail = function(element, show)
            if show then
                if not element.data.detailPane then
                    element.data.detailPane = CSBuilder._ancestrySelectorPanel()
                    element:AddChild(element.data.detailPane)
                end
            end
            if element.data.detailPane then
                element.data.detailPane:SetClass("collapsed", not show)
            end
        end,

        children = {
            selectorButton
        },
    }

    return selector
end

function CSBuilder._cultureSelector()
    return CSBuilder._makeSelectorButton{
        text = "Culture",
        data = { selector = "culture" },
    }
end

function CSBuilder._careerSelector()

    local selectorButton = CSBuilder._makeSelectorButton{
        text = "Career",
        data = { selector = "career" },
        selectorChange = function(element, selector)
            local selfSelected = selector == element.data.selector
            local parentPane = element:FindParentWithClass("career-selector")
            if parentPane then
                element:FireEvent("setSelected", selfSelected)
                parentPane:FireEvent("showDetail", selfSelected)
            end
        end,
    }

    local selector = gui.Panel{
        classes = {"career-selector"},
        width = "100%",
        height = "auto",
        pad = 0,
        margin = 0,
        flow = "vertical",
        data = { detailPane = nil },

        showDetail = function(element, show)
            if show then
                if not element.data.detailPane then
                    element.data.detailPane = CSBuilder._careerSelectorPanel()
                    element:AddChild(element.data.detailPane)
                end
            end
            if element.data.detailPane then
                element.data.detailPane:SetClass("collapsed", not show)
            end
        end,

        children = {
            selectorButton
        },
    }

    return selector
end

function CSBuilder._classSelector()

    local selectorButton = CSBuilder._makeSelectorButton{
        text = "Class",
        data = { selector = "class" },
        selectorChange = function(element, selector)
            local selfSelected = selector == element.data.selector
            local parentPane = element:FindParentWithClass("class-selector")
            if parentPane then
                element:FireEvent("setSelected", selfSelected)
                parentPane:FireEvent("showDetail", selfSelected)
            end
        end,
    }

    local selector = gui.Panel{
        classes = {"class-selector"},
        width = "100%",
        height = "auto",
        pad = 0,
        margin = 0,
        flow = "vertical",
        data = { detailPane = nil },

        showDetail = function(element, show)
            if show then
                if not element.data.detailPane then
                    element.data.detailPane = CSBuilder._classSelectorPanel()
                    element:AddChild(element.data.detailPane)
                end
            end
            if element.data.detailPane then
                element.data.detailPane:SetClass("collapsed", not show)
            end
        end,

        children = {
            selectorButton
        },
    }

    return selector
end

function CSBuilder._kitSelector()
    return CSBuilder._makeSelectorButton{
        text = "Kit",
        data = { selector = "kit" },
    }
end

function CSBuilder._complicationSelector()
    return CSBuilder._makeSelectorButton{
        text = "Complication",
        data = { selector = "complication" },
    }
end

CSBuilder.RegisterSelector{
    id = "back",
    ord = 1,
    selector = CSBuilder._backSelector
}

CSBuilder.RegisterSelector{
    id = "character",
    ord = 2,
    selector = CSBuilder._characterSelector
}

CSBuilder.RegisterSelector{
    id = "ancestry",
    ord = 3,
    selector = CSBuilder._ancestrySelector
}

CSBuilder.RegisterSelector{
    id = "culture",
    ord = 4,
    selector = CSBuilder._cultureSelector
}

CSBuilder.RegisterSelector{
    id = "career",
    ord = 5,
    selector = CSBuilder._careerSelector
}

CSBuilder.RegisterSelector{
    id = "class",
    ord = 6,
    selector = CSBuilder._classSelector
}

CSBuilder.RegisterSelector{
    id = "kit",
    ord = 7,
    selector = CSBuilder._kitSelector
}

CSBuilder.RegisterSelector{
    id = "complication",
    ord = 8,
    selector = CSBuilder._complicationSelector
}

-- TODO: Remove the gate on dev mode
if dmhub.GetSettingValue("dev") then

--- Our tab in the character sheet
CharSheet.RegisterTab {
    id = "builder2",
    text = "Builder (WIP)",
	visible = function(c)
		return c ~= nil and c:IsHero()
	end,
    panel = CSBuilder.CreatePanel
}
dmhub.RefreshCharacterSheet()

end
