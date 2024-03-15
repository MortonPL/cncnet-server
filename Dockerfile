FROM mcr.microsoft.com/dotnet/sdk:8.0-jammy AS build
ARG TARGETARCH
WORKDIR /build

# See https://github.com/NuGet/Home/issues/13062
ENV DOTNET_NUGET_SIGNATURE_VERIFICATION=false

# Copy csproj and restore as distinct layers
COPY *.csproj .
RUN dotnet restore cncnet-server-core.csproj -a $TARGETARCH

# Copy and publish app and libraries
COPY . .
RUN dotnet publish cncnet-server-core.csproj -a $TARGETARCH --no-restore -o /app

# Move built executable to a runtime image
FROM mcr.microsoft.com/dotnet/runtime:8.0-jammy
WORKDIR /app
COPY --from=build /app .

# Fix "No usable version of libssl was found" .NET Core error
# .NET Core 3.1 only works with OpenSSL 1.x, but Ubuntu 22.04 LTS comes with much newer OpenSSL 3.0
# Package URL taken from https://gist.github.com/joulgs/c8a85bb462f48ffc2044dd878ecaa786
RUN apt-get update &&\
    apt-get install wget -y &&\
    wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb &&\
    dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb

ENTRYPOINT ["./cncnet-server"]
