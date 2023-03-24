from build_srcs import lib_module_setup, create_Vheaders, copy_files, module_dependency_setup
import sys

def lib_sim_setup (module_name, dest_srcs_dir):
    hardware_srcs = []
    Vheaders = []
    sim_srcs = []
    lib_dir="."
    lib_module_setup(Vheaders, hardware_srcs, module_name, lib_dir=lib_dir, add_sim_srcs=True)
    module_dependency_setup(hardware_srcs, Vheaders, "src", [], lib_dir=lib_dir, add_sim_srcs=True)

    #Copy Hw
    if Vheaders: create_Vheaders( dest_srcs_dir, Vheaders )
    if hardware_srcs: copy_files( lib_dir, dest_srcs_dir, hardware_srcs, '*.v' )
    
    # Copy TB
    copy_files(lib_dir, dest_srcs_dir, [], f"{module_name}_tb.v", copy_all = True)
    # Copy LIB hw files
    copy_files( "hardware/modules", dest_srcs_dir, [], 'iob_lib.vh', copy_all = True )
    
if __name__ == "__main__":
    lib_sim_setup(sys.argv[1], sys.argv[2])
