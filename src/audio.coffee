window.Audio =
  constructor: ->
    @tags = {}

  play: (name) ->
  	try
      tag = tags[name]
      if not tag
        tag = document.createElement 'audio'
        source = document.createElement 'source'
        source.src = "assets/audio/#{name}.ogg"
        tag.appendChild source
    	tag.play()
    catch e
      console.log 'play failed:', e
