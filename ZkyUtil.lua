local _, _addon = ...

isDevelopment = true;

function devPrint(...) if (isDevelopment) then print(...) end end

function MakeCheckbox(frame, name, sizeX, sizeY)
    local cb = CreateFrame('CheckButton', name, frame)
    cb:SetNormalTexture([[Interface\Buttons\UI-CheckBox-Up]])
    cb:SetPushedTexture([[Interface\Buttons\UI-CheckBox-Down]])
    cb:SetHighlightTexture([[Interface\Buttons\UI-CheckBox-Highlight]], 'ADD')
    cb:SetCheckedTexture([[Interface\Buttons\UI-CheckBox-Check]])
    cb:SetDisabledCheckedTexture([[Interface\Buttons\UI-CheckBox-Check-Disabled]])
    cb:SetSize(sizeX, sizeY)
    return cb
end

