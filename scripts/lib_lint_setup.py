import os, sys, re
from pathlib import Path

def lib_lint_setup (module_name):
    lint_dir = "./hardware/lint"
    
    files = Path(f"{lint_dir}").glob('*')
    for file in files:
        file = os.path.basename(file)
        with open(f"{lint_dir}/{file}", "r") as sources:
            lines = sources.readlines()
        with open(f"./hardware/src/{file}", "w") as sources:
            for line in lines:
                sources.write(re.sub(r'IOB_CORE_NAME', module_name, line))
    
if __name__ == "__main__":
    lib_lint_setup(sys.argv[1])
