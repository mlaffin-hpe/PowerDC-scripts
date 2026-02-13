# HPE Power Integrity Team PowerDC setup script
# 
# Usage Instructions:
# Open TCL Command Pane (View->Pane->TCL Command) and enter:
# source "C:/path/to/script/setup.tcl"


# Find install directory from environment variable
proc find_sigrity_root {} {
    if {![info exists ::env(SIGRITY_EDA_DIR)]} {
        error "SIGRITY_EDA_DIR environment variable not set"
    }

    set active_path [file normalize $::env(SIGRITY_EDA_DIR)]
    if {![file exists $active_path]} {
        error "Sigrity installation path does not exist: $active_path"
    }
    
    return $active_path
}

# Validate presense of user-defined materials
proc validate_material_library {lib_path required_materials} {
    if {![file exists $lib_path]} {
        error "Material library file not found: $lib_path"
    }
    
    if {[catch {open $lib_path r} fid]} {
        error "Cannot open material library file: $lib_path"
    }
    
    set file_contents [read $fid]
    close $fid
    
    set missing_materials {}
    foreach material $required_materials {
        # Look for exact XML tag match: <Material name="!RTF">
        set pattern "<Material name=\"$material\">"
        if {[string first $pattern $file_contents] == -1} {
            lappend missing_materials $material
        }
    }
    
    if {[llength $missing_materials] > 0} {
        error "Required materials not found in material library: $missing_materials\nLibrary path: $lib_path"
    }
    
    return 1
}



set SIGRITY_ROOT [find_sigrity_root]
puts "Sigrity root: $SIGRITY_ROOT"

set MATERIAL_LIB_PATH "$SIGRITY_ROOT/share/pcb/text/material.cmx"
set REQUIRED_MATERIALS {!RTF !HVLP}

validate_material_library $MATERIAL_LIB_PATH $REQUIRED_MATERIALS


puts "Updating all conductor layers to material: !RTF"
# refer to: C:/Cadence/Sigrity2023.1/doc/pdc_ug/c9_TCL_Via_Material_Assignment_Commands.html
if {[catch {sigrity::update layer model_name {!RTF} {all conductor layers} {!}} result]} {
    puts "ERROR: Command failed with message: $result"
    # TODO: handle
} else {
    puts "Set all conductor layers to material: !RTF"
}

# Set plating thickness to 1 mil
if {[catch {sigrity::update option -GlobalUnit {mil} {!}} result]} {
    puts "ERROR: Failed to set global unit to mil: $result"
} else {
    if {[catch {sigrity::update PadStack -all -PlatingThickness {1} {!}} result]} {
        puts "ERROR: Failed to set padstack plating thickness: $result"
    } else {
        puts "Set all padstack plating thickness to: 1mil"
    }
}

# -----------------------------------------------------------------------
# Simulation Options
# -----------------------------------------------------------------------

# Turn off accuracy mode initially (required for -makePadsEquipotential)
sigrity::set pdcAccuracyMode {0}

if {[catch {sigrity::update option -treatPadAsShape {1}} result]} {
    puts "ERROR: Command failed with message: $result"
} else {
    puts "Enabled treatPadAsShape option"
}

if {[catch {sigrity::update option -makePadsEquipotential {1}} result]} {
    puts "ERROR: Command failed with message: $result"
} else {
    puts "Enabled makePadsEquipotential option"
}
