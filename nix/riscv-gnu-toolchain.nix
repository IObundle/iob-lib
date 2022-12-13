{ lib
, stdenv
, fetchFromGitHub
, util-linux
, git
, cacert
, autoconf
, automake
, curl
, python3
, gawk
, bison
, flex
, texinfo
, gperf
, bc
, libmpc
, mpfr
, gmp
, zlib
, expat
}:

stdenv.mkDerivation rec {
  pname = "riscv-gnu-toolchain";
  version = "2022.11.23";

  src = fetchFromGitHub {
    owner = "riscv-collab";
    repo = "riscv-gnu-toolchain";
    rev = "${version}";
    sha256 = "sha256-5BWWbjQ65/tDpWmY9r+oA013OhVkjga8GCLK90ZXe5k=";
    leaveDotGit = true;
  };

  postPatch = ''
    # hack for unknown issue in fetchgit
    git reset --hard
    patchShebangs ./scripts
  '';

  nativeBuildInputs = [
    python3
    util-linux
    git
    cacert
    autoconf
    automake
    curl
    python3
    gawk
    bison
    flex
    texinfo
    gperf
    bc
  ];

  buildInputs = [
    libmpc
    mpfr
    gmp
    zlib
    expat
  ];

  configureFlags = [
    "--enable-multilib"
  ];

  makeFlags = [
    "newlib"
    "linux"
  ];

  hardeningDisable = [
    "format"
  ];

  enableParallelBuilding = true;

  __noChroot = true;

  meta = with lib; {
    description = "This is the RISC-V C and C++ cross-compiler. It supports two build modes: a generic ELF/Newlib toolchain and a more sophisticated Linux-ELF/glibc toolchain.";
    homepage = "https://github.com/riscv-collab/riscv-gnu-toolchain";
    license = licenses.gpl2;
    maintainers = with maintainers; [  ];
    platforms = platforms.linux;
  };
}
