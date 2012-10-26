FW = @FW ||= {}

class FW.ParticleGenerator extends FW.ContainerProxy
  constructor: (options) ->
    super()

    @x = 0
    @y = 0
    @_particles = []

    @maxParticles                = options.maxParticles
    @numberOfParticlesToGenerate = options.numberOfParticlesToGenerate
    @generateParticle            = options.generateParticle
    @updateParticle              = options.updateParticle
    @isParticleCullable          = options.isParticleCullable

  tick: ->
    @_container.x = @x
    @_container.y = @y

    particlesToKeep = []
    for particle in @_particles
      @updateParticle(particle)
      if @isParticleCullable(particle)
        @_container.removeChild(particle)
      else
        particlesToKeep.push(particle)

    @_particles = particlesToKeep

    numToGenerate = Math.min(@numberOfParticlesToGenerate(), @maxParticles - @_particles.length)
    if numToGenerate > 0
      for i in [1..numToGenerate]
        particle = @generateParticle()
        @_particles.push(particle)
        @_container.addChild(particle)
