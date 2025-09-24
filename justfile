# https://just.systems

default:
    echo 'Hello, world!'
rebuild-local:
    sudo nixos-rebuild switch --flake ./#${HOSTNAME}
