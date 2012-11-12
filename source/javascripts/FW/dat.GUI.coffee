instance = undefined

getInstance = ->
  instance ||= new dat.GUI()

FW = @FW ||= {}

FW.dat =
  GUI:
    add: (receiver, property) ->
      getInstance().add(receiver, property)
