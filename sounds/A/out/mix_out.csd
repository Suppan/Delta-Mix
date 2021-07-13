
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
i1    0.000   3.674014   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/2-machine-noise1.wav"
i1    9.477   9.453333   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/0-sticks.wav"
i1   37.907   3.721088   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/6-kung-fu.wav"
i1   42.646   6.971111   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/7-car-stop.wav"
i1   56.861   2.010544   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/4-ugly-horn.wav"
i1   66.338   3.721088   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/6-kung-fu.wav"
i1   75.815   2.010544   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/4-ugly-horn.wav"
i1   90.030   6.971111   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/7-car-stop.wav"
i1  123.199   9.453333   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/0-sticks.wav"
i1  156.368   6.971111   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/7-car-stop.wav"
i1  161.107   3.721088   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/6-kung-fu.wav"
i1  165.845   4.446667   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/5-crowd.wav"
i1  180.060   7.735147   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/8-children.wav"
i1  213.229   3.720408   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/1-water-splash.wav"
i1  232.183   4.446667   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/5-crowd.wav"
i1  251.137   3.720408   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/1-water-splash.wav"
i1  255.875   9.453333   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/0-sticks.wav"
i1  284.306   3.721088   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/6-kung-fu.wav"
i1  293.783   2.010544   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/4-ugly-horn.wav"
i1  298.521   4.446667   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/5-crowd.wav"
i1  317.475   3.720408   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.22/sounds/A/1-water-splash.wav"

e
</CsScore>
</CsoundSynthesizer>
