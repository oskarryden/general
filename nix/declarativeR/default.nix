{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/cf73a86c35a84de0e2f3ba494327cf6fb51c0dfd.tar.gz") {} }:

with pkgs;

let
  my-r = rWrapper.override {
    packages = with rPackages; [
        dplyr
        ggplot2
        (buildRPackage {
          name = "housing";
          src = fetchgit {
          url = "https://github.com/rap4all/housing";
          branchName = "fusen";
          rev = "1c860959310b80e67c41f7bbdc3e84cef00df18e";
          sha256 = "sha256-s4KGtfKQ7hL0sfDhGb4BpBpspfefBN6hf+XlslqyEn4=";
          };
          propagatedBuildInputs = [
            dplyr
            ggplot2
            janitor
            purrr
            readxl
            rlang
            rvest
            stringr
            tidyr
            ];
          })
        ];
    };
  my-rstudio = rstudioWrapper.override {
    packages = with rPackages; [
        dplyr
        ggplot2
        (buildRPackage {
          name = "housing";
          src = fetchgit {
          url = "https://github.com/rap4all/housing";
          branchName = "fusen";
          rev = "1c860959310b80e67c41f7bbdc3e84cef00df18e";
          sha256 = "sha256-s4KGtfKQ7hL0sfDhGb4BpBpspfefBN6hf+XlslqyEn4=";
          };
          propagatedBuildInputs = [
            dplyr
            ggplot2
            janitor
            purrr
            readxl
            rlang
            rvest
            stringr
            tidyr
            ];
          })
        ];
    };
in
 mkShell {
   LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
     buildInputs = [
        my-r
        my-rstudio
      ];
 }
