{ nixpkgs ? import <nixpkgs> {}
, pythonPkgs ? nixpkgs.pkgs.python3Packages
, version
, frontend
}:

let
  pname = "panic_button_backend";
  src   = builtins.path { path = ./.; name = "backend"; };

  package = { buildPythonApplication, flask, flask-cors, flask-compress, gevent, mypy }:
    buildPythonApplication {
      inherit pname version src;

      checkInputs = [ mypy ];
      propagatedBuildInputs = [ flask flask-compress flask-cors gevent ];

      postInstall = ''
        ln --symbolic ${frontend} $out/${nixpkgs.pkgs.python3.sitePackages}/msfocb/static
      '';

      doCheck = true;
      checkPhase = ''
        mypy --warn-redundant-casts \
             --warn-unused-ignores \
             --warn-no-return \
             --warn-return-any \
             --warn-unreachable \
             --check-untyped-defs \
             $src/msfocb/
      '';

      meta = {
        description = ''
          Lock the data partition of a server via a web interface.
        '';
      };
    };
in
  pythonPkgs.callPackage package {}

