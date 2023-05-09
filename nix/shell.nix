{ pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "iob-soc-shell";
  buildInputs = with pkgs; [     
    bash
    gnumake
    verilog
    verilator
    gtkwave
    python3
    python3Packages.parse
    (texlive.combine { inherit (texlive) scheme-medium multirow lipsum catchfile nowidow enumitem placeins xltabular ltablex titlesec makecell ; })
    (callPackage ./riscv-gnu-toolchain.nix { })
    verible
    black
    llvmPackages_15.clangUseLLVM
  ];
}
