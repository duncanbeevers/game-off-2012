FW = @FW ||= {}

class FW.ParticleGenerator
  constructor: (options) ->
    container = new createjs.Container()
    @x = 0
    @y = 0
    @maxParticles = options.maxParticles
    @numberOfParticlesToGenerate = options.numberOfParticlesToGenerate
    @generateParticle = options.generateParticle
    @updateParticle = options.updateParticle
    @isParticleCullable = options.isParticleCullable

    parent = undefined
    Object.defineProperty @, 'parent'
      get: ->
        parent
      set: (value) ->
        if parent
          parent.removeChild(container)
        parent = value
        if parent
          parent.addChild(container)

    @_particles = []
    @_container = container

  isVisible: ->
    @_container.isVisible()

  updateContext: (context) ->
    # debugger
    # @_container.updateContext(context)
  draw: (context) ->

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
