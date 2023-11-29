# Packaging already existing software
Taken from [here](https://nix.dev/tutorials/packaging-existing-software).

The main usage of Nix is to manage software and its dependencies. This process is often stressful at the beginning (as we need to declare everything) but allow us to profit massively moving forward.

Nix has a package called `stdenv` that can automatize most of the steps. This is short for (Nixpkgs Standard Environment)[https://nixos.org/manual/nixpkgs/stable/#sec-using-stdenv]. 

A Nix derivation is what most others would call a package. 

We are going to create a file called `hello.nix` which will use a GNU program called ´hello´. 
```{sh}
cd ~/code/general/nix
mkdir psExample && cd psExample
vim hello.nix
# -- Paste the following:
{ lib
, stdenv
, fetchzip
}:

stdenv.mkDerivation {
  name = "hello";

  src = fetchzip {
    url = "https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz";
    sha256 = lib.fakeSha256; # will generate a complain, we change it after the fact
  };
}

# Place this file in the same directory as the hello.nix file
vim default.nix
# -- Paste the following:
# default.nix
let
  pkgs = import <nixpkgs> { };
in
{
  hello = pkgs.callPackage ./hello.nix { };
}

nix-build -A hello
# Find the correct hash and repopulate the hello.nix file
vim hello.nix

# Build again
nix-build -A hello
```
We will now have a `result` directory that contains the built package. We can run it with `./result/bin/hello`.

```{sh}
ls -la
./result/bin/hello
```

We will add a second program, called `icat`. We need to fetch from GitHub, which we can read about [here](https://nix.dev/tutorials/packaging-existing-software#fetching-source-from-github)

```{sh}
vim icat.nix
# -- Paste the following:
# icat.nix
{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
    name = "icat";

    src = fetchFromGitHub {
        owner = "atextor";
        repo = "icat";
        rev = "v0.5";
        sha256 = "0wyy2ksxp95vnh71ybj1bbmqd5ggp13x3mk37pzr99ljs9awy8ka";
    };
}

# Update the default.nix file
vim default.nix
# -- Paste the following:
icat = pkgs.callPackage ./icat.nix { };
```

We can download the files from GitHub like:
```{sh}
nix-prefetch-url --unpack https://github.com/atextor/icat/archive/refs/tags/v0.5.tar.gz --type sha256
```

We can now build the package:
```{sh}
nix-build -A icat
```
This will cause an error as there is a missing package, search for it via 
[nixOS Search](search.nixos.org). It should be added to the icat program file in two places:

1. In the function arguments.
2. In the `buildInputs` attribute inside the `stdenv.mkDerivation` function.

Update the icat program file to look like:

```{sh}
vim icat.nix
# -- Paste the following:
# icat.nix
{ lib
, stdenv
, fetchFromGitHub
, imlib2
}:

stdenv.mkDerivation {
    name = "icat";

    src = fetchFromGitHub {
        owner = "atextor";
        repo = "icat";
        rev = "v0.5";
        sha256 = "0wyy2ksxp95vnh71ybj1bbmqd5ggp13x3mk37pzr99ljs9awy8ka";
    };

    buildInputs = [ imlib2 ];
}
```
Try to build once more (and fail due to dependencies). We need to add `xorg` as a dependency and the package `libX11` to the `buildInputs` attribute. 

The dependency problems are gone, but there is now an installation problem. The attribute `installPhase` can be used here.

Add the following snippet to the icat file
```{sh}
vim icat.nix
# -- Paste the following:
installphase = ''
  mkdir -p $out/bin
  cp icat $out/bin
''
```
This will simply copy the program, because it was build successfully. Nix has a environment variable called `$out` that is the target directory for the build.

It should now work.

### Phases and hooks
The function `mkDerivation` has a number of attributes that can be used to customize the build process. These are called [phases](https://nixos.org/manual/nixpkgs/stable/#sec-stdenv-phases) and hooks.

The hooks are specific to each phase. It is good practice to list the hoooks in the order that they are called, if we modify anything.

Update the icat file to look like:
```{sh}
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp icat $out/bin
    runHook postInstall
  '';
```

Build one last time:
```{sh}
nix-build -A icat
ls -lR
```


