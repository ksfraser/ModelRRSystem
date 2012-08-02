#!/usr/bin/wish
# Generated code: Wed Jan 07 05:50:36 PM EST 2009
# Generated by: $Id$
# Add your code to the bottom (after the 'Add User code after this line').
#
# -name {Example 2: Mainline with an industrial siding}
# -width 780
# -height 550
# -hascmri yes
# -cmriport /dev/ttyS3
# -cmrispeed 9600
# -cmriretries 10000
# Load Tcl/Tk system supplied packages
package require Tk;#            Make sure Tk is loaded
package require BWidget;#       Load BWidgets
package require snit;#          Load Snit

# Load MRR System packages
# Add MRR System package Paths
lappend auto_path /usr/local/lib/MRRSystem;# C++ (binary) packages
lappend auto_path /usr/local/share/MRRSystem;# Tcl (source) packages

package require BWStdMenuBar;#  Load the standard menu bar package
package require MainWindow;#    Load the Main Window package
package require CTCPanel 2.0;#  Load the CTCPanel package (V2)
package require grsupport 2.0;# Load Graphics Support code (V2)

#* 
#* ------------------------------------------------------------------
#* panelCode.tcl - Panel Main Window Creation Library
#* Created by Robert Heller on Sun Apr 13 18:27:24 2008
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 

# $Id$

snit::type MainWindow {
  pragma -hastypeinfo    no
  pragma -hastypedestroy no
  pragma -hasinstances   no

  typecomponent main
  typecomponent swframe
  typecomponent ctcpanel

  delegate typemethod {ctcpanel *} to ctcpanel
  delegate typemethod {main *} to main
  typemethod createwindow {args} {
    set name [from args -name {}]
    set width [from args -width 800]
    set height [from args -height 800]
    wm protocol . WM_DELETE_WINDOW [mytypemethod CarefulExit]
    wm withdraw .
    wm title . "$name"
    set main [mainwindow .main]
    pack $main -expand yes -fill both
    $main menu entryconfigure file New -state disabled
    $main menu entryconfigure file Open... -state disabled
    $main menu entryconfigure file Save -state disabled
    $main menu entryconfigure file {Save As...} -state disabled
    $main menu entryconfigure file Print... -state disabled
    $main menu entryconfigure file Close -command [mytypemethod CarefulExit]
    $main menu entryconfigure file Exit -command [mytypemethod CarefulExit]
    set frame [$main scrollwindow getframe]
    set swframe [ScrollableFrame $frame.swframe \
			-constrainedheight yes -constrainedwidth yes \
			-width [expr {$width + 15}] -height $height]
    pack $swframe -expand yes -fill both
    $main scrollwindow setwidget $swframe
    set ctcpanel [::CTCPanel::CTCPanel [$swframe getframe].ctcpanel \
			-width $width -height $height]
    pack $ctcpanel -fill both -expand yes
    $main menu add view command \
		-label {Zoom In} \
		-accelerator {+} \
		-command "$ctcpanel zoomBy 2"
    set zoomMenu [menu [$main mainframe getmenu view].zoom -tearoff no]
    $main menu add view cascade \
		-label Zoom \
		-menu $zoomMenu
    $main menu add view command \
		-label {Zoom Out} \
		-accelerator {-} \
		-command "$ctcpanel zoomBy .5"
    $zoomMenu add command -label {16:1} -command "$ctcpanel setZoom 16"
    $zoomMenu add command -label {8:1} -command "$ctcpanel setZoom 8"
    $zoomMenu add command -label {4:1} -command "$ctcpanel setZoom 4"
    $zoomMenu add command -label {2:1} -command "$ctcpanel setZoom 2"
    $zoomMenu add command -label {1:1} -command "$ctcpanel setZoom 1"
    $zoomMenu add command -label {1:2} -command "$ctcpanel setZoom .5"
    $zoomMenu add command -label {1:4} -command "$ctcpanel setZoom .25"
    $zoomMenu add command -label {1:8} -command "$ctcpanel setZoom .125"
    $zoomMenu add command -label {1:16} -command "$ctcpanel setZoom .0625"

    $main showit
  }
  typemethod CarefulExit {{answer no}} {
    if {!$answer} {
      set answer [tk_messageBox -default no -icon question \
			-message {Really Quit?} -title {Careful Exit} \
			-type yesno -parent $main]
      if {$answer} {exit}
    }
  }  
}

MainWindow createwindow -name {Example 2: Mainline with an industrial siding} -width 780 -height 550
# CTCPanelObjects
MainWindow ctcpanel create Switch SW1 \
	-x 90.0 \
	-y 200.0 \
	-label 1 \
	-controlpoint CP1 \
	-orientation 0 \
	-flipped yes \
	-statecommand {::Switches::SW1 getstate} \
	-occupiedcommand {::Switches::SW1 occupiedp}
MainWindow ctcpanel create Switch INDUS1 \
	-x 200.0 \
	-y 177.0 \
	-label {} \
	-controlpoint None \
	-orientation 0 \
	-flipped yes \
	-statecommand {::Switches::INDUS1 getstate} \
	-occupiedcommand {::Switches::INDUS1 occupiedp}
MainWindow ctcpanel create Switch SW2 \
	-x 700.0 \
	-y 200.0 \
	-label 2 \
	-controlpoint CP2 \
	-orientation 4 \
	-flipped no \
	-statecommand {::Switches::SW2 getstate} \
	-occupiedcommand {::Switches::SW2 occupiedp}
MainWindow ctcpanel create Switch INDUS2 \
	-x 400.0 \
	-y 177.0 \
	-label {} \
	-controlpoint None \
	-orientation 0 \
	-flipped yes \
	-statecommand {::Switches::INDUS2 getstate} \
	-occupiedcommand {::Switches::INDUS2 occupiedp}
MainWindow ctcpanel create Switch INDUS3 \
	-x 612.0 \
	-y 177.0 \
	-label {} \
	-controlpoint None \
	-orientation 4 \
	-flipped no \
	-statecommand {::Switches::INDUS3 getstate} \
	-occupiedcommand {::Switches::INDUS3 occupiedp}
MainWindow ctcpanel create SIGPlate CP1SG \
	-x 110.0 \
	-y 170.0 \
	-label 1 \
	-controlpoint CP1 \
	-leftcommand {::SignalPlates::CP1SG setlever left} \
	-centercommand {::SignalPlates::CP1SG setlever center} \
	-rightcommand {::SignalPlates::CP1SG setlever right}
MainWindow ctcpanel create SWPlate CP1SW \
	-x 110.0 \
	-y 75.0 \
	-label 1 \
	-controlpoint CP1 \
	-normalcommand {::SwitchPlates::CP1SW setlever normal} \
	-reversecommand {::SwitchPlates::CP1SW setlever reverse}
MainWindow ctcpanel create StraightBlock BK1 \
	-x1 6.0 \
	-y1 200.0 \
	-x2 86.0 \
	-y2 200.0 \
	-controlpoint Main \
	-label BK1 \
	-position below \
	-occupiedcommand {::Blocks::BK1 occupiedp}
MainWindow ctcpanel create StraightBlock Mill \
	-x1 531.0 \
	-y1 156.0 \
	-x2 567.0 \
	-y2 156.0 \
	-controlpoint None \
	-label Mill \
	-position above \
	-occupiedcommand {}
MainWindow ctcpanel create StraightBlock ISide1 \
	-x1 134.0 \
	-y1 177.0 \
	-x2 195.0 \
	-y2 177.0 \
	-controlpoint None \
	-label {} \
	-position below \
	-occupiedcommand {::Blocks::ISide1 occupiedp}
MainWindow ctcpanel create SWPlate CP2SW \
	-x 680.0 \
	-y 75 \
	-label 2 \
	-controlpoint CP2 \
	-normalcommand {::SwitchPlates::CP2SW setlever normal} \
	-reversecommand {::SwitchPlates::CP2SW setlever reverse}
MainWindow ctcpanel create CodeButton CP1Code \
	-x 110.0 \
	-y 220.0 \
	-controlpoint CP1 \
	-command {::ControlPoints::CP1 code}
MainWindow ctcpanel create SIGPlate CP2SG \
	-x 680 \
	-y 170.0 \
	-label 2 \
	-controlpoint CP2 \
	-leftcommand {::SignalPlates::CP2SG setlever left} \
	-centercommand {::SignalPlates::CP2SG setlever center} \
	-rightcommand {::SignalPlates::CP2SG setlever right}
MainWindow ctcpanel create StraightBlock ISide2 \
	-x1 245.0 \
	-y1 177.0 \
	-x2 396.0 \
	-y2 177.0 \
	-controlpoint None \
	-label {} \
	-position below \
	-occupiedcommand {::Blocks::ISide2 occupiedp}
MainWindow ctcpanel create StraightBlock Bk3 \
	-x1 134.0 \
	-y1 200.0 \
	-x2 653.0 \
	-y2 200.0 \
	-controlpoint Main \
	-label BK3 \
	-position below \
	-occupiedcommand {::Blocks::BK3 occupiedp}
MainWindow ctcpanel create CodeButton CP2Code \
	-x 680 \
	-y 220.0 \
	-controlpoint CP2 \
	-command {::ControlPoints::CP2 code}
MainWindow ctcpanel create StraightBlock BoxFactory \
	-x1 444.0 \
	-y1 156.0 \
	-x2 467.0 \
	-y2 156.0 \
	-controlpoint None \
	-label {Box Factory} \
	-position above \
	-occupiedcommand {}
MainWindow ctcpanel create StraightBlock ISide3 \
	-x1 445.0 \
	-y1 177.0 \
	-x2 567.0 \
	-y2 177.0 \
	-controlpoint None \
	-label {} \
	-position below \
	-occupiedcommand {::Blocks::ISide3 occupiedp}
MainWindow ctcpanel create StraightBlock Sawmill \
	-x1 245.0 \
	-y1 156.0 \
	-x2 336.0 \
	-y2 156.0 \
	-controlpoint None \
	-label Sawmill \
	-position above \
	-occupiedcommand {}
MainWindow ctcpanel create StraightBlock BK5 \
	-x1 704.0 \
	-y1 200.0 \
	-x2 781.0 \
	-y2 200.0 \
	-controlpoint Main \
	-label BK5 \
	-position below \
	-occupiedcommand {::Blocks::BK5 occupiedp}
MainWindow ctcpanel create StraightBlock ISide4 \
	-x1 616.0 \
	-y1 177.0 \
	-x2 655.0 \
	-y2 177.0 \
	-controlpoint None \
	-label {} \
	-position below \
	-occupiedcommand {::Blocks::ISide4 occupiedp}
#* 
#* ------------------------------------------------------------------
#* cmriCode.tcl - CM/RI Library
#* Created by Robert Heller on Sun Apr 13 18:02:03 2008
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 

# $Id$

package require Cmri;#          Load the CMR/I package.
package require grsupport 2.0

# Snit type to implement a CMR/I node. 
snit::type CMriNode {
  typecomponent CMriBusObject;#		CMR/I I/O object
  typeconstructor {set CMriBusObject {}}
  typemethod open {port speed retries} {
    set CMriBusObject [::new_CMri $port $speed $retries]
  }
  typemethod close {} {
    if {[string length "$CMriBusObject"] > 0} {$CMriBusObject -delete}
    set CMriBusObject {}
  }
  # Define the integer verify method.
  GRSupport::VerifyIntegerMethod
  # options used by CMR/I nodes.
  option -ns -default 0 -readonly yes \
	 -validatemethod _VerifyInteger
  option -ni -default 0 -readonly yes \
	 -validatemethod _VerifyInteger
  option -no -default 0 -readonly yes \
	 -validatemethod _VerifyInteger
  option -dl -default 0 -readonly yes \
	 -validatemethod _VerifyInteger
  option -ct -default {} -readonly yes
  variable UA;#				This node's address
    
  constructor {_UA NodeType args} {
    set UA $_UA;#			Stash our address
    $self configurelist $args;#		configure options
    # Determine type of node.
    switch -exact -- $NodeType {
      SUSIC {set ctype X}
      USIC  {set ctype N}
      SMINI {set ctype M
	     set options(-ni) 3
	     set options(-no) 6
	     set options(-dl) 0}
      default {
	error "Unknown Node Type: $NodeType"
      }
    }
    # Initialize our board.
    $CMriBusObject InitBoard $options(-ct) $options(-ni) \
			       $options(-no) $options(-ns) \
			       $UA $ctype $options(-dl)
  }
  # Input method -- poll our input ports
  method inputs {} {
    return [$CMriBusObject Inputs $UA]
  }
  # Output method -- write to our output ports
  method outputs {args} {
    return [$CMriBusObject Outputs $args $UA]
  }
}


  


CMriNode open /dev/ttyS3 9600 10000
# CMRIBoards
CMriNode create CP1 0 SMINI -ns 0 -ni 3 -no 6 -dl 0 -ct {}
CMriNode create CP2 2 SMINI -ns 0 -ni 3 -no 6 -dl 0 -ct {}
CMriNode create Siding 1 SMINI -ns 0 -ni 3 -no 6 -dl 0 -ct {}

# Add User code after this line
# This is an example CTC Panel program.  It features a section of single
# tracked mainline with an industrial siding.
#
# The switches and signals are controled by a pair of SMINI nodes, which also 
# connects occupation detectors and switch point sensors to the host system.
# The switches to the industrial sidings are manually operated (ground throws),
# with point position sensors.  There is no occupation detectors on the 
# industrial sidings and their switches are not signaled.
# See example2.iow for the I/O connections for this example.
#
# The signals are two headed, three light signals.
#

package require snit;#		Make sure snit is loaded.

# Define types:
# This code uses SNIT to create a set of OO types to encapsulate each of 
# the several elements of the system: trackwork sections (blocks), 
# switches (turnouts), Switch Plates, Signal Plates, Signals, and control
# points.
#

namespace eval Blocks {
  # Block type (general trackwork).
  # Encapsulates block occupation detectors.
  #
  snit::type Block {
    # Occupation state values
    typevariable OCC 1
    typevariable CLR 0
    # Occupation state bit
    variable occupiedbit
    constructor {} {
      set occupiedbit $CLR;#	Initialize to clear.
    }
    # Occupation state methods
    method occupiedp {} {return [expr {$occupiedbit == $OCC}]}
    method setoccupied {value} {
      set occupiedbit $value
    }
  }
  # Main line trackage
  Block BK1;#	Block 1
  Block BK3;#	Block 3
  Block BK5;#	Block 5
  # Industrial siding sections
  Block ISide1
  Block ISide2
  Block ISide3
  Block ISide4
}

namespace eval Switches {
  # Switch type (turnout)
  # Encapsulates a switch (turnout), including its OS (delegated to a Block 
  # object), its switch motor, and its point position sensor (its state).
  snit::type Switch {
    component block;#			OS section
    delegate method * to block;#	Delegate block methods
    variable state unknown;#		Sense state (point position)
    # Motor bit values
    typevariable NOR 1;# 01		
    typevariable REV 2;# 10		
    variable motor;#			Motor bits -- used to drive switch 
#					motor.
    constructor {} {
      #					Install OS section
      install block using Blocks::Block %AUTO%
      # Initialize motor bits
      set motor $NOR
    }
    # State methods
    method getstate {} {return $state}
    method setstate {statebits} {
      if {$statebits == $NOR} {
	set state normal
      } elseif {$statebits == $REV} {
	set state reverse
      } else {
	set state unknown
      }
    }
    # Motor bit methods
    method motorbits {} {return $motor}
    method setmotor {mv} {
      switch -exact $mv {
	normal {set motor $NOR}
	reverse {set motor $REV}
      }
    }
  }
  Switch SW1;#		Switch at CP1
  Switch SW2;#		Switch at CP2
  Switch INDUS1;#	Switch at Sawmill
  Switch INDUS2;#	Switch at Box Factory
  Switch INDUS3;#	Switch at Mill
}


namespace eval SwitchPlates {
  # Switch Plate
  # Encapsulates a switch plate, implementing its lever position.
  snit::type SwitchPlate {
    component switch
    delegate method * to switch
    variable leverpos unknown
    constructor {sw} {
      set switch $sw
    }
    method setlever {pos} {set leverpos $pos}
    method getlever {} {return $leverpos}
  }
  SwitchPlate CP1SW Switches::SW1
  SwitchPlate CP2SW Switches::SW2
}

namespace eval Signals {
  # Signal types.  Encapsulates a signal's aspect.
  snit::type OneHead {
    # Single head signals have four states: dark, green, yellow, or red.
    typevariable aspects -array {
      Dark	0x00
      Green	0x01
      Yellow	0x02
      Red	0x04
    }
    variable aspectbits
    constructor {} {
      set aspectbits $aspects(Dark)
    }
    method setaspect {a} {set aspectbits $aspects($a)}
    method getaspect {}  {return $aspectbits}
  }
  snit::type TwoHead {
    # Two head signals have five states: dark, green over red, 
    # yellow over red, red over yellow, and red over red.
    typevariable aspects -array {
      Dark	0x00
      GreenRed	0x11
      YellowRed	0x12
      RedYellow	0x0c
      RedRed	0x14
    }
    variable aspectbits
    constructor {} {
      set aspectbits $aspects(Dark)
    }
    method setaspect {a} {set aspectbits $aspects($a)}
    method getaspect {}  {return $aspectbits}
  }
  TwoHead CP1E;#	Heading into switch 1 from the west (block 1)
  TwoHead CP1WM;#	Heading into switch 1 from the east on the main (Block 3)
  TwoHead CP1WS;#	Heading into switch 1 from the east from the siding
  TwoHead CP2EM;#	Heading into switch 2 from the west on the main (Block 3)
  TwoHead CP2ES;#	Heading into switch 2 from the west from the siding
  TwoHead CP2W;#	Heading into switch 2 from the east (block 5)
}

namespace eval SignalPlates {
  # Signal Plate, encapsulating a signal plate with its lever and indicators.
  snit::type SignalPlate {
    variable leverpos unknown
    option -signalplate -default {} -readonly yes
    constructor {args} {
      $self configurelist $args
    }
    method setlever {pos} {set leverpos $pos}
    method getlever {} {return $leverpos}
    method setdot {dir} {
      switch $dir {
	left {
	  MainWindow ctcpanel seti $options(-signalplate) L on
	  MainWindow ctcpanel seti $options(-signalplate) C off
	  MainWindow ctcpanel seti $options(-signalplate) R off
	}
	right {
	  MainWindow ctcpanel seti $options(-signalplate) L off
	  MainWindow ctcpanel seti $options(-signalplate) C off
	  MainWindow ctcpanel seti $options(-signalplate) R on
	}
	none -
	default {
	  MainWindow ctcpanel seti $options(-signalplate) L off
	  MainWindow ctcpanel seti $options(-signalplate) C on
	  MainWindow ctcpanel seti $options(-signalplate) R off
	}
      }
    }
  }
  SignalPlate CP1SG -signalplate CP1SG;#Signal plate for control point 1
  SignalPlate CP2SG -signalplate CP2SG;#Signal plate for control point 2
}

namespace eval ControlPoints {
  # Control points.  Used to implement code buttons.  
  # Encapsulates a control point
  snit::type ControlPoint {
    option -cpname -readonly yes -default {}
    constructor {args} {
      $self configurelist $args
    }
    method code {} {
      foreach swp [MainWindow ctcpanel objectlist $options(-cpname) SwitchPlates] {
	MainWindow ctcpanel invoke $swp
      }      
      foreach sgp [MainWindow ctcpanel objectlist $options(-cpname) SignalPlates] {
	MainWindow ctcpanel invoke $sgp
      }
    }
  }
  ControlPoint CP1 -cpname CP1;#	Control point 1
  ControlPoint CP2 -cpname CP2;#	Control point 2
}


# Main Loop Start
while {true} {
  # Read all ports
  set CP1_inbits [CP1 inputs]
  # Occupation Detectors and point state switches: (Input Port A, Card 1)
  set tempByte [lindex $CP1_inbits 0]
  Blocks::BK1  setoccupied  [expr {$tempByte      & 0x01}]
  Switches::SW1 setoccupied [expr {$tempByte >> 1 & 0x01}]
  Switches::SW1 setstate    [expr {$tempByte >> 2 & 0x03}]
  set CP2_inbits [CP2 inputs]
  # Occupation Detectors and point state switches: (Input Port A, Card 1)
  set tempByte [lindex $CP2_inbits 0]
  Blocks::BK5  setoccupied  [expr {$tempByte      & 0x01}]
  Switches::SW2 setoccupied [expr {$tempByte >> 1 & 0x01}]
  Switches::SW2 setstate    [expr {$tempByte >> 2 & 0x03}]
  set Siding_inbits [Siding inputs]
  # Occupation Detectors: (Input Port A, Card 1)
  set tempByte [lindex $Siding_inbits 0]
  Blocks::BK3    setoccupied    [expr {$tempByte      & 0x01}]
  Blocks::ISide1 setoccupied    [expr {$tempByte >> 1 & 0x01}]
  Blocks::ISide2 setoccupied    [expr {$tempByte >> 2 & 0x01}]
  Blocks::ISide3 setoccupied    [expr {$tempByte >> 3 & 0x01}]
  Blocks::ISide4 setoccupied    [expr {$tempByte >> 4 & 0x01}]
  Switches::INDUS1 setoccupied  [expr {$tempByte >> 5 & 0x01}]
  Switches::INDUS2 setoccupied  [expr {$tempByte >> 6 & 0x01}]
  Switches::INDUS3 setoccupied  [expr {$tempByte >> 7 & 0x01}]
  # Point state switches: (Input Port B, Card 1)
  set tempByte [lindex $Siding_inbits 1]
  Switches::INDUS1 setstate     [expr {$tempByte      & 0x03}]
  Switches::INDUS2 setstate     [expr {$tempByte >> 2 & 0x03}]
  Switches::INDUS3 setstate     [expr {$tempByte >> 4 & 0x03}]
  # Invoke all trackwork and get occupicency
  MainWindow ctcpanel invoke BK1
  MainWindow ctcpanel invoke Bk3
  MainWindow ctcpanel invoke BK5
  MainWindow ctcpanel invoke ISide1
  MainWindow ctcpanel invoke ISide2
  MainWindow ctcpanel invoke ISide3
  MainWindow ctcpanel invoke ISide4
  MainWindow ctcpanel invoke INDUS1
  MainWindow ctcpanel invoke INDUS2
  MainWindow ctcpanel invoke INDUS3
  # Combine all siding ODs
  set Siding [expr {[Blocks::ISide1 occupiedp] ||
		    [Blocks::ISide2 occupiedp] ||
		    [Blocks::ISide3 occupiedp] ||
		    [Blocks::ISide4 occupiedp] ||
		    [Switches::INDUS1 occupiedp] ||
		    [Switches::INDUS2 occupiedp] ||
		    [Switches::INDUS3 occupiedp]}]
  # Initialize all signals to Red
  Signals::CP1E setaspect RedRed
  Signals::CP1WM setaspect RedRed
  Signals::CP1WS setaspect RedRed
  Signals::CP2EM setaspect RedRed
  Signals::CP2ES setaspect RedRed
  Signals::CP2W setaspect RedRed
  set dot1 none;# Assume no direction of travel through control point 1
  if {![MainWindow ctcpanel invoke SW1]} {
    # Switch1 OS is clear.  We can start to move the points
    Switches::SW1 setmotor [SwitchPlates::CP1SW getlever]
    # get current point state
    switch [Switches::SW1 getstate] {
      normal {;# Aligned for the Main.  Set the mainline signals.
	if {![Blocks::BK1 occupiedp] &&
	    [string equal [SignalPlates::CP1SG getlever] "left"]} {
	  # Clear to left
	  Signals::CP1WM setaspect GreenRed
	  set dot1 left
	}
        if {![Blocks::BK3 occupiedp] &&
	    [string equal [SignalPlates::CP1SG getlever] "right"]} {
	  # Clear to right
	  Signals::CP1E setaspect GreenRed
	  set dot1 right
	}
	# Set plate indicators
	MainWindow ctcpanel seti CP1SW N on
	MainWindow ctcpanel seti CP1SW R off
      }
      reverse {;# Aligned for the siding.  Set siding signals
	if {![Blocks::BK1 occupiedp] &&
	    [string equal [SignalPlates::CP1SG getlever] "left"]} {
	  # Clear to left
	  Signals::CP1WS setaspect RedYellow
	  set dot1 left
	}
	if {!$Siding && [string equal [SignalPlates::CP1SG getlever] "right"]} {
	  # Clear to right
	  Signals::CP1E setaspect RedYellow
	  set dot1 right
	}
	# Set plate indicators
	MainWindow ctcpanel seti CP1SW N off
	MainWindow ctcpanel seti CP1SW R on
      }
      default {;# Points still moving.
	# Set plate indicators
	MainWindow ctcpanel seti CP1SW N off
	MainWindow ctcpanel seti CP1SW R off
      }
    }
  }
  # Set DOT on signal plate
  SignalPlates::CP1SG setdot $dot1
  # Switch 2 is much the same.
  set dot2 none;# Assume no direction of travel through control point 1
  if {![MainWindow ctcpanel invoke SW2]} {
    # Switch1 OS is clear.  We can start to move the points
    Switches::SW2 setmotor [SwitchPlates::CP2SW getlever]
    # get current point state
    switch [Switches::SW2 getstate] {
      normal {;# Aligned for the Main.  Set the mainline signals.
	if {![Blocks::BK5 occupiedp] &&
	    [string equal [SignalPlates::CP2SG getlever] "right"]} {
	  # Clear to right
	  Signals::CP2EM setaspect GreenRed
	  set dot2 right
	}
        if {![Blocks::BK3 occupiedp] &&
	    [string equal [SignalPlates::CP2SG getlever] "left"]} {
	  # Clear to left
	  Signals::CP2W setaspect GreenRed
	  set dot2 left
	}
	# Set plate indicators
	MainWindow ctcpanel seti CP2SW N on
	MainWindow ctcpanel seti CP2SW R off
      }
      reverse {;# Aligned for the siding.  Set siding signals
	if {![Blocks::BK5 occupiedp] &&
	    [string equal [SignalPlates::CP2SG getlever] "right"]} {
	  # Clear to right
	  Signals::CP2ES setaspect RedYellow
	  set dot2 right
	}
	if {!$Siding && [string equal [SignalPlates::CP2SG getlever] "left"]} {
	  # Clear to left
	  Signals::CP2W setaspect RedYellow
	  set dot2 left
	}
	# Set plate indicators
	MainWindow ctcpanel seti CP2SW N off
	MainWindow ctcpanel seti CP2SW R on
      }
      default {;# Points still moving.
	# Set plate indicators
	MainWindow ctcpanel seti CP2SW N off
	MainWindow ctcpanel seti CP2SW R off
      }
    }
  }
  # Set DOT on signal plate
  SignalPlates::CP2SG setdot $dot2
  # Approach lighting -- darken signals facing empty blocks.
  if {![Blocks::BK1 occupiedp]} {
    Signals::CP1E setaspect Dark
  }
  if {![Blocks::BK3 occupiedp]} {
    Signals::CP1WM setaspect Dark
    Signals::CP2EM setaspect Dark
  }
  if {!$Siding} {
    Signals::CP1WS setaspect Dark
    Signals::CP2ES setaspect Dark
  }
  if {![Blocks::BK5 occupiedp]} {
    Signals::CP2W setaspect Dark 
  }
  # Pack output bits
  # CP1:
  # Output Port A, Card 0 (CP1E and SW1)
  set CP1_outbits [expr {[Signals::CP1E   getaspect] | \
			 [Switches::SW1   motorbits] << 5}]
  # Output Port B, Card 0 (CP1WM)
  lappend CP1_outbits [Signals::CP1WM getaspect]
  # Output Port C, Card 0 (CP1WS)
  lappend CP1_outbits [Signals::CP1WS getaspect]
  # Output Ports A, B, C of Card 2: nothing
  lappend CP1_outbits 0 0 0
  # CP2:
  # Output Port A, Card 0 (CP2W and SW2)
  set CP2_outbits [expr {[Signals::CP2W   getaspect] | \
			 [Switches::SW2   motorbits] << 5}]
  # Output Port B, Card 0 (CP2EM)
  lappend CP2_outbits [Signals::CP2EM getaspect]
  # Output Port C, Card 0 (CP2ES)
  lappend CP2_outbits [Signals::CP2ES getaspect]
  # Output Ports A, B, C of Card 2: nothing
  lappend CP2_outbits 0 0 0
  # Write all output ports
  eval [list CP1 outputs] $CP1_outbits
  eval [list CP2 outputs] $CP2_outbits
  #eval [list Siding outputs] $Siding_outbits;# No Siding outputs ports used
  update;# Update display
}
# Main Loop End

