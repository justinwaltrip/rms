{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, nixgl, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            frameworks = pkgs.darwin.apple_sdk.frameworks;
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                ({ pkgs, config, lib, ... }: with pkgs; {
                  languages.javascript = {
                    enable = true;
                    pnpm = {
                      enable = true;
                      install.enable = true;
                    };
                  };
                  packages = [
                    at-spi2-atk
                    atkmm
                    cairo
                    gdk-pixbuf
                    glib
                    gobject-introspection
                    gobject-introspection.dev
                    gtk3
                    harfbuzz
                    librsvg
                    libsoup_3
                    pango
                    rustup
                  ] ++ lib.optionals pkgs.stdenv.isDarwin [
                    frameworks.SystemConfiguration
                    frameworks.AppKit
                    frameworks.Foundation
                    frameworks.WebKit
                    frameworks.ApplicationServices
                    frameworks.CoreGraphics
                    frameworks.CoreVideo
                    frameworks.CoreFoundation
                    frameworks.Carbon
                    frameworks.QuartzCore
                    frameworks.Security
                  ] ++ lib.optionals pkgs.stdenv.isLinux [
                    webkitgtk_4_1
                    webkitgtk_4_1.dev
                  ];
                  enterShell = ''
                    export PKG_CONFIG_PATH="\
                      ${glib.dev}/lib/pkgconfig:\
                      ${libsoup_3.dev}/lib/pkgconfig:\
                      ${at-spi2-atk.dev}/lib/pkgconfig:\
                      ${gtk3.dev}/lib/pkgconfig:\
                      ${gdk-pixbuf.dev}/lib/pkgconfig:\
                      ${cairo.dev}/lib/pkgconfig:\
                      ${pango.dev}/lib/pkgconfig:\
                      ${harfbuzz.dev}/lib/pkgconfig"
                    export NIX_LDFLAGS="\
                      -F${frameworks.SystemConfiguration}/Library/Frameworks -framework SystemConfiguration \
                      -F${frameworks.AppKit}/Library/Frameworks -framework AppKit \
                      -F${frameworks.Foundation}/Library/Frameworks -framework Foundation \
                      -F${frameworks.WebKit}/Library/Frameworks -framework WebKit \
                      -F${frameworks.ApplicationServices}/Library/Frameworks -framework ApplicationServices \
                      -F${frameworks.CoreGraphics}/Library/Frameworks -framework CoreGraphics \
                      -F${frameworks.CoreVideo}/Library/Frameworks -framework CoreVideo \
                      -F${frameworks.CoreFoundation}/Library/Frameworks -framework CoreFoundation \
                      -F${frameworks.Carbon}/Library/Frameworks -framework Carbon \
                      -F${frameworks.QuartzCore}/Library/Frameworks -framework QuartzCore \
                      -F${frameworks.Security}/Library/Frameworks -framework Security \
                      $NIX_LDFLAGS"
                    export PATH=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH
                    export LIBRARY_PATH=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib:$LIBRARY_PATH
                  '';
                })
              ];
            };
          }
        );
    };
}
