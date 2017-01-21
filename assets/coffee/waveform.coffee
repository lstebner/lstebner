class Waveform
  constructor: (container, @opts={}) ->
    @container = $ container
    @wavesurfer = WaveSurfer.create
      container: @container[0]
      waveColor: "violet"
      progressColor: "purple"
      height: 700

    @wavesurfer.load "/audio/52beats2017/mpcbeat170107.mp3"


document.Waveform = Waveform
