

puts "Updating all conductor layers to material: !RTF"
# Reference: C:/Cadence/Sigrity2023.1/doc/pdc_ug/c9_TCL_Via_Material_Assignment_Commands.html
if {[catch {sigrity::update layer model_name {!RTF} {all conductor layers} {!}} result]} {
    puts "ERROR: Command failed with message: $result"
    # TODO: handle
} else {
    puts "Result: $result"
}
