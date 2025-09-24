#!/usr/bin/env bash

sudo podman network create mariadb --ipv6
sudo podman network create postgres17 --ipv6
sudo podman network create postgres-sparky --ipv6
sudo podman network create mongo6-ys --ipv6
sudo podman network create valkey-traefik --ipv6
