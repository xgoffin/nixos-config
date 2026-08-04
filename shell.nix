{ lib, pkgs, inputs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    jq
    go
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
    (ruby.withPackages (
      ps: with ps; [
        ruby-lsp
        rubocop
        date
        bundler
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
    golangci-lint
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
    (pkgs.stdenv.mkDerivation {
      name = "thrift";

      src = pkgs.fetchurl {
        url = "https://github.com/upfluence/thrift/releases/download/v2.7.5/thrift-ubuntu-24.04";
        sha256 = "sha256-nr4i6EnUqNsCCePVBA20xVa+UTCKLlcftECzVzB3oGA=";
      };

      nativeBuildInputs = [ pkgs.autoPatchelfHook ];
      buildInputs = [ pkgs.stdenv.cc.cc.lib ];

      dontUnpack = true;

      installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/thrift
          chmod +x $out/bin/thrift
      '';
    })
    inputs.uds.packages.${pkgs.system}.psql-user-provisioner
    inputs.uds.packages.${pkgs.system}.edsctl
    inputs.uds.packages.${pkgs.system}.sdsctl
    inputs.uds.packages.${pkgs.system}.smsctl
    inputs.uds.packages.${pkgs.system}.uds-cqlsh
    inputs.uds.packages.${pkgs.system}.uds-psql
    inputs.uds.packages.${pkgs.system}.uds-redis-cli
    inputs.man-tools.packages.${pkgs.system}.add_source           
    inputs.man-tools.packages.${pkgs.system}.aws-connector        
    inputs.man-tools.packages.${pkgs.system}.aws-mfa              
    inputs.man-tools.packages.${pkgs.system}.circleci-envset      
    inputs.man-tools.packages.${pkgs.system}.gh-actions-aws       
    inputs.man-tools.packages.${pkgs.system}.gh-actions-go-mod    
    inputs.man-tools.packages.${pkgs.system}.ghctl                
    inputs.man-tools.packages.${pkgs.system}.grin-import          
    inputs.man-tools.packages.${pkgs.system}.image-rollback       
    inputs.man-tools.packages.${pkgs.system}.okta-go-mod          
    inputs.man-tools.packages.${pkgs.system}.uds-aws-env          
    inputs.man-tools.packages.${pkgs.system}.youtube_amplification
    inputs.helm-charts.packages.${pkgs.system}.uchart
    inputs.tcurl.packages.${pkgs.system}.tcurl
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
    if command -v kubectl >/dev/null 2>&1; then
      source <(kubectl completion bash)
    fi
    echo "Entering dev shell"
  '';
}
