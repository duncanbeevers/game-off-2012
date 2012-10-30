FW = @FW ||= {}

class FW.ParticleGenerator extends FW.ContainerProxy
  constructor: (options) ->
    super()

    @_particles = []

    @maxParticles                = options.maxParticles
    @numberOfParticlesToGenerate = options.numberOfParticlesToGenerate
    @generateParticle            = options.generateParticle
    @updateParticle              = options.updateParticle
    @isParticleCullable          = options.isParticleCullable
    @absolutePlacement           = options.absolutePlacement

  tick: ->
    particles = @_particles

    if @absolutePlacement
      container = @parent
    else
      container = @_container

    particlesToKeep = []
    for particle in particles
      @updateParticle(particle)
      if @isParticleCullable(particle)
        container.removeChild(particle)
      else
        particlesToKeep.push(particle)

    @_particles = particles = particlesToKeep

    numToGenerate = Math.min(@numberOfParticlesToGenerate(), @maxParticles - particles.length)
    if numToGenerate > 0
      for i in [1..numToGenerate]
        particle = @generateParticle()
        if @absolutePlacement
          particle.x += @x
          particle.y += @y

        particles.push(particle)
        container.addChild(particle)
