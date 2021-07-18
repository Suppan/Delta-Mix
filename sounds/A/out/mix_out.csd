
<CsoundSynthesizer>
<CsOptions>
-o "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/out/mix_out.wav"
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
i1    0.000   2.010544   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/4-ugly-horn.wav"
i1    4.328   3.674014   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/2-machine-noise1.wav"
i1    6.493   2.524603   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/3-machine-noise2.wav"
i1   17.313   7.735147   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/8-children.wav"
i1   21.642   3.721088   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/6-kung-fu.wav"
i1   23.806   6.971111   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/7-car-stop.wav"
i1   36.791   3.720408   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/1-water-splash.wav"
i1   45.448   4.446667   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/5-crowd.wav"
i1   56.269   9.453333   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/DeltaMix-0.22/sounds/A/0-sticks.wav" 
e
</CsScore>
</CsoundSynthesizer>
