
<CsoundSynthesizer>
<CsOptions>
-o "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/out/mix_out.wav"
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
i1    0.000   7.348027 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/2-machine-noise1.wav"
i1   12.491  15.470295 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/8-children.wav"
i1   18.737   8.893333 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/5-crowd.wav"
i1   22.901  13.942222 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/7-car-stop.wav"
i1   37.474  18.906667 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/0-sticks.wav"
i1   45.801   4.021088 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/4-ugly-horn.wav"
i1   47.883   5.049206 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/3-machine-noise2.wav"
i1   52.047   7.440816 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/1-water-splash.wav"
i1   62.456   7.442177 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/6-kung-fu.wav"

e
</CsScore>
</CsoundSynthesizer>
