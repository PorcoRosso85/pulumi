{
  description = "Hello World HTTP server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      # parentOutPuts = parent.outputs;
    in
    {
      # nix develop
      devShell = pkgs.mkShell {
        buildInputs = [
          pkgs.pulumi
          pkgs.kubectl
          pkgs.awscli
          pkgs.nodejs
        ];
        shellHook = ''
        '';
      };

      # nix run
      packages = {
        cowsay = pkgs.cowsay;
      };

      apps = {
        # .#hello
        hello = flake-utils.lib.mkApp {
          drv = pkgs.hello;
        };
        # .#cowsay
        cowsay = flake-utils.lib.mkApp {
          drv = self.packages.${system}.cowsay;
        };
        hello2 = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "hello_from_shell" ''
            echo "Hello from shell!" 
          '';
        };
        sqlc = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "test" ''
            echo 'sqlc generate'

            cd ./database
            sqlc generate
            cd ..
            
            echo 'done'
          '';
        };
        test = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "test" ''
            cd ./core
            pnpm vitest .
            cd ..
          '';
        };
        dev = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "dev" ''
            cd ./core
            pnpm wrangler dev
            cd -
            
            cd ./database
            pnpm wrangler dev
            cd -
          '';
        };
      };

    }
    );
}


