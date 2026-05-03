# https://just.systems

default:
    echo 'Hello, world!'
rebuild-local:
    sudo nixos-rebuild switch --flake ./#${HOSTNAME}
deploy-main-server:
    nix run github:serokell/deploy-rs -- ./#main-server -s
deploy-node1:
    nix run github:serokell/deploy-rs -- ./#node1 -s
deploy-node2:
    nix run github:serokell/deploy-rs -- ./#node2 -s
deploy-node3:
    nix run github:serokell/deploy-rs ./#node3
deploy-node4:
    nix run github:serokell/deploy-rs ./#node4
deploy-node5:
    nix run github:serokell/deploy-rs -- ./#node5 -s
deploy-vps-racknerd:
    nix run github:serokell/deploy-rs -- ./#az-vps -s
deploy-all:
    nix run github:serokell/deploy-rs ./
