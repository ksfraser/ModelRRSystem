#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Mar 1 10:44:58 2016
#  Last Modified : <190130.2228>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2016  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
#*****************************************************************************


## @defgroup OpenLCB OpenLCB
# @brief OpenLCB main program (for configuration and manual operations).
#
# @section SYNOPSIS
#
# OpenLCB [X11 Resource Options] -- [Other options]
#
# @section DESCRIPTION
#
# This program is a GUI program for configuring OpenLCB nodes and for manual
# (testing) operations.
#
# @section PARAMETERS
#
# none
#
# @section OPTIONS
#
# @subsection x11resource X11 Resource Options
#
# @arg -colormap: Colormap for main window
# @arg -display:  Display to use
# @arg -geometry: Initial geometry for window
# @arg -name:     Name to use for application
# @arg -sync:     Use synchronous mode for display server
# @arg -visual:   Visual for main window
# @arg -use:      Id of window in which to embed application
# @par
#
# @subsection other Other options
#
# @arg -transportname The name of the transport constructor.  A shell wildcard
#                     is allowed (but needs to be quoted or escaped).
# @arg -listconstructors Print a list of available constructors and exit.
# @arg -help Print a short help message and exit.
# @arg -debug Turn on debug output.
# @par
#
# Additional options, specific to the transport constructor can also be 
# specified.
#
# @section AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB]

package require gettext
package require Tk
package require tile
package require snit
package require MainWindow
package require ScrollWindow
package require ROText
package require snitStdMenuBar
package require HTMLHelp 2.0
package require LabelFrames
package require LCC
package require ParseXML
package require ConfigurationEditor
package require EventDialogs
package require ConfigDialogs
package require LCCNodeTree
package require LayoutControlDB
package require Dialog
package require ScrollTabNotebook                                      

global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
							[info script]]]] Help]
#puts stderr "*** HelpDir = $HelpDir"
set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]
#puts stderr "*** msgfiles = $msgfiles"

snit::widgetadaptor NewTurnoutDialog {
    delegate option -parent to hull
    option -db
    
    component nameLE;#                  Name of object
    constructor {args} {
        installhull using Dialog -bitmap questhead -default add \
              -cancel cancel -modal local -transient yes \
              -side bottom -title [_ "New Turnout"] \
              -parent [from args -parent]
        $hull add add    -text Add    -command [mymethod _Add]
        $hull add cancel -text Cancel -command [mymethod _Cancel]
        wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
        set frame [$hull getframe]
        install nameLE using LabelEntry $frame.nameLE \
              -label [_m "Label|Name:"] -text {}
        pack $nameLE -fill x
        $self configurelist $args
    }
    method draw {args} {
        $self configurelist $args
        set options(-parent) [$self cget -parent]
        return [$hull draw]
    }
    method _Add {} {
        set name "[$nameLE cget -text]"
        [$self cget -db] newTurnout $name
        $hull withdraw
        return [$hull enddialog {}]
    }
    method _Cancel {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
}
snit::widgetadaptor NewBlockDialog {
    delegate option -parent to hull
    option -db
    component nameLE;#                  Name of object
    constructor {args} {
        installhull using Dialog -bitmap questhead -default add \
              -cancel cancel -modal local -transient yes \
              -side bottom -title [_ "New Block"] \
              -parent [from args -parent]
        $hull add add    -text Add    -command [mymethod _Add]
        $hull add cancel -text Cancel -command [mymethod _Cancel]
        wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
        set frame [$hull getframe]
        install nameLE using LabelEntry $frame.nameLE \
              -label [_m "Label|Name:"] -text {}
        pack $nameLE -fill x
        $self configurelist $args
    }
    method draw {args} {
        $self configurelist $args
        set options(-parent) [$self cget -parent]
        return [$hull draw]
    }
    method _Add {} {
        set name "[$nameLE cget -text]"
        [$self cget -db] newBlock $name
        $hull withdraw
        return [$hull enddialog {}]
    }
    method _Cancel {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
}
snit::widgetadaptor NewSignalDialog {
    delegate option -parent to hull
    option -db
    component nameLE;#                  Name of object
    component aspectlistLF
    component   aspectlistSTabNB
    variable    aspectlist -array {}
    component   addaspectB
    
    constructor {args} {
        installhull using Dialog -bitmap questhead -default add \
              -cancel cancel -modal local -transient yes \
              -side bottom -title [_ "New Signal"] \
              -parent [from args -parent]
        $hull add add    -text Add    -command [mymethod _Add]
        $hull add cancel -text Cancel -command [mymethod _Cancel]
        wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
        set frame [$hull getframe]
        install nameLE using LabelEntry $frame.nameLE \
              -label [_m "Label|Name:"] -text {}
        pack $nameLE -fill x
        install aspectlistLF using ttk::labelframe $frame.aspectlistLF \
              -labelanchor nw -text [_m "Label|Signal Aspect Events"]
        pack $aspectlistLF -fill x
        install aspectlistSTabNB using ScrollTabNotebook \
              $aspectlistLF.aspectlistSTabNB
        pack $aspectlistSTabNB -expand yes -fill both
        install addaspectB using ttk::button $aspectlistLF.addaspectB \
              -text [_m "Label|Add another aspect"] \
              -command [mymethod _addaspect]
        $self configurelist $args
    }
    method _addaspect {} {
        set aspectcount 0
        incr aspectcount
        set fr aspect$aspectcount
        while {[winfo exists $aspectlistSTabNB.$fr]} {
            incr aspectcount
            set fr aspect$aspectcount
        }
        set aspectlist($aspectcount,frame) $fr
        ttk::frame $aspectlistSTabNB.$fr
        $aspectlistSTabNB add $aspectlistSTabNB.$fr -text [_ "Aspect %d" $aspectcount] -sticky news
        set aspl_ [LabelEntry $aspectlistSTabNB.$fr.aspl \
                   -label [_m "Label|Aspect Name"] \
                   -text {}]
        pack $aspl_ -fill x
        set aspectlist($aspectcount,aspl) {}
        set asplook_ [LabelEntry $aspectlistSTabNB.$fr.asplook \
                      -label [_m "Label|Aspect Look"] \
                      -text {}]
        pack $asplook_ -fill x
        set aspectlist($aspectcount,asplook) {}
        set del [ttk::button $aspectlistSTabNB.$fr.delete \
                 -text [_m "Label|Delete Aspect"] \
                 -command [mymethod _deleteAspect $aspectcount]]
        pack $del -fill x
    }
    method _deleteAspect {index} {
        set fr $aspectlist($index,frame)
        $aspectlistSTabNB forget $aspectlistSTabNB.$fr
        unset $aspectlist($index,frame)
        unset $aspectlist($index,asplook)
        unset $aspectlist($index,aspl)
    }
    method draw {args} {
        $self configurelist $args
        set options(-parent) [$self cget -parent]
        return [$hull draw]
    }
    method _Add {} {
        set name "[$nameLE cget -text]"
        [$self cget -db] newSignal $name
        foreach a [lsort [array names aspectlist -glob *,frame]] {
            regsub {^([[:digit:]]+),frame} => index
            [$self cget -db] addAspect $name \
                  -aspect [[$aspectlist($index,aspl)] get] \
                  -look   [[$aspectlist($index,asplook)] get]
        }
        $hull withdraw
        return [$hull enddialog {}]
    }
    method _Cancel {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
}
snit::widgetadaptor NewSensorDialog {
    delegate option -parent to hull
    option -db
    component nameLE;#                  Name of object
    constructor {args} {
        installhull using Dialog -bitmap questhead -default add \
              -cancel cancel -modal local -transient yes \
              -side bottom -title [_ "New Sensor"] \
              -parent [from args -parent]
        $hull add add    -text Add    -command [mymethod _Add]
        $hull add cancel -text Cancel -command [mymethod _Cancel]
        wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
        set frame [$hull getframe]
        install nameLE using LabelEntry $frame.nameLE \
              -label [_m "Label|Name:"] -text {}
        pack $nameLE -fill x
        $self configurelist $args
    }
    method draw {args} {
        $self configurelist $args
        set options(-parent) [$self cget -parent]
        return [$hull draw]
    }
    method _Add {} {
        set name "[$nameLE cget -text]"
        [$self cget -db] newSensor $name
        $hull withdraw
        return [$hull enddialog {}]
    }
    method _Cancel {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
}
snit::widgetadaptor NewControlDialog {
    delegate option -parent to hull
    option -db
    component nameLE;#                  Name of object
    constructor {args} {
        installhull using Dialog -bitmap questhead -default add \
              -cancel cancel -modal local -transient yes \
              -side bottom -title [_ "New Control"] \
              -parent [from args -parent]
        $hull add add    -text Add    -command [mymethod _Add]
        $hull add cancel -text Cancel -command [mymethod _Cancel]
        wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
        set frame [$hull getframe]
        install nameLE using LabelEntry $frame.nameLE \
              -label [_m "Label|Name:"] -text {}
        pack $nameLE -fill x
        $self configurelist $args
    }
    method draw {args} {
        $self configurelist $args
        set options(-parent) [$self cget -parent]
        return [$hull draw]
    }
    method _Add {} {
        set name "[$nameLE cget -text]"
        [$self cget -db] newControl $name
        $hull withdraw
        return [$hull enddialog {}]
    }
    method _Cancel {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
}
    
snit::type OpenLCB {
    #*************************************************************************
    # OpenLCB Main program -- provide node configuration and event monitoring.
    #
    # Displays available nodes in a tree list form, allowing for node 
    # configuration, event monitoring, and event generation for test purposes.
    #
    #*************************************************************************
    
    pragma -hastypeinfo false
    pragma -hastypedestroy false
    pragma -hasinstances false
    
    typecomponent mainWindow;# Main window
    typecomponent   nodetree;# Tree list of nodes
    typecomponent transport; # Transport layer
    typecomponent eventlog;  # Event log toplevel
    
    typevariable nodetree_cols {nodeid};# Columns
    typevariable mynid {};   # My Node ID
    
    typevariable _debug no;# Debug flag
    
    typecomponent layoutcontroldb
    typecomponent newTurnoutDialog
    typecomponent newBlockDialog
    typecomponent newSignalDialog
    typecomponent newSensorDialog
    typecomponent newControlDialog
        
    typemethod _buildDialogs {} {
        putdebug "*** $type _buildDialogs"
        set newTurnoutDialog [NewTurnoutDialog .main.newTurnoutDialog -parent .main]
        putdebug "*** $type _buildDialogs: newTurnoutDialog is $newTurnoutDialog"
        set newBlockDialog   [NewBlockDialog   .main.newBlockDialog -parent .main]
        set newSignalDialog  [NewSignalDialog  .main.newSignalDialog -parent .main]
        set newSensorDialog  [NewSensorDialog  .main.newSensorDialog -parent .main]
        set newControlDialog [NewControlDialog .main.newControlDialog -parent .main]
    }
    typemethod _newTurnout {} {
        putdebug "*** $type _newTurnout: newTurnoutDialog is $newTurnoutDialog"
        $newTurnoutDialog draw -db $layoutcontroldb
    }
    typemethod _newBlock {} {
        $newBlockDialog   draw -db $layoutcontroldb
    }
    typemethod _newSignal {} {
        $newSignalDialog  draw -db $layoutcontroldb
    }
    typemethod _newSensor {} {
        $newSensorDialog  draw -db $layoutcontroldb
    }
    typemethod _newControl {} {
        $newControlDialog draw -db $layoutcontroldb
    }
        
    typemethod _loadLCDB {} {
        set filename [tk_getOpenFile -defaultextension .xml \
                      -filetypes {{{XML Files} {.xml} TEXT}
                      {{All Files} *     TEXT}
                  } -parent . -title "XML File to open"]
        if {"$filename" ne {}} {
            set layoutcontroldb [LayoutControlDB olddb $filename]
            foreach cdiform [array names CDIs_FormTLs] {
                set tl $CDIs_FormTLs($cdiform)
                if {[winfo exists $tl] && ![$tl cget -displayonly]} {
                    $tl configure -layoutdb $layoutcontroldb
                }
            }
        }
    }
        
    typemethod _saveLCDB {} {
        set filename [tk_getSaveFile -defaultextension .xml \
                      -filetypes {{{XML Files} {.xml} TEXT}
                      {{All Files} *     TEXT}
                  } -parent . -title "XML File to open"]
        if {"$filename" ne {}} {
            $layoutcontroldb savedb "$filename"
        }
    }

    proc putdebug {message} {
        if {$_debug} {
            puts stderr $message
        }
    }
    proc hexdump { header data} {
        if {$_debug} {
            puts -nonewline stderr $header
            foreach byte $data {
                puts -nonewline stderr [format " %02X" $byte]
            }
            puts stderr {}
        }
    }

    typemethod usage {} {
        #* Print a usage message.
        
        puts stdout [_ "Usage: %s \[X11 Resource Options\] -- \[Other options\]" $::argv0]
        puts stdout {}
        puts stdout [_ "X11 Resource Options:"]
        puts stdout [_ " -colormap: Colormap for main window"]
        puts stdout [_ "-display:  Display to use"]
        puts stdout [_ "-geometry: Initial geometry for window"]
        puts stdout [_ "-name:     Name to use for application"]
        puts stdout [_ "-sync:     Use synchronous mode for display server"]
        puts stdout [_ "-visual:   Visual for main window"]
        puts stdout [_ "-use:      Id of window in which to embed application"]
        puts stdout {}
        puts stdout [_ "Other options:"]
        puts stdout [_ "-transportname: The name of the transport constructor."]
        puts stdout [_ "-listconstructors: Print a list of available constructors and exit."]
        puts stdout [_ "-help: Print this help message and exit."]
        puts stdout [_ "-debug: Enable debug output."]
        puts stdout [_ "Additional options for the transport constructor can also be specified."]
    }
    proc hidpiP {w} {
        set scwidth [winfo screenwidth $w]
        set scmmwidth [winfo screenmmwidth $w]
        set scinchwidth [expr {$scmmwidth / 25.4}]
        set scdpiw [expr {$scwidth / $scinchwidth}]
        set scheight [winfo screenheight $w]
        set scmmheight [winfo screenmmheight $w]
        set scinchheight [expr {$scmmheight / 25.4}]
        set scdpih [expr {$scheight / $scinchheight}]
        return [expr {($scdpiw > 100) || ($scdpih > 100)}]
    }
    typeconstructor {
        #* Type constructor -- create all of the one time computed stuff.
        #* This includes processing the CLI, building the main window and 
        #* opening a connection to the OpenLCB bus(s).
        
        # Process the command line options.
        # Does the user want a list of available transport constructors?
        
        set listconstructorsP [lsearch $::argv -listconstructors]
        if {$listconstructorsP >= 0} {
            wm withdraw .
            set transportConstructorList [lcc::OpenLCBNode \
                                          transportConstructors]
            puts stdout [_ "Constructors available:"]
            foreach {descr name} $transportConstructorList {
                puts stdout [format "%s: %s" [namespace tail $name] $descr]
            }
            $type usage
            exit
        }
        
        # Does the user want help?  
        set helpP [lsearch $::argv -help]
        if {$helpP >= 0} {
            wm withdraw .
            $type usage
            exit
        }
        set debugIdx [lsearch $::argv -debug]
        if {$debugIdx >= 0} {
            set _debug yes
            set ::argv [lreplace $::argv $debugIdx $debugIdx]
        }
        LCCNodeTree setdebug $_debug
        
        putdebug "*** $type typeconstructor: ::argv is $::argv"
        # Try to get transport constructor from the CLI.
        set transportConstructorName [from ::argv -transportname ""]
        putdebug "*** $type typeconstructor: transportConstructorName is $transportConstructorName"
        # Assume there isn't one specified on the command line.
        set transportConstructor {}
        if {$transportConstructorName ne ""} {
            # The user speficied something.  Get the actual name, if any.
            set transportConstructors [info commands ::lcc::$transportConstructorName]
            putdebug "*** $type typeconstructor: transportConstructors is $transportConstructors"
            if {[llength $transportConstructors] > 0} {
                set transportConstructor [lindex $transportConstructors 0]
            }
        }
        # Was something found?  If not, pop up a dialog box to get an answer.
        if {$transportConstructor eq {}} {
            update idle
            set transportConstructor [lcc::OpenLCBNode \
                                      selectTransportConstructor \
                                      -parent .]
        }
        # Canceled? Give up.
        if {$transportConstructor eq {}} {
            exit
        }
        # Deal with constructor required opts.  Try the command line, fall 
        # back to a dialog box.
        set reqOpts [$transportConstructor requiredOpts]
        set transportOpts [list]    
        foreach {o d} $reqOpts {
            if {[lsearch $::argv $o] >= 0} {
                lappend transportOpts $o [from ::argv $o $d]
            }
        }
        if {[llength $reqOpts] > [llength $transportOpts]} {
            update idle
            set transportOpts [eval [list $transportConstructor \
                                     drawOptionsDialog \
                                     -parent .] \
                                     $transportOpts]
        }
        # Open the transport.
        if {[catch {eval [list lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor\
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "OpenLCB GUI" \
                          -softwareversion "1.0" \
                          -additionalprotocols {Datagram EventExchange} \
                          ] $transportOpts} transport]} {
            tk_messageBox -type ok -icon error \
                      -message [_ "Failed to open transport because: %s" $transport]
            exit 99
        }
        # Build main GUI window.
        set mainWindow [mainwindow .main -scrolling yes \
                        -height 480 -width 640]
        pack $mainWindow -expand yes -fill both
        # Update menus: bind to Exit item, add Send Event, flesh out the Help
        # menu.
        $mainWindow menu entryconfigure file "Exit" -command [mytypemethod _carefulExit]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Menu|File|Send Event"] \
              -command [mytypemethod _SendEvent]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Menu|File|Load Layout Control DB"] \
              -dynamichelp "[_ {Load a Layout Control DB File}]" \
              -accelerator Ctrl+L \
              -underline 0 \
              -command "[mytypemethod _loadLCDB]"
        bind [winfo toplevel $mainWindow] <Control-Key-L> [mytypemethod _loadLCDB]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Menu|File|Save Layout Control DB"] \
              -dynamichelp "[_ {Save a Layout Control DB File}]" \
              -accelerator Ctrl+S \
              -underline 0 \
              -command "[mytypemethod _saveLCDB]"
        bind [winfo toplevel $mainWindow] <Control-Key-S> [mytypemethod _saveLCDB]
        $mainWindow menu add edit separator
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Turnout"] \
              -dynamichelp "[_ {Create new turnout}]" \
              -command "[mytypemethod _newTurnout]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Block"] \
              -dynamichelp "[_ {Create new block}]" \
              -command "[mytypemethod _newBlock]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Signal"] \
              -dynamichelp "[_ {Create new signal}]" \
              -command "[mytypemethod _newSignal]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Sensor"] \
              -dynamichelp "[_ {Create new sensor}]" \
              -command "[mytypemethod _newSensor]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Control"] \
              -dynamichelp "[_ {Create new control}]" \
              -command "[mytypemethod _newControl]"
        $mainWindow menu entryconfigure help "On Help..." -command {HTMLHelp help Help}
        $mainWindow menu delete help "On Keys..."
        $mainWindow menu delete help "Index..."
        $mainWindow menu delete help "Tutorial..."
        $mainWindow menu entryconfigure help "On Version" -command {HTMLHelp help Version}
        $mainWindow menu entryconfigure help "Warranty" -command {HTMLHelp help Warranty}
        $mainWindow menu entryconfigure help "Copying" -command {HTMLHelp help Copying}
        $mainWindow menu add help command \
              -label [_m "Menu|Help|Reference Manual"] \
              -command {HTMLHelp help "OpenLCB Reference"}
        $mainWindow menu add view command \
              -label [_m "Menu|View|Display CDI from XML file"] \
              -command [mytypemethod _ViewCDI]
        # Hook in help files.
        HTMLHelp setDefaults "$::HelpDir" "index.html#toc"
        
        # Lazy eval for event log.
        set sendlog {}
        # Create node tree widget.
        # ($mainWindow setstatus text, $mainWindow setprogress pval)
        set nodetree [LCCNodeTree [$mainWindow scrollwindow getframe].nodetree \
                      -transport $transport]
        # Bind scrollbars.
        $mainWindow scrollwindow setwidget $nodetree
        
        putdebug "*** $type typeconstructor: transport = $transport"
        # Get our Node ID.
        set mynid [$transport cget -nid]
        putdebug "*** $type typeconstructor: mynid = $mynid"
        set layoutcontroldb [LayoutControlDB newdb]
        $type _buildDialogs
        # Pop the main window on the screen.
        $mainWindow showit
        update idle
        putdebug "*** $type typeconstructor: done."
    }
    
    typemethod _eventHandler {command eventid {validity {}}} {
        #* Event handler -- when a PCER message is received, pop up an
        #* event received pop up.
        
        putdebug "*** $type _eventHandler $command $eventid $validity"
        if {$command eq "report"} {
            if {![winfo exists $eventlog]} {
                set eventlog [lcc::EventLog .eventlog%AUTO% \
                              -transport $transport]
            }
            $eventlog eventReceived $eventid
            $eventlog open
        }
    }
    typemethod _messageHandler {message} {
        #* Message handler -- handle incoming messages.
        #* Certain messages are processed:
        #*
        #* Verify Node ID   -- Send our Verified Node ID.
        #* Protocol Support Inquiry -- Send our Supported Protocols.
        #* Simple Node Information Request -- Send our Simple Node Info.
        #* Other messages are handled by the nodetree.
        
        putdebug [format {*** $type _messageHandler: mti is 0x%04X} [$message cget -mti]]
        switch [format {0x%04X} [$message cget -mti]] {
            0x0490 -
            0x0488 {
                #* Verify Node ID
                $transport SendMyNodeVerifcation
            }
            0x0828 {
                #* Protocol Support Inquiry
                $transport SendMySupportedProtocols [$message cget -sourcenid]
            }
            0x0DE8 {
                #* Simple Node Information Request
                $transport SendMySimpleNodeInfo [$message cget -sourcenid]
            }
            default {
            }
        }
        $nodetree messageHandler $message
    }
    typemethod _insertSimpleNodeInfo {nid infopayload} {
        #* Insert the SimpleNodeInfo for nid into the tree view.

        putdebug "*** $type _insertSimpleNodeInfo $nid $infopayload"
        $nodetree insert $nid end -id ${nid}_simplenodeinfo \
              -text {Simple Node Info} \
              -open no
        set strings1 [lindex $infopayload 0]
        if {$strings1 == 1} {set strings1 4}
        set i 1
        set names1 {manufact model hvers svers}
        set formats1 [list \
                      "Manfacturer: %s" \
                      "Model: %s" \
                      "Hardware Version: %s" \
                      "Software Version: %s"]
        for {set istring 0} {$istring < $strings1} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                set c [lindex $infopayload $i]
                putdebug "*** $type _insertSimpleNodeInfo: strings1: i = $i, c = '$c'"
                if {$c eq ""} {break}
                append s [format %c $c]
                incr i
            }
            if {$s ne ""} {
                $nodetree insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_[lindex $names1 $istring] \
                      -text [_ [lindex $formats1 $istring] $s] \
                      -open no
            }
            incr i
        }
        if {$i >= [llength $infopayload]} {return}
        set strings2 [lindex $infopayload $i]
        if {$strings2 == 1} {set strings2 2}
        # If version 1, then 2 strings (???), other wise version == number of strings
        incr i
        set names2 {name descr}
        set formats2 [list "Name: %s" "Description: %s"]
        for {set istring 0} {$istring < $strings2} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                set c [lindex $infopayload $i]
                putdebug "*** $type _insertSimpleNodeInfo: strings2: i = $i, c = '$c'"
                if {$c eq ""} {break}
                append s [format %c $c]
                incr i
            }
            if {$s ne ""} {
                $nodetree insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_[lindex $names2 $istring] \
                      -text [_ [lindex $formats2 $istring] $s] \
                      -open no
            }
            incr i
        }
        putdebug "*** $type _insertSimpleNodeInfo: done"
    }
    typemethod _insertSupportedProtocols {nid report} {
        #* Insert Supported Protocols if node into tree view.
        
        if {[llength $report] < 3} {lappend report 0 0 0}
        if {[llength $report] > 3} {set report [lrange $report 0 2]}
        set protocols [lcc::OpenLCBProtocols GetProtocolNames $report]
        putdebug "*** $type _insertSupportedProtocols $nid $report"
        
        putdebug "*** $type _insertSupportedProtocols: protocols are $protocols"
        if {[llength $protocols] > 0} {
            $nodetree insert $nid end -id ${nid}_protocols \
                 -text {Protocols Supported} \
                 -open no
            foreach p $protocols {
                putdebug [list *** $type _insertSupportedProtocols: p = $p]
                $nodetree insert ${nid}_protocols end \
                      -id ${nid}_protocols_$p \
                      -text [lcc::OpenLCBProtocols ProtocolLabelString $p] \
                      -open no \
                      -tag protocol_$p
            }
        }
    }
    typemethod _SendEvent {} {
        #* Generate a PCER message.

        if {![winfo exists $eventlog]} {
            set eventlog [lcc::EventLog .eventlog%AUTO% \
                          -transport $transport]
        }
        $eventlog open
    }
    
    typevariable _datagramdata;# Datagram data buffer. 
    typevariable _currentnid;  # Node ID of the node we currently expect 
                               # datagrams from.
    
    typevariable _iocomplete;  # I/O completion flag.
    typemethod _datagramHandler {command sourcenid args} {
        #* Datagram handler.

        set data $args
        switch $command {
            datagramreceivedok {
                return
            }
            datagramrejected {
                if {$sourcenid ne $_currentnid} {return}
                set _datagramdata $data
                incr _iocomplete -1
            }
            datagramcontent {
                if {$sourcenid ne $_currentnid} {
                    $transport DatagramRejected $sourcenid 0x1000
                } else {
                    set _datagramdata $data
                    $transport DatagramReceivedOK $sourcenid
                    incr _iocomplete
                }
            }
        }
    }
    #* CDI text for nodes (indexed by Node IDs).
    typevariable CDIs_text -array {}
    #* CDI parsed XML trees (indexed by Node IDs).
    typevariable CDIs_xml  -array {}
    #* CDI Forms (indexed by Node IDs).
    typevariable CDIs_FormTLs -array {}
    typemethod _ReadCDI {x y} {
        #* Read in a CDI for the node at x,y
        
        putdebug "*** $type _ReadCDI $x $y"
        set id [$nodetree identify row $x $y]
        putdebug "*** $type _ReadCDI: id = $id"
        set nid [regsub {_protocols_CDI} $id {}]
        putdebug "*** $type _ReadCDI: nid = $nid"
        putdebug "*** $type _ReadCDI: \[info exists CDIs_text($nid)\] => [info exists CDIs_text($nid)]"
        if {![info exists CDIs_text($nid)] ||
            $CDIs_text($nid) eq ""} {
            putdebug "*** $type _ReadCDI: Going to read CDI for $nid"
            $transport configure -datagramhandler [mytypemethod _datagramHandler]
            set data [list 0x20 0x84 0x0FF]
            set _iocomplete 0
            set _currentnid $nid
            $transport SendDatagram $nid $data
            vwait [mytypevar _iocomplete]
            $transport configure -datagramhandler {}
            unset _currentnid
            set present [expr {[lindex $_datagramdata 1] == 0x87}]
            if {!$present} {return}
            set lowest 0x00000000
            set highest [expr {[lindex $_datagramdata 3] << 24}]
            set highest [expr {$highest | ([lindex $_datagramdata 4] << 16)}]
            set highest [expr {$highest | ([lindex $_datagramdata 5] << 8)}]
            set highest [expr {$highest | [lindex $_datagramdata 6]}]
            set flags [lindex $_datagramdata 7]
            if {($flags & 0x02) != 0} {
                set lowest [expr {[lindex $_datagramdata 8] << 24}]
                set lowest [expr {$lowest | ([lindex $_datagramdata 9] << 16)}]
                set lowest [expr {$lowest | ([lindex $_datagramdata 10] << 8)}]
                set lowest [expr {$lowest | [lindex $_datagramdata 11]}]
            }
            putdebug [format {*** %s _ReadCDI: lowest = %08X} $type $lowest]
            putdebug [format {*** %s _ReadCDI: highest = %08X} $type $highest]
            set start $lowest
            set end   [expr {$highest + 64}]
            set CDIs_text($nid) {}
            set EOS_Seen no
            for {set address $start} {$address < $end && !$EOS_Seen} {incr address $size} {
                set size [expr {$end - $address}]
                if {$size > 64} {set size 64}
                set data [list 0x20 0x43 \
                          [expr {($address & 0xFF000000) >> 24}] \
                          [expr {($address & 0xFF0000) >> 16}] \
                          [expr {($address & 0xFF00) >> 8}] \
                          [expr {$address & 0xFF}] \
                          $size]
                $transport configure -datagramhandler [mytypemethod _datagramHandler]
                set _iocomplete 0
                set _currentnid $nid
                $transport SendDatagram $nid $data
                vwait [mytypevar _iocomplete]
                $transport configure -datagramhandler {}
                unset _currentnid
                putdebug [format {*** %s _ReadCDI: address = %08X} $type $address]
                hexdump [format "*** %s _ReadCDI: datagram received: " $type] $_datagramdata
                set status [lindex $_datagramdata 1]
                if {$status == 0x53} {
                    set respaddress [expr {[lindex $_datagramdata 2] << 24}]
                    set respaddress [expr {$respaddress | ([lindex $_datagramdata 3] << 16)}]
                    set respaddress [expr {$respaddress | ([lindex $_datagramdata 4] << 8)}]
                    set respaddress [expr {$respaddress | [lindex $_datagramdata 5]}]
                    if {$respaddress == $address} {
                        set bytes [lrange $_datagramdata 6 end]
                        set count 0
                        foreach b $bytes {
                            if {$b == 0} {
                                set EOS_Seen yes
                                break
                            }
                            append CDIs_text($nid) [format {%c} $b]
                            incr count
                            if {$count >= $size} {break}
                        }
                    } else {
                        # ??? (bad return address)
                    }
                } else {
                    # error...
                    set error [expr {[lindex $_datagramdata 2] << 8}]
                    set error [expr {$error | [lindex $_datagramdata 3]}]
                    $logmessages insert end "[format {Read Reply error %04X} $error]"
                    set message { }
                    foreach b [lrange $_datagramdata 4 end] {
                        append message [format %c $b]
                    }
                    $logmessages insert end "$message\n"
                }
                
            }
            set CDIs_xml($nid) [ParseXML %AUTO% $CDIs_text($nid)]
            putdebug "*** $type _ReadCDI: CDI XML parsed for $nid: $CDIs_xml($nid)"
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) -nid $nid \
                   -layoutdb $layoutcontroldb \
                   -transport $transport \
                   -debugprint [myproc putdebug]]
            putdebug "*** $type _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
        } elseif {![info exists CDIs_xml($nid)] ||
            $CDIs_xml($nid) eq {}} {
            
            set CDIs_xml($nid) [ParseXML %AUTO% \
                                          $CDIs_text($nid)]
            putdebug "*** $type _ReadCDI: CDI XML parsed for $nid: $CDIs_xml($nid)"
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) \
                   -nid $nid \
                   -transport $transport \
                   -layoutdb $layoutcontroldb \
                   -debugprint [myproc putdebug]]
            putdebug "*** $type _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
        } elseif {![info exists CDIs_FormTLs($nid)] ||
                  $CDIs_FormTLs($nid) eq {} ||
                  ![winfo exists $CDIs_FormTLs($nid)]} {
            putdebug "*** $type _ReadCDI: CDI XML parsed for $nid: $CDIs_xml($nid)"
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) \
                   -nid $nid \
                   -transport $transport \
                   -layoutdb $layoutcontroldb \
                   -debugprint [myproc putdebug]]
            putdebug "*** $type _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
        } else {
            putdebug "*** $type _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
            wm deiconify $CDIs_FormTLs($nid)
        }
    }
    typemethod _ViewCDI {} {
        set cdifile [tk_getOpenFile -defaultextension .xml \
                     -filetypes { {{XML Files} {.xml} }
                                  {{Text Files} {.txt} }
                                  {{All Files} * } } \
                     -initialdir [pwd] \
                     -initialfile cdi.xml \
                     -parent . \
                     -title "Select a CDI XML file to display"]
        if {$cdifile eq {}} {return}
        if {[catch {open $cdifile r} infp]} {
            tk_messageBox -type ok -icon error \
                  -message [_ "Could not open %s because %s" $cdifile $infp]
            return
        }
        set CDIs_text($cdifile) [read $infp]
        close $infp
        set CDIs_xml($cdifile) [ParseXML %AUTO% $CDIs_text($cdifile)]
        if {[info exists CDIs_FormTLs($cdifile)] && 
            [winfo exists $CDIs_FormTLs($cdifile)]} {
            destroy $CDIs_FormTLs($cdifile)
        }
        set CDIs_FormTLs($cdifile) \
              [lcc::ConfigurationEditor \
               .cdi[regsub -all {.} [file tail $cdifile] {}]%AUTO% \
               -cdi $CDIs_xml($cdifile) \
               -displayonly true \
               -debugprint [myproc putdebug]]
    }
    typemethod _MemoryConfig {x y} {
        #* Configure the memory for the node at x,y

        putdebug "*** $type _MemoryConfig $x $y"
        set id [$nodetree identify row $x $y]
        putdebug "*** $type _MemoryConfig: id = $id"
        set nid [regsub {_protocols_MemoryConfig} $id {}]
        putdebug "*** $type _MemoryConfig: nid = $nid"
        set count 10
        $transport configure -datagramhandler [mytypemethod _datagramHandler]
        set _iocomplete 0
        while {$count > 0 && $_iocomplete <= 0} {
            set _iocomplete 0
            set data [list 0x20 0x80]
            set _currentnid $nid
            $transport SendDatagram $nid $data
            vwait [mytypevar _iocomplete]
            if {$_iocomplete < 0} {
                incr count -1
            }
        }
        unset _currentnid
        $transport configure -datagramhandler {}
        if {$_iocomplete < 0} {
            tk_messageBox -icon warning \
                  -message [_ "Could not get configuration options for %s!" $nid] \
                  -type ok
            return
        }
        set available [expr {([lindex $_datagramdata 2] << 8) | [lindex $_datagramdata 3]}]
        set writelens [lindex $_datagramdata 4]
        set highest [lindex $_datagramdata 5]
        set lowest 0xFD
        set name ""
        if {[llength  $_datagramdata] >= 7} {
            set lowest [lindex $_datagramdata 6]
            foreach b [lrange $_datagramdata 7 end] {
                if {$b == 0} {break}
                append name [format %c $b]
            }
        }
        lcc::ConfigOptions .configopts[regsub {:} $nid {}]%AUTO% \
              -nid $nid \
              -available $available \
              -writelengths $writelens \
              -highest $highest \
              -lowest $lowest \
              -name "$name" \
              -debugprint [myproc putdebug]
        lcc::ConfigMemory .configmem[regsub {:} $nid {}]%AUTO% \
              -destnid $nid \
              -transport $transport \
              -debugprint [myproc putdebug]
    }
    
    typemethod _carefulExit {} {
        #* Exit method.

        exit
    }
    proc countNUL {list} {
        #* Procedure to count the NUL bytes in list.
        
        set count 0
        set start 0
        while {[set i [lsearch -start $start $list 0]] >= 0} {
            incr count
            set start [expr {$i + 1}]
        }
        return $count
    }
}

