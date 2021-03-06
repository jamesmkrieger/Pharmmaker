# 2019-06-30 Bahar LAB, University of Pittsburgh  bahar@pitt.edu
# Written by Ji Young Lee
# Select snapshots with many of the most dominant interactions from
# Druggability molecular dynamics simulations

set CUTOFF CUTOFF
set PROBE AAA
set hotspotNum FF

# Take parameter values from input arguments as far as possible
for {set index 0} {$index < $argc -1} {incr index} {
  if {$index eq  0} {set CUTOFF [lindex $argv $index]}
  if {$index eq  1} {set PROBE [lindex $argv $index]}
  if {$index eq  2} {set hotspotNum [lindex $argv $index]}
}

animate read pdb ./v-com-ok.pdb beg 0 end -1 skip 1 waitfor all

set num_frames [molinfo top get numframes]

set ofile [open _ligbo-ok.dat w]

for {set f 0} {$f < $num_frames} {incr f} {
	molinfo top set frame $f

  set gluOxy [atomselect top "resname $PROBE and chain P and not hydrogen"]
	$gluOxy frame $f
	set Olist [$gluOxy list]
  ############ Check distance cutoff
  set argNit [atomselect top "resname $PROBE and chain M and resid $hotspotNum"]
  $argNit frame $f
  set Nlist [$argNit list]
	foreach atom1 $Olist {
		foreach atom2 $Nlist {
			set NOdist [measure bond [list [list $atom1] [list $atom2]]]
      if { $NOdist < $CUTOFF } {
        set aato1 [expr $atom1+1]
        set aato2 [expr $atom2+1]
        set phe1 [atomselect [molinfo top get id] "serial $aato2"]
        set pha1 [atomselect [molinfo top get id] "serial $aato1"]
        set phe_vec1 [lindex [$phe1 get {resname}] 0]
        set phe_vec2 [lindex [$phe1 get {resid}] 0]
        set phe_vec3 [lindex [$phe1 get {name}] 0]
        set pha_vec1 [lindex [$pha1 get {resname}] 0]
        set pha_vec2 [lindex [$pha1 get {resid}] 0]
        set pha_vec3 [lindex [$pha1 get {name}] 0]
        #animate write pdb xok-$f.pdb beg $f end $f sel [atomselect top "all"]
        puts $ofile "$f $aato1 $pha_vec1 $pha_vec2 $pha_vec3  $aato2 $phe_vec1 $phe_vec2 $phe_vec3  $NOdist"
      }
		}
	}	
############
}
#end loop over frames
animate delete all

flush $ofile
close $ofile

exit
