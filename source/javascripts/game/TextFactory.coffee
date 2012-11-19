@TextFactory =
  create: (text, color) ->
    t              = new createjs.Text(text)
    t.font         = "48px Upheaval"
    t.textAlign    = "center"
    t.textBaseline = "middle"
    t.color        = color || "#FFFFFF"

    t
