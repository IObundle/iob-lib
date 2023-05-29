import iob_colors

# Generic class to describe a base iob-module
class iob_module:
    # Standard attributes common to all iob-modules
    name="iob_module" # Verilog module name (not instance name)
    version="1.0" # Module version
    flows="" # Flows supported by this module
    setup_dir="" # Setup directory for this module
    build_dir="" # Build directory for this module
    confs=[] # List of configuration macros/parameters for this module
    regs=[] # List of registers for this module
    ios=[] # List of I/O for this module
    block_groups=[] # List of block groups for this module. Used for documentation.

    _setup_purpose=[] # List of setup purposes for this module. Also used to check if module has already been setup.


    # Public setup method for this module.
    @classmethod
    def setup(cls, purpose="hardware"):
        # Don't setup if module has already been setup for this purpose or for the "hardware" purpose.
        if purpose in cls._setup_purpose or
            "hardware" in cls._setup_purpose:
            return

        cls._setup_purpose.append(purpose)
        
        cls.set_dynamic_attributes()
        cls._run_setup()


    # Public method to create a Verilog instance of this module
    @classmethod
    def instance(cls, name="", description=""):
        assert _setup_purpose, f"{iob_colors.ERROR}Module {cls.name} has not been setup yet!{iob_colors.ENDC}"

        if not name:
            name=f"{cls.name}_0"

        # TODO: Return a new iob_verilog_instance object with these attributes and pointing to the class
        return NotImplemented


    # Public method to set dynamic attributes
    # This method is automatically called by setup()
    @classmethod
    def set_dynamic_attributes(cls):
        if not cls.build_dir:
            cls.build_dir=f"../{cls.name}_{cls.version}"

    # Default setup function does nothing
    @classmethod
    def _run_setup():
        pass

    # Append confs to the current list, overriding existing ones
    @classmethod
    def _setup_confs(cls, confs):
        for conf in confs:
            for _conf in cls.confs:
                if _conf['name'] == conf['name']:
                    _conf.update(conf)
                    break
            else:
                cls.confs.append(conf)


