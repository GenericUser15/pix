# cspell:ignore direnv
sh <(curl -L https://nixos.org/nix/install) --daemon
curl -sfL https://direnv.net/install.sh | bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
cd $PWD
direnv allow
