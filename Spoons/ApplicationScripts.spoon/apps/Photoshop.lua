local obj = {}

obj.id = "com.adobe.Photoshop"

function obj.autoAdjustments(appObj)
  for _, menuitem in ipairs({{"Image", "Auto Tone"}, {"Image", "Auto Color"}, {"Image", "Auto Contrast"}}) do
    appObj:selectMenuItem(menuitem)
  end
end

return obj
