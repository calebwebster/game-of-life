# Use Arch Linux as the base image
FROM archlinux:latest

# Update system and install required packages
RUN pacman --disable-sandbox -Syu --noconfirm && \
    pacman --disable-sandbox -S --noconfirm \
        sudo \
        curl \
        git \
        fzf \
        ripgrep \
        unzip \
        wget \
        npm \
        dotnet-sdk \
        aspnet-runtime \
        gcc \
        neovim \
        python \
        python-pip \
        luarocks \
        tree-sitter \
        tree-sitter-cli \
        && pacman --disable-sandbox -Scc --noconfirm

WORKDIR /app

CMD ["dotnet", "watch", "/p:AllowMissingPrunePackageData=true", "--urls", "http://0.0.0.0:5001"]
