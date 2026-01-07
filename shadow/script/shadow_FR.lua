local dlg
local autoPick = true
local advanced = true
local advanced2 = false
local fgListenerCode
local bgListenerCode
local eyeDropper = true
local slots = 7
local shadingColors = {}
local lighthessColors = {}
local saturationColors = {}
local nuanceColors = {}
local mixedColors = {}
local hueColors = {}
local complementaryColors = {}
local triadicColors = {}
local tetradicColors = {}
local lastColor

-- Valeurs par défaut
local default_lowtemp = 215
local default_hightemp = 50
local default_intensity = 40
local default_peak = 60
local default_sway = 60
local default_slots = 7

-- Fonctions auxiliaires
local function lerp(first, second, by)
  return first * (1 - by) + second * by
end

local function shiftHue(color, amount)
  local newColor = Color(color)
  newColor.hue = (newColor.hue + amount * 360) % 360
  return newColor
end

local function shiftSaturation(color, amount)
  local newColor = Color(color)
  if (amount > 0) then
    newColor.saturation = lerp(newColor.saturation, 1, amount)
  elseif (amount < 0) then
    newColor.saturation = lerp(newColor.saturation, 0, -amount)
  end
  return newColor
end

local function shiftLightness(color, amount)
  local newColor = Color(color)
  if (amount > 0) then
    newColor.lightness = lerp(newColor.lightness, 1, amount)
  elseif (amount < 0) then
    newColor.lightness = lerp(newColor.lightness, 0, -amount)
  end
  return newColor
end

local function shiftHSL(color, hue, saturation, lightness)
  return shiftHue(
    shiftSaturation(shiftLightness(color, lightness), saturation),
    hue)
end

local function mixColors(color1, color2, proportion)
  return Color {
    red = lerp(color1.red, color2.red, proportion),
    green = lerp(color1.green, color2.green, proportion),
    blue = lerp(color1.blue, color2.blue, proportion)
  }
end

local function shiftShading(color, hue, proportion)
  local hueShifted = Color(color)
  hueShifted.hue = hue
  return mixColors(color, hueShifted, proportion)
end

local function calculateAdvanced2Colors(baseColor)
  complementaryColors = {}
  triadicColors = {}
  tetradicColors = {}

  complementaryColors[1] = baseColor
  complementaryColors[2] = shiftHue(baseColor, 0.5) -- 180°

  triadicColors[1] = baseColor
  triadicColors[2] = shiftHue(baseColor, 120/360)
  triadicColors[3] = shiftHue(baseColor, 240/360)

  tetradicColors[1] = baseColor
  tetradicColors[2] = shiftHue(baseColor, 90/360)
  tetradicColors[3] = shiftHue(baseColor, 180/360)
  tetradicColors[4] = shiftHue(baseColor, 270/360)
end

local function calculateColors(baseColor)
  local intensity = dlg and dlg.data and dlg.data.intensity or default_intensity
  local peak = dlg and dlg.data and dlg.data.peak or default_peak
  local sway = dlg and dlg.data and dlg.data.sway or default_sway
  local lowtemp = dlg and dlg.data and dlg.data.lowtemp or default_lowtemp
  local hightemp = dlg and dlg.data and dlg.data.hightemp or default_hightemp

  shadingColors = {}
  lighthessColors = {}
  saturationColors = {}
  nuanceColors = {}
  mixedColors = {}
  hueColors = {}

  for i = 1, slots do
    mixedColors[i] = mixColors((FGcache or app.fgColor), (BGcache or app.bgColor), 1 / (slots + 1) * i)
    hueColors[i] = shiftHue(baseColor, 1 / (slots + 1) * i)

    if i == (slots + 1) / 2 then
      shadingColors[i] = baseColor
      lighthessColors[i] = baseColor
      saturationColors[i] = baseColor
      nuanceColors[i] = baseColor
    else
      local factor = ((slots - 1) / 2 - i + 1) / ((slots - 1) / 2)
      local neg = -1
      local temp = lowtemp
      if i > slots / 2 then
        factor = (-1) * factor
        neg = 1
        temp = hightemp
      end
      shadingColors[i] = shiftShading(
        shiftHSL(baseColor, 0,
          intensity / 100 * factor,
          peak / 100 * factor * neg),
        temp, sway / 100 * factor)
      lighthessColors[i] = shiftLightness(baseColor, 0.4 * factor * neg)
      saturationColors[i] = shiftSaturation(baseColor, 0.75 * factor * neg)
      nuanceColors[i] = shiftHue(baseColor, ((slots + 1) / 2 - i) * 1 /
                                          (slots + 1) * 2 / (slots + 1))
    end
  end

  if advanced2 then
    calculateAdvanced2Colors(baseColor)
  end
end

local function updateDialogData()
  if not dlg then return end
  dlg:modify{id = "base", colors = {FGcache, BGcache}}
  dlg:modify{id = "sha", colors = shadingColors}
  dlg:modify{id = "lit", colors = lighthessColors}
  dlg:modify{id = "sat", colors = saturationColors}
  dlg:modify{id = "nuance", colors = nuanceColors}
  dlg:modify{id = "mix", colors = mixedColors}
  dlg:modify{id = "hue", colors = hueColors}

  dlg:modify{id = "intensity", visible = advanced}
  dlg:modify{id = "peak", visible = advanced}
  dlg:modify{id = "sway", visible = advanced}
  dlg:modify{id = "slots", visible = advanced}

  if advanced2 then
    dlg:modify{id = "comp", visible = true, colors = complementaryColors}
    dlg:modify{id = "triad", visible = true, colors = triadicColors}
    dlg:modify{id = "tetrad", visible = true, colors = tetradicColors}
  else
    dlg:modify{id = "comp", visible = false}
    dlg:modify{id = "triad", visible = false}
    dlg:modify{id = "tetrad", visible = false}
  end
end

local function onShadesClick(ev)
  eyeDropper = false
  if (ev.button == MouseButton.LEFT) then
      app.fgColor = ev.color
  elseif (ev.button == MouseButton.MIDDLE) then
      if FGcache == lastColor then
          app.fgColor = ev.color
          FGcache = ev.color
      else
          app.bgColor = ev.color
          BGcache = ev.color
      end
      lastColor = ev.color
      calculateColors(ev.color)
      updateDialogData()
  elseif (ev.button == MouseButton.RIGHT) then
      app.bgColor = ev.color
  end
end

local function resetValues()
  dlg:modify{id = "lowtemp", value = default_lowtemp}
  dlg:modify{id = "hightemp", value = default_hightemp}
  dlg:modify{id = "intensity", value = default_intensity}
  dlg:modify{id = "peak", value = default_peak}
  dlg:modify{id = "sway", value = default_sway}
  dlg:modify{id = "slots", value = default_slots}

  slots = default_slots
  calculateColors(lastColor)
  updateDialogData()
end

local function showHelp()
  app.alert{
      title="Aide",
      text={
          "Description de l'outil :",
          "- Base : Cliquer sur une couleur de base change la palette générée.",
          "- \"Obtenir\" : Met à jour les couleurs de base avec le premier plan/arrière-plan actuel.",
          "",
          "Actions de la Souris sur un échantillon :",
          "- Clic Gauche : Définit la couleur comme Premier plan (FG).",
          "- Clic Droit : Définit la couleur comme Arrière-plan (BG).",
          "- Clic Milieu : Définit la couleur selon le dernier changement (FG ou BG) et régénère.",
          "",
          "Contrôles Avancés :",
          "- Temp. Sombre/Claire : Ajuste les teintes chaudes/froides pour les ombres.",
          "- Intensité : Ajoute un gradient de saturation aux nuances.",
          "- Pic : Contrôle la luminosité maximale des teintes claires.",
          "- Oscillation : Ajuste l'influence des changements de température sur les couleurs.",
          "- Niveaux : Change le nombre d'échantillons de couleur générés.",
          "",
          "Harmonies : Affiche des combinaisons harmoniques (Compl., Triade, Tétrade).",
          "",
          "Sélection Auto : Si activé, les changements FG/BG mettent à jour la palette.",
          "Avancé : Affiche ou masque les contrôles avancés.",
          "",
          "Réinitialiser : Retourne les paramètres aux valeurs par défaut."
      }
  }
end

local function onFBGChange(fg)
  return function()
      if (eyeDropper == true and autoPick == true) then
          local col
          if fg then
              col = app.fgColor
              FGcache = col
          else
              col = app.bgColor
              BGcache = col
          end
          calculateColors(col)
          lastColor = col
          updateDialogData()
      end
      eyeDropper = true
  end
end

local function createDialog()
  FGcache = app.fgColor
  BGcache = app.bgColor
  lastColor = FGcache

  dlg = Dialog {
      title = "Nuances de Couleur",
      onclose = function()
          app.events:off(fgListenerCode)
          app.events:off(bgListenerCode)
      end
  }

  dlg:shades{
      id = "base",
      label = "Base",
      colors = {FGcache, BGcache},
      onclick = function(ev)
          lastColor = ev.color
          calculateColors(ev.color)
          updateDialogData()
      end
  }
  :button{
      id = "get",
      text = "Obtenir",
      onclick = function()
        local cacheLastColor = lastColor
        FGcache = app.fgColor
        BGcache = app.bgColor
          if cacheLastColor == BGcache then
            lastColor = app.bgColor
            calculateColors(BGcache)
            lastColor = app.fgColor
            calculateColors(FGcache)
          else
            lastColor = app.fgColor
            calculateColors(FGcache)
          end
          updateDialogData()
      end
  }
  :shades{
      id = "sha",
      label = "Ombre",
      onclick = onShadesClick
  }
  :shades{
      id = "lit",
      label = "Lumière",
      onclick = onShadesClick
  }
  :shades{
      id = "sat",
      label = "Sat.",
      onclick = onShadesClick
  }
  :shades{
      id = "mix",
      label = "Mélange",
      onclick = onShadesClick
  }
  :shades{
      id = "nuance",
      label = "Nuance",
      onclick = onShadesClick
  }
  :shades{
      id = "hue",
      label = "Teinte",
      onclick = onShadesClick
  }
  :newrow()
  :slider{
      id = "lowtemp",
      label = "Temp. Sombre",
      min = 0,
      max = 359.999,
      value = default_lowtemp,
      onchange = function()
          dlg:modify{
              id = "lowtempcol",
              color = Color {
                  hue = dlg.data.lowtemp,
                  saturation = 1,
                  lightness = 0.5
              }
          }
          calculateColors(lastColor)
          updateDialogData()
      end
  }
  :slider{
      id = "hightemp",
      label = "Temp. Claire",
      min = 0,
      max = 359.999,
      value = default_hightemp,
      onchange = function()
          dlg:modify{
              id = "hightempcol",
              color = Color {
                  hue = dlg.data.hightemp,
                  saturation = 1,
                  lightness = 0.5
              }
          }
          calculateColors(lastColor)
          updateDialogData()
      end
  }
  :newrow()
  :color{
      id = "lowtempcol",
      color = Color {
          hue = default_lowtemp,
          saturation = 1,
          lightness = 0.5
      },
      onchange = function()
          dlg:modify{
              id = "lowtemp",
              value = dlg.data.lowtempcol.hue
          }
      end
  }
  :color{
      id = "hightempcol",
      color = Color {
          hue = default_hightemp,
          saturation = 1,
          lightness = 0.5
      },
      onchange = function()
          dlg:modify{
              id = "hightemp",
              value = dlg.data.hightempcol.hue
          }
      end
  }
  :slider{
      id = "intensity",
      label = "Intensité",
      min = 1,
      max = 200,
      value = default_intensity,
      onchange = function()
          calculateColors(lastColor)
          updateDialogData()
      end
  }
  :slider{
      id = "peak",
      label = "Pic",
      min = 1,
      max = 100,
      value = default_peak,
      onchange = function()
          calculateColors(lastColor)
          updateDialogData()
      end
  }
  :slider{
      id = "sway",
      label = "Oscillation",
      min = 1,
      max = 100,
      value = default_sway,
      onchange = function()
          calculateColors(lastColor)
          updateDialogData()
      end
  }
  :slider{
      id = "slots",
      label = "Niveaux",
      min = 3,
      max = 25,
      value = default_slots,
      onchange = function()
          local value = dlg.data.slots
          if value % 2 == 0 then
              dlg:modify{id = "slots", value = value + 1}
          end
          slots = dlg.data.slots
          calculateColors(lastColor)
          updateDialogData()
      end
  }

  :newrow()
  :check{
      id = "mode",
      text = "Sélection Auto",
      selected = autoPick,
      onclick = function() autoPick = not autoPick end
  }
  :check{
      id = "mode2",
      text = "Avancé",
      selected = advanced,
      onclick = function()
          advanced = not advanced
          updateDialogData()
      end
  }

  :newrow()
  :check{
      id="mode3",
      text="Harmonies",
      selected=advanced2,
      onclick=function()
          advanced2 = not advanced2
          calculateColors(lastColor)
          updateDialogData()
      end
  }

  :newrow()
  :button{
      id = "reset",
      text = "Réinitialiser",
      onclick = resetValues
  }
  :button{
      id="helpBtn",
      text="?",
      tooltip="Aide",
      onclick=showHelp
  }

  :shades{
      id = "comp",
      label = "Compl.",
      colors = {},
      visible = false,
      onclick = onShadesClick
  }
  :shades{
      id = "triad",
      label = "Triade",
      colors = {},
      visible = false,
      onclick = onShadesClick
  }
  :shades{
      id = "tetrad",
      label = "Tétrade",
      colors = {},
      visible = false,
      onclick = onShadesClick
  }

  dlg:show{wait = false}
end

fgListenerCode = app.events:on('fgcolorchange', onFBGChange(true))
bgListenerCode = app.events:on('bgcolorchange', onFBGChange(false))

FGcache = app.fgColor
BGcache = app.bgColor
lastColor = FGcache
createDialog()
calculateColors(app.fgColor)
updateDialogData()
