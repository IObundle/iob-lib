import iob_colors

# Generic class to describe a base iob-module
class iob_module:
    def __init__(self, name="iob_module", version="1.0", flows="", setup_dir="", build_dir="", blocks=[], confs=[], regs=[], ios=[], is_top_module=False, disable_setup=False, **kwargs):
        self.name = name
        self.version = version
        self.flows = flows
        self.setup_dir = setup_dir
        if build_dir:
            self.build_dir = build_dir
        else:
            self.build_dir = f"../{self.name}_{self.version}"
        self.confs = confs
        self.ios = ios
        self.regs = regs
        self.is_top_module = is_top_module

        # We may want to disable the setup process for debug purposes or just to get the default attributes of the module
        self.disable_setup = disable_setup
        if not disable_setup:
            self.setup(**kwargs)

    # Default setup function does nothing
    # This function is called by the constructor
    def setup(self, **kwargs):
        if kwargs:
            print(f"{iob_colors.WARNING}Module {self.name} was initialised with unknown arguments: {kwargs}{iob_colors.ENDC}")
        pass
