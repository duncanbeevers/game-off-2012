class @Player extends FW.ParticleGenerator
  constructor: ->
    super
      maxParticles: 30
      numberOfParticlesToGenerate: ->
        if FW.Math.rand(2) == 0
          1
        else
          0

      generateParticle: ->
        src = FW.Math.sample([
            "images/skulls/skull1.png", "images/skulls/skull2.png", "images/skulls/skull3.png",
            "images/skulls/animalskull1.png", "images/skulls/animalskull2.png", "images/skulls/animalskull3.png", "images/skulls/animalskull4.png"
            ])
        bitmapWidth = 64
        bitmapHeight = bitmapWidth
        particle = new createjs.Bitmap(src)
        particle.regX = bitmapWidth / 2
        particle.regY = bitmapHeight / 2
        particle.x = 0
        particle.y = 0

        vec = FW.Math.random(0, FW.Math.TWO_PI)
        intensity = Math.random(0.5, 1)
        particle.xVel = Math.cos(vec) * intensity / bitmapWidth
        particle.yVel = Math.sin(vec) * intensity / bitmapHeight
        particle.rotationVel = FW.Math.random(-5, 5)
        particle.rotation = FW.Math.random(360)
        particle.scaleX = FW.Math.random(0.1, 0.3) / bitmapWidth
        particle.scaleY = particle.scaleX
        particle


      updateParticle: (particle) ->
        particle.alpha *= 0.92
        particle.scaleX *= 0.99
        particle.scaleY = particle.scaleX
        particle.x += particle.xVel
        particle.y += particle.yVel
        particle.rotation += particle.rotationVel

      isParticleCullable: (particle) ->
        particle.alpha <= 0.02

    reticle = new createjs.Shape()
    @reticle = reticle
    graphics = reticle.graphics
    graphics.clear()

    radius = 0.25
    arrowWidth = radius / 2
    halfArrowWidth = arrowWidth / 2
    arrowHeight = halfArrowWidth

    # graphics.beginStroke("rgba(192, 0, 192, 0.5)")
    # graphics.setStrokeStyle(0.05, "round", "bevel")
    # graphics.drawCircle(0, 0, radius)
    # graphics.endStroke()
    graphics.beginStroke("rgba(192, 0, 192, 0.5)")
    graphics.beginFill("rgba(192, 0, 192, 0.5)")
    graphics.setStrokeStyle(0.01, "round", "bevel")
    graphics.moveTo(-radius, -halfArrowWidth)
    graphics.lineTo(-radius - arrowHeight, 0)
    graphics.lineTo(-radius, halfArrowWidth)
    graphics.lineTo(-radius, -halfArrowWidth)
    graphics.endStroke()
    graphics.endFill()

    @addChild(reticle)

  setThrustAngle: (angle) ->
    @_thrustAngle = angle
    @reticle.rotation = angle * FW.Math.RAD_TO_DEG

  tick: ->
    super()