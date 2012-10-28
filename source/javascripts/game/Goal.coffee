class @Goal extends FW.ParticleGenerator
  constructor: ->
    super
      maxParticles: 30
      numberOfParticlesToGenerate: -> FW.Math.rand(2)
      generateParticle: ->
        src = FW.Math.sample([ "images/goal/star1.png" ])
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
