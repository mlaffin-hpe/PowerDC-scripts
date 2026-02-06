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



set SIGRITY_ROOT [find_sigrity_root]
set MATERIAL_LIB_PATH "$SIGRITY_ROOT/share/pcb/text/material.cmx"
set REQUIRED_MATERIALS {!RTF !HVLP}

puts "Sigrity root: $SIGRITY_ROOT"
puts "Updating all conductor layers to material: !RTF"
# Reference: C:/Cadence/Sigrity2023.1/doc/pdc_ug/c9_TCL_Via_Material_Assignment_Commands.html
if {[catch {sigrity::update layer model_name {!RTF} {all conductor layers} {!}} result]} {
    puts "ERROR: Command failed with message: $result"
    # TODO: handle
} else {
    puts "Result: $result"
}
