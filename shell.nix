with import <nixpkgs> { };
let
  ocamlPackages = pkgs.recurseIntoAttrs pkgs.ocamlPackages_latest;
  ocamlVersion = (builtins.parseDrvName ocamlPackages.ocaml.name).version;
  ocamlDeps = with ocamlPackages; [
    ocaml
    findlib
    ocp-indent
    base
    batteries
    core
    core_extended
    dune_2
    utop
    merlin
  ];
  findlibSiteLib = "${ocamlPackages.findlib}/lib/ocaml/${ocamlVersion}/site-lib";
  deps = with pkgs; [
    opam
    gnum4
    gnumake
    git
    rsync
    curl
  ];
  ocamlInit = pkgs.writeText "ocamlinit" ''
    let () =
      try Topdirs.dir_directory "${findlibSiteLib}"
      with Not_found -> ()
    ;;

    #use "topfind";;
    #thread;;
    #require "base";;
    #require "core.top";;
    #require "core.syntax";;
  '';
in
mkShell {
  name = "ocaml-env";
  nativeBuildInputs = [ ncurses ];
  buildInputs = deps ++ ocamlDeps;
  shellHook = ''
    unset SSL_CERT_FILE
    unset NIX_SSL_CERT_FILE

    export OCAMLFORMAT_LOCATION=${ocamlformat}
    export TERM=xterm

    # eval `opam env`

    alias utop="utop -init ${ocamlInit}"
    alias ocaml="ocaml -init ${ocamlInit}"
  '';
}
