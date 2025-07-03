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

local default_lowtemp = 215
local default_hightemp = 50
local default_intensity = 40
local default_peak = 60
local default_sway = 60
local default_slots = 7

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
  complementaryColors[2] = shiftHue(baseColor, 0.5)

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
      title="ヘルプ",
      text={
          "ツール説明:",
          "- ベース: ベースカラーをクリックするとパレットが生成されます。",
          "- 「取得」: 現在のFG/BGを使ってベースカラーを更新し、シェードを再生成します。",
          "",
          "スウォッチでのマウス操作:",
          "- 左クリック: FGカラーとして設定。",
          "- 右クリック: BGカラーとして設定。",
          "- 中クリック: 最後に変更したカラーに応じて設定し、再生成します。",
          "",
          "高度なコントロール:",
          "- ダーク温度/ライト温度: 暗い/明るいシェードの暖色/寒色調整。",
          "- 強度: シェードの彩度グラデーションを追加。",
          "- ピーク: 最も明るいシェードの明るさ調整。",
          "- スウェイ: 温度シフトの影響度を調整。",
          "- スロット: 生成されるスウォッチの数。",
          "",
          "カラーハーモニー（調和）オプション: 補色、三分割、四分割配色の提案。",
          "",
          "自動取得: 有効にすると、FG/BGの変更時に自動的にパレットを更新。",
          "高度: 高度なコントロールの表示切替。",
          "",
          "リセット: パラメータをデフォルトに戻します。"
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
      title = "カラーシェード",
      onclose = function()
          app.events:off(fgListenerCode)
          app.events:off(bgListenerCode)
      end
  }

  dlg:shades{
      id = "base",
      label = "ベース",
      colors = {FGcache, BGcache},
      onclick = function(ev)
          lastColor = ev.color
          calculateColors(ev.color)
          updateDialogData()
      end
  }
  :button{
      id = "get",
      text = "取得",
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
      label = "シェード",
      onclick = onShadesClick
  }
  :shades{
      id = "lit",
      label = "ライト",
      onclick = onShadesClick
  }
  :shades{
      id = "sat",
      label = "彩度",
      onclick = onShadesClick
  }
  :shades{
      id = "mix",
      label = "ミックス",
      onclick = onShadesClick
  }
  :shades{
      id = "nuance",
      label = "ニュアンス",
      onclick = onShadesClick
  }
  :shades{
      id = "hue",
      label = "色相",
      onclick = onShadesClick
  }
  :newrow()
  :slider{
      id = "lowtemp",
      label = "ダーク温度",
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
      label = "ライト温度",
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
      label = "強度",
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
      label = "ピーク",
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
      label = "スウェイ",
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
      label = "スロット",
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
      text = "自動取得",
      selected = autoPick,
      onclick = function() autoPick = not autoPick end
  }
  :check{
      id = "mode2",
      text = "高度",
      selected = advanced,
      onclick = function()
          advanced = not advanced
          updateDialogData()
      end
  }
  :newrow()
  :check{
      id="mode3",
      text="カラーハーモニー",
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
      text = "リセット",
      onclick = resetValues
  }
  :button{
      id="helpBtn",
      text="?",
      tooltip="ヘルプ",
      onclick=showHelp
  }
  :shades{
      id = "comp",
      label = "補色",
      colors = {},
      visible = false,
      onclick = onShadesClick
  }
  :shades{
      id = "triad",
      label = "三分割",
      colors = {},
      visible = false,
      onclick = onShadesClick
  }
  :shades{
      id = "tetrad",
      label = "四分割",
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
