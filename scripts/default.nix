{ pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "iob-shell";
  buildInputs = with pkgs; [     
    bash
    gnumake
    verilog
    verilator
    gtkwave
    python3
    python3Packages.black
    python3Packages.parse
    python3Packages.numpy
    python3Packages.wavedrom
    (texlive.combine { inherit (texlive) scheme-medium multirow lipsum catchfile nowidow enumitem placeins xltabular ltablex titlesec makecell datetime fmtcount ; })
    (callPackage ./riscv-gnu-toolchain.nix { })
    verible
    black
    llvmPackages_14.clangUseLLVM
    librsvg
    libreoffice
  ];
}
