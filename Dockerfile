# Use Arch Linux as the base image
# -------------------------------------------------------------------
# Base: Shared Arch Linux Environment with Dev Tools
# -------------------------------------------------------------------
FROM archlinux:latest AS dev
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
COPY . ./

# Development target default run command
CMD ["dotnet", "watch", "/p:AllowMissingPrunePackageData=true", "--urls", "http://0.0.0.0:5001"]

# -------------------------------------------------------------------
# Build: Compile & Publish Release Binaries
# -------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS build
WORKDIR /src

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# -------------------------------------------------------------------
# Target: Production (Lightweight Runtime)
# -------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine AS prod
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS=http://+:5001

EXPOSE 5001

ENTRYPOINT ["dotnet", "app.dll"]
