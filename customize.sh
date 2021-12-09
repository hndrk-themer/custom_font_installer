. $MODPATH/ohmyfont.sh

gfi_dl() {
    local family=`echo $@ | sed 's| |%20|g'`
    font=`echo $@ | sed 's| ||g'`
    local link="https://fonts.google.com/download?family=$family"
    local zipfile=`echo $@ | sed 's| |_|g'`.zip
    local zip=$OMFDIR/$zipfile
    local time=`valof GF_timeout`; [ ${time:=30} ]
    [ -f $zip ] && unzip -l $zip >/dev/null || {
        ui_print "  Downloading $font (${time}s timeout)"
        ui_print "  $link"
        wget --spider --no-check-certificate $link || {
            ui_print "! $@: no font match, make sure font name is correct"
            return
        }
        timeout $time $MAGISKBIN/busybox wget --no-check-certificate -O $zip $link || {
            ui_print "! Download failed"
            ui_print "  Please download the font manually from the link above or Google Fonts"
            abort "  Then move/rename the downloaded font to $zip"
        }
    }
    ui_print "  Extracting $zipfile"
    unzip -q $zip -d $gfidir
}

gfi_ren() {
    local fa=${1:-$SA} i
    case $fa in $SA) i=u ;; $SC) i=c ;; $SE) i=s ;; $MO) i=m ;; $SO) i=o ;; esac
    set bl $Bl eb $EBo b $Bo sb $SBo m $Me r $Re l $Li el $ELi t $Th
    while [ $2 ]; do
        [ $i = u ] && {
            $find $gfidir -type f -name "$font*\_$Cn$2$X" -exec mv -n {} $CFI/c$1$X \;
            cp $CFI/c$1$X $CFI
        }
        find $gfidir -type f -name "$font*-$2$X" ! \( -name "*$Cn*" -o -name "*Expanded-*" \) \
            -exec mv -n {} $CFI/$i$1$X \;
        find $gfidir -type f -name "$font-$2$X" -exec mv -n {} $CFI/$i$1$X \;
        cp $CFI/$i$1$X $CFI
        shift 2
    done
    case $fa in $SA) i=i ;; $SC) i=d ;; $SE) i=t ;; $MO) i=n ;; $SO) i=p ;; esac
    set bl $Bl$It eb $EBo$It b $Bo$It sb $SBo$It m $Me$It r $It l $Li$It el $ELi$It t $Th$It
    while [ $2 ]; do
        [ $i = i ] && {
            find $gfidir -type f -name "$font*\_$Cn$2$X" -exec mv -n {} $CFI/d$1$X \;
            cp $CFI/d$1$X $CFI
        }
        find $gfidir -type f -name "$font*-$2$X" ! \( -name "*$Cn*" -o -name "*Expanded-*" \) \
            -exec mv -n {} $CFI/$i$1$X \;
        find $gfidir -type f -name "$font-$2$X" -exec mv -n {} $CFI/$i$1$X \;
        cp $CFI/$i$1$X $CFI
        shift 2
    done
    [ $gfidir ] && rm -rf $gfidir/*
}

gfi() {
    $SANS || $SERF || $MONO || $SRMO || return
    GF=`valof GF` GF_condensed=`valof GF_condensed` GF_mono=`valof GF_mono`
    GF_serif=`valof GF_serif` GF_serif_mono=`valof GF_serif_mono`
    [ "$GF" ] || [ "$GF_mono" ] || [ "$GF_serif" ] || [ "$GF_serif_mono" ] && \
    [ -d $CFI ] || return

    ui_print "+ Google Font Installer"
    local font gfidir=$FONTS/gfi; mkdir $gfidir

    $SANS && {
        [ "$GF" ] && {
            ui_print "> Sans Serif"
            [ -f $CFI/ur$XY -o  -f $CFI/$Re$XY -o -f $CFI/ss$X ] && {
                ui_print "  Fonts exist in $CFI. Do nothing!"
            } || {
                gfi_dl $GF
                ui_print "  Preparing $font"
                gfi_ren $SA
                [ -f $CFI/ur$X ] && {
                    ui_print "  $font has been saved to $CFI!"
                } || {
                    ui_print "! Failed: there is no Regular font style"
                    abort "  Please rename fonts manually in $CFI"
                }
            }
        }
        [ "$GF_condensed" ] && {
            ui_print "> Sans Serif Condensed"
            [ -f $CFI/cr$XY -o  -f $CFI/$Cn$Re$XY ] && {
                ui_print "  Fonts exist in $CFI. Do nothing!"
            } || {
                gfi_dl $GF_condensed
                ui_print "  Preparing $font"
                gfi_ren $SC
                [ -f $CFI/cr$X ] && {
                    ui_print "  $font has been saved to $CFI!"
                } || {
                    ui_print "! Failed: there is no Regular font style"
                    abort "  Please rename fonts manually in $CFI"
                }
            }
        }
    }

    $MONO && [ "$GF_mono" ] && {
        ui_print "> Monospace"
        [ -f $CFI/mr$XY -o  -f $CFI/$Mo$Re$XY -o -f $CFI/ms$X ] && {
            ui_print "  Fonts exist in $CFI. Do nothing!"
        } || {
            gfi_dl $GF_mono
            ui_print "  Preparing $font"
            gfi_ren $MO
            [ -f $CFI/mr$X ] && {
                ui_print "  $font has been saved to $CFI!"
            } || {
                ui_print "! Failed: there is no Regular font style"
                abort "  Please rename fonts manually in $CFI"
            }
        }
    }

    $SERF && [ "$GF_serif" ] && {
        ui_print "> Serif"
        [ -f $CFI/sr$XY -o  -f $CFI/$Se$Re$XY -o -f $CFI/ser$X ] && {
            ui_print "  Fonts exist in $CFI. Do nothing!"
        } || {
            gfi_dl $GF_serif
            ui_print "  Preparing $font"
            gfi_ren $SE
            [ -f $CFI/sr$X ] && {
                ui_print "  $font has been saved to $CFI!"
            } || {
                ui_print "! Failed: there is no Regular font style"
                abort "  Please rename fonts manually in $CFI"
            }
        }
    }

    $SRMO && [ "$GF_serif_mono" ] && {
        ui_print "> Serif Monospace"
        [ -f $CFI/or$XY -o  -f $CFI/$So$Re$XY -o -f $CFI/srm$X ] && {
            ui_print "  Fonts exist in $CFI. Do nothing!"
        } || {
            gfi_dl $GF_serif_mono
            ui_print "  Preparing $font"
            gfi_ren $SO
            [ -f $CFI/or$X ] && {
                ui_print "  $font has been saved to $CFI!"
            } || {
                ui_print "! Failed: there is no Regular font style"
                abort "  Please rename fonts manually in $CFI"
            }
        }
    }

    ver gfi
}

fontfix() {
    FONTFIX=`valof FONTFIX`; ${FONTFIX:=true} || return
    local i a=$@
    [ "$a" ] || a=`echo $SS $SSI $SER $SERI $MS $MSI $SRM $SRMI | xargs -n1 | sort -u`
    [ "$a" ] && afdko || return
    ui_print '+ Font tweaks'
    [ $# -eq 0 ] && {
        for i in $a; do $TOOLS/fontfix $SYSFONT/$i; done
        return
    }
    for i in $a; do $TOOLS/fontfix $i; done
}

### INSTALLATION ###

ui_print '- Installing'

ui_print '+ Prepare'
prep

ui_print '+ Configure'
config

mkdir $FONTS ${CFI:=$OMFDIR/CFI}
gfi
ui_print '+ Font'
cp $CFI/*$XY $FONTS || ui_print "! $CFI: no font found"
[ -f $FONTS/$SS ] || SS=
[ -f $FONTS/`valof SSI` ] || { [ "`valof IR`" ] && SSI=$SS; } || SSI=
[ -f $FONTS/$SER ] || SER=; [ -f $FONTS/$SERI ] || SERI=
[ -f $FONTS/$MS ] || MS=; [ -f $FONTS/$MSI ] || MSI=
[ -f $FONTS/$SRM ] || SRM=; [ -f $FONTS/$SRMI ] || SRMI=

DS=DroidSans SSP=SourceSanPro
[ $SS ] && {
    mv $FONTS/$SS $FONTS/$DS$X && SS=$DS$X
    [ $SSI = $SS ] || { mv $FONTS/$SSI $FONTS/$DS-$Bo$X && SSI=$DS-$Bo$X; }
}
[ $SER ] && {
    mv $FONTS/$SER $FONTS/$SSP-$Re$X && SER=$SSP-$Re$X
    [ $SERI = $SER ] || { mv $FONTS/$SERI $FONTS/$SSP-$It$X && SERI=$SSP-$It$X; }
}
[ $MS ] && {
    mv $FONTS/$MS $FONTS/$SSP-$SBo$X && MS=$SSP-$SBo$X
    [ $MSI = $MS ] || { mv $FONTS/$MSI $FONTS/$SSP-$SBo$It$X && MSI=$SSP-$SBo$It$X; }
}
[ $SRM ] && {
    mv $FONTS/$SRM $FONTS/$SSP-$Bo$X && SRM=$SSP-$Bo$X
    [ $SRMI = $SRM ] || { mv $FONTS/$SRMI $FONTS/$SSP-$Bo$It$X && SRMI=$SSP-$Bo$It$X; }
}
ORISS=$SS ORISSI=$SSI ORISER=$SER  ORISERI=$SERI
ORIMS=$MS ORIMSI=$MSI ORISRM=$SRM  ORISRMI=$SRMI

install_font; fontfix
[ $Sa ] && rm $FONTS/[cd]*$XY
false | cp -i $FONTS/*$XY $SYSFONT
$SANS || $SERF || $MONO || $SRMO || $EMOJ || rm $SYSXML $PRDXML

src

ui_print '+ Rom'
rom
fontspoof
finish

[ -d $SYSFONT ] || abort "! No font installed"
