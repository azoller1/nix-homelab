# https://just.systems

default:
    echo 'Hello, world!'
rebuild-local:
    sudo nixos-rebuild switch --flake ./#${HOSTNAME}
deploy-main-server:
    nix run github:serokell/deploy-rs ./#main-server
deploy-node1:
    nix run github:serokell/deploy-rs ./#node1
deploy-node2:
    nix run github:serokell/deploy-rs ./#node2
deploy-node3:
    nix run github:serokell/deploy-rs ./#node3
deploy-node4:
    nix run github:serokell/deploy-rs ./#node4
deploy-node5:
    nix run github:serokell/deploy-rs ./#node5
deploy-vps-racknerd:
    nix run github:serokell/deploy-rs ./#az-vps
deploy-all:
    nix run github:serokell/deploy-rs ./
