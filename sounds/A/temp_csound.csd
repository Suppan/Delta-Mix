
<CsoundSynthesizer>
<CsOptions>
-o "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/out/mix_out.wav"
</CsOptions>
<CsInstruments>

sr   =   44100
ksmps   =   32
nchnls   =   2  

0dbfs = 1

instr 1

itransp = p4
imul = ampdbfs(p5)
Sfilepath = p6

ichn filenchnls Sfilepath
ispeed = powoftwo(itransp / 12)

if ichn == 2 then
aL, aR diskin2 Sfilepath, ispeed, 0, 0, 0, 32
outs aL*imul ,aR*imul
else
aL diskin2 Sfilepath, ispeed, 0, 0, 0, 32
outs aL*imul, aL*imul
endif
  endin
</CsInstruments>

<CsScore>
i1    0.000  27.884444 -24   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/7-car-stop.wav"
i1    0.637   30.94059 -24   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/8-children.wav"
i1    7.003  14.884354 -24   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/6-kung-fu.wav"
i1   14.643  14.696054 -24   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/2-machine-noise1.wav"
i1   19.736  37.813333 -24   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/0-sticks.wav"
i1   24.830  17.786667 -24 -20.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/5-crowd.wav"
i1   29.923  14.881633 -24 -20.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/1-water-splash.wav"
i1   36.290  10.098413 -24 -20.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/3-machine-noise2.wav"
i1   42.656   8.042177 -24   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/4-ugly-horn.wav"

e
</CsScore>
</CsoundSynthesizer>
