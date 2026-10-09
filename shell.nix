{ lib, pkgs, inputs, ... }: let
  thrift-upf = pkgs.stdenv.mkDerivation {
    name = "thrift";

    src = pkgs.fetchurl {
      url = "https://github.com/upfluence/thrift/releases/download/v2.7.10/thrift-ubuntu-24.04";
      sha256 = "sha256-snUlHNf4zN3u2VOFw4hbwp3t2DHEExm8Kd7JmflofUE=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];

    dontUnpack = true;

    installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/thrift
        chmod +x $out/bin/thrift
    '';
  };
in pkgs.mkShell {
  packages = with pkgs; [
    jq
    go_1_27
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        pip
        pyyaml
        pygithub
        jinja2
        yq
        dulwich
        urllib3
        requests
      ]
    ))
    uv
    (ruby_3_4.withPackages (
      ps: with ps; [
        ruby-lsp
        rubocop
        date
        (bundler.overrideAttrs (old: let
          version = "4.0.10";
        in {
          version = version;
          name = "bundler-${version}";
          suffix = version;
          src = fetchurl {
            url = "https://rubygems.org/downloads/bundler-${version}.gem";
            hash = "sha256-7nOnWr5hD08rtN7OdFlYfrGbMCdv0JmCV+yb1vZM4+k=";
          };
        }))
        psych
        typhoeus
        racc
        pg
        charlock_holmes
        libxlsxwriter
      ]
    ))
    nodejs
    postgresql
    cassandra
    kubectl
    (pkgs.wrapHelm pkgs.kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-diff
        helm-secrets
        helm-s3
      ];
    })
    awscli
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.golangci-lint
    go-tools
    gopls
    gnumake 
    gcc
    openssl
    libyaml
    libpq
    zlib
    pkg-config
    sqlite
    poppler-utils
    thrift-upf
    (pkgs.stdenv.mkDerivation {
      name = "fleetctl";

      src = pkgs.fetchurl {
        url = "https://github.com/AlexisMontagne/fleet/releases/download/v1.0.0/fleetctl-linux-amd64";
        sha256 = "sha256-Nk0lfLanuGqB+Gm5Pd07Xa+PkUPh8bKfr0AwWMuIejg=";
      };

      nativeBuildInputs = [ pkgs.autoPatchelfHook ];
      buildInputs = [ pkgs.stdenv.cc.cc.lib ];

      dontUnpack = true;

      installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/fleetctl
          chmod +x $out/bin/fleetctl
      '';
    })
    inputs.uds.packages.${pkgs.system}.default
    inputs.man-tools.packages.${pkgs.system}.default
    inputs.helm-charts.packages.${pkgs.system}.uchart
    inputs.tcurl.packages.${pkgs.system}.default
    inputs.thrift-ls.packages.${pkgs.system}.default
    inputs.tbuild.packages.${pkgs.system}.default
  ];
  env = {
    LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.zlib
    ];
    PKG_CONFIG_PATH =
    "${pkgs.libyaml.dev}/lib/pkgconfig:"
    + "${pkgs.libpq.dev}/lib/pkgconfig:"
    + "${pkgs.zlib.dev}/lib/pkgconfig:"
    + "${pkgs.openssl.dev}/lib/pkgconfig";
    CPATH =
      "${pkgs.libyaml.dev}/include:"
      + "${pkgs.libpq.dev}/include:"
      + "${pkgs.zlib.dev}/include:"
      + "${pkgs.openssl.dev}/include";
    HISTFILE = "/home/xgoffin/.bash_history";
    HISTSIZE = "-1";
    HISTFILESIZE = "-1";
    HISTCONTROL = "ignoreboth";
    # tbuild downloads its own Thrift distribution, but its compiler
    # binary is not patched for NixOS. Use the Nix-packaged compiler
    # while retaining tbuild's downloaded type definitions.
    COMPILEROVERRIDE_THRIFTPATH = "${thrift-upf}/bin/thrift";
  };
  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
      pkgs.curl
      pkgs.libpq
      pkgs.sqlite
      pkgs.zlib
      pkgs.icu
      pkgs.openssl
      pkgs.libyaml
    ]}:$LD_LIBRARY_PATH"
    set -o history
    shopt -s histappend
    if command -v kubectl >/dev/null 2>&1; then
      source <(kubectl completion bash)
    fi
    echo "Entering dev shell"
  '';
}
