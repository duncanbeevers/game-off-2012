class @Pup extends FW.ParticleGenerator
  maxParticles: 30
  numberOfParticlesToGenerate: -> 1

  generateParticle: ->
    new createjs.Shape()

  initializeParticle: (particle) ->
    particle.alpha = 1
    particle.x = 0
    particle.y = 0
    particle.rotationVel = FW.Math.random(-5, 5)

    graphics = particle.graphics
    graphics.clear()

    graphics.beginFill("rgba(255, 0, 0, 0.8)")
    graphics.drawCircle(FW.Math.random(-0.1, 0.1), FW.Math.random(-0.1, 0.1), 0.5)
    graphics.endFill()

  updateParticle: (particle) ->
    particle.alpha *= 0.92
    # particle.scaleX *= 0.99
    # particle.scaleY = particle.scaleX
    # particle.x += particle.xVel
    # particle.y += particle.yVel
    particle.rotation += particle.rotationVel

  isParticleCullable: (particle) ->
    particle.alpha <= 0.02
