# storecli
# Sua loja de aplicativos via linha de comando.

Instalação:
Passo 1 - instalar o curl:
     
     
     Debian/Ubuntu
     sudo apt install -y curl
   
     Fedora
     sudo dnf install -y curl
     
     ArchLinux
     sudo pacman -S curl
     
     
Passo 2 executar o script de instalação via linha de comando.

sudo sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"

INFO:

storecli --help           => Ajuda

storecli --list           => Lista pacotes disponíveis para instalação.

storecli install <pacote> => Instala um pacote

storecli remove <pacote> => Remove um pacote

storecli                 => Abre o GUI gráfico
