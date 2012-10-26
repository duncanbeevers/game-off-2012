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
        particle = new createjs.Bitmap(src)
        particle.regX = 32
        particle.regY = 32
        particle.x = 0
        particle.y = 0
        particle.xVel = FW.Math.random(-1, 1)
        particle.yVel = FW.Math.random(-1, 1)
        particle.rotationVel = FW.Math.random(-5, 5)
        particle.rotation = FW.Math.random(360)
        particle.scaleX = FW.Math.random(0.5, 1)
        particle.scaleY = particle.scaleX
        particle


      updateParticle: (particle) ->
        particle.alpha *= 0.9
        particle.scaleX *= 0.99
        particle.scaleY = particle.scaleX
        particle.x += particle.xVel
        particle.y += particle.yVel
        particle.rotation += particle.rotationVel

      isParticleCullable: (particle) ->
        particle.alpha <= 0.02
