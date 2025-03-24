{ pkgs }:

{
  enable = true;
  package = pkgs.vscode;
  profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "theme-cobalt2";
        publisher = "wesbos";
        version = "2.5.0";
        sha256 = "0xvhbzxkpi0yqp8m01dgrakkz6djzzviafh33dvpz9bma85jq8ly";
      }
      {
        name = "monica-code";
        publisher = "monicaim";
        version = "1.3.153";
        sha256 = "1g0ljda8f03qsgsdzha13b1ky0p2mv7mvwg1xn8dhnb97dqpxd1a";
      }
    ];
    userSettings = {
      "git.autofetch" = true;
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;

      "editor.formatOnSave" = true;
      "files.autoSave" = "onFocusChange";

      "window.commandCenter" = 1;
      "editor.fontFamily" = "'JetBrains Mono Nerd Font', monospace";
      "editor.fontLigatures" = true;
      "workbench.colorTheme" = "Cobalt2";
      "workbench.iconTheme" = "vs-seti";
      "workbench.sideBar.location"= "right";
    };
  };
} 