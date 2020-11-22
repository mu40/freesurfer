#!/usr/bin/env bash
source "$(dirname $0)/../test.sh"

# always run a multithreaded test, but generate single-threaded reference data
if [ "$FSTEST_REGENERATE" != true ]; then
    export OMP_NUM_THREADS=8
fi

# make surfaces

# test_command mris_make_surfaces -aseg aseg.presurf -white white.preaparc -noaparc -whiteonly -mgz -T1 brain.finalsurfs subject lh
# compare_surf subject/surf/lh.white.preaparc subject/surf/lh.white.preaparc.REF

test_command mris_make_surfaces -orig_white white.preaparc -orig_pial white.preaparc -aseg aseg.presurf -mgz -T1 brain.finalsurfs subject lh
compare_surf subject/surf/lh.white subject/surf/lh.white.REF
compare_surf subject/surf/lh.pial subject/surf/lh.pial.REF

# place surfaces

# cmd 1
#    output = ./surf/lh.white.preaparc  
# cmd 2
#    input  = ./surf/lh.white.preaparc (as generated by cmd 1) 
#    output = ./surf/lh.white
# cmd 3
#    input = ./surf/lh.white (output from cmd 2)
#    output = ./surf/lh.pial.T1
export SUBJECTS_DIR=$SUBJECTS_DIR/subject
test_command "cd $SUBJECTS_DIR/mri && mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --wm wm.mgz --threads 1 --invol brain.finalsurfs.mgz --lh --i ../surf/lh.orig --o ../surf/lh.white.preaparc --white --seg aseg.presurf.mgz --nsmooth 5 && mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white.preaparc --o ../surf/lh.white --white --nsmooth 0 --rip-label ../label/lh.cortex.label --rip-bg --rip-surf ../surf/lh.white.preaparc --aparc ../label/lh.aparc.annot"

# takes too long to run cmd_3
# &&  mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white --o ../surf/lh.pial.T1 --pial --nsmooth 0 --rip-label ../label/lh.cortex+hipamyg.label --pin-medial-wall ../label/lh.cortex.label --aparc ../label/lh.aparc.annot --repulse-surf ../surf/lh.white --white-surf ../surf/lh.white"

export SUBJECTS_DIR=$SUBJECTS_DIR

# cmd 1 diff
# compare_surf surf/lh.white.preaparc surf/lh.white.preaparc.REF_PLACE_SURFACES
(cd $SUBJECTS_DIR && ../../../mris_diff/mris_diff surf/lh.white.preaparc surf/lh.white.preaparc.REF_PLACE_SURFACES)

# cmd 2 diff
(cd $SUBJECTS_DIR && ../../../mris_diff/mris_diff surf/lh.white surf/lh.white.REF_PLACE_SURFACES)

