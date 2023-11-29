# Intro to Nix
Nix is a package manager and a functional language that can help with creating reproducible environments. It can be ran on Linux, but also on MacOS and Windows (through WSL). 

We can run nix in a few different ways:
- `nix-shell` - enter and ad hoc shell with the packages that are needed


# Installation
To install nix, we can run the following command:
`curl -L https://nixos.org/nix/install | sh -s -- --daemon`

# Ways to use nix

## Ad Hoc Shell with cowsay and lolcat
Try to run any of these programs:
```{sh}
echo Cow says | cowsay
echo lolcat says | lolcat
```
If you do not have them installed, they will not work. Try to launch an ad hoc shell environment with cowsay and lolcat installed. 

```{sh}
nix-shell -p cowsay lolcat
echo Cow says | cowsay
ls -la | lolcat
```

Launch an ad hoc shell with `R` and `git`:
```{sh}
nix-shell -p R git
# Where are we?
pwd && ls -la
# Which version of R?
Rscript -e 'sessionInfo()'
# Which version of git?
which git
exit
```
When using ad hoc shells, you can nest different shells. For example, you can launch a shell with `R` and `git`, and then launch another shell with `python` and `cowsay`.

A more elaborate nix-shell can be rendered by specifying further flags:
```{sh}
nix-shell -p git --run "git --version" --pure -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/2a601aafdc5605a5133a2ca506a34a3a73377247.tar.gz
```
- `--run` will run a quoted command
- `--pure` will kill irrelevant environment variables relative to `-p`
- `-I` will specify a custom nixpkgs repository, which can then be used by others to obtain the same version.

## A Nix shell script
Nix can be used to interpret shell scripts. By putting introducing nix-shell in the shebang, we can run a shell script with a specific environment. For example, we can create a file called `nixpkgs-releases.sh` with the following contents:
```{sh}
cd ~/code/general/nix
vim nixpkgs-releases.sh

# -- Paste the following:
#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash cacert curl jq python3Packages.xmljson
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/2a601aafdc5605a5133a2ca506a34a3a73377247.tar.gz

curl https://github.com/NixOS/nixpkgs/releases.atom | xml2json | jq .
```
- `-i` will instruct to use bash as the interpreter for what follows

Make the script executable and then try to run it:
```{sh}
chmod +x nixpkgs-releases.sh
./nixpkgs-releases.sh
```

## Declarative nix environment
We can create a more declarative shell environment that can be used by others. Instead of running a shell, we can use a a file typically called `shell.nix` to specify an environment to build. By using a config file like this, we can specify a reproducible environment that can be used by others with a great deal of customization.

A test of this using git, neovim, and nodejs from `nixos-22.11`:

```{sh}
cd ~/code/general/nix
mkdir declarativeProject && cd declarativeProject
vim shell.nix
# -- Paste the following:
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-22.11";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShell {
  packages = with pkgs; [
    git
    neovim
    nodejs
  ];
}

# Build this environment by running `nix-shell` from the same directory as the `shell.nix` file exists in.
nix-shell
```
- `fetchTarball` will fetch a tarball from a URL
- `import` will import a nix expression
- `pkgs.mkShell` will create a shell environment with the specified packages/attributes

The packages that we specified should be seen in `$PATH`:
```{sh}
which git && git --version
which nvim
which node
# See all of the paths in $PATH
echo $PATH | tr ':' '\n'
```

### Add an environment variable
We can specify a custom environment variable in the `shell.nix` file by populating the m̀kShell` section like this:
```{sh}
pkgs.mkShell {
  packages = with pkgs; [
    git
    neovim
    nodejs
  ];
    GIT_EDITOR = "${pkgs.neovim}/bin/nvim";
}
```
This can be overwritten by nix itself, but there are ways of being more strict about this. We can use something that is called a shellHook. More about that later.

We can use shellHooks to run commands when entering a shell. For example, we can add a shellHook to run `git status` when entering a shell:
```{sh}
pkgs.mkShell {
  packages = with pkgs; [
    git
    neovim
    nodejs
  ];
    GIT_EDITOR = "${pkgs.neovim}/bin/nvim";
    shellHook = ''
      git status
    '';
}
```





# Useful links:
- <a href="https://nix.dev/">The Nix Developer Manual</a>
- <a href="https://nixos.org/manual/nix/stable/">The Nix Manual</a>



# Series on R Bloggers
# https://www.r-bloggers.com/2023/07/reproducible-data-science-with-nix/
# https://www.r-bloggers.com/2023/07/reproducible-data-science-with-nix-part-2-running-targets-pipelines-with-nix/
# https://www.r-bloggers.com/2023/07/reproducible-data-science-with-nix-part-3-frictionless-plumber-api-deployments-with-nix/
# https://www.r-bloggers.com/2023/08/reproducible-data-science-with-nix-part-4-so-long-renv-and-docker-and-thanks-for-all-the-fish/

