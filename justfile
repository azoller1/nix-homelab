# https://just.systems

default:
    echo 'Hello, world!'
rebuild-local:
    nixos-rebuild switch --flake ./#${HOSTNAME}
