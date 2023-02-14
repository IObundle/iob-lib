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
    (callPackage ./riscv-gnu-toolchain.nix { })
  ];
}
