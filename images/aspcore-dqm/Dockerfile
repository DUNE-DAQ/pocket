# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/aspnet:3.1-buster-slim AS base
WORKDIR /src
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build

WORKDIR /src
#RUN git clone https://github.com/DUNE-DAQ/dqmplatform.git
RUN git clone -b develop https://github.com/DUNE-DAQ/dqmplatform.git

WORKDIR "/src/dqmplatform/"
#COPY . .
COPY foo.csproj ./DuneDaqMonitoringPlatform.csproj
RUN dotnet restore
COPY appsettings.json ./
RUN dotnet build "DuneDaqMonitoringPlatform.csproj" -c Release -o /app/build

# build app
RUN dotnet publish -c Release -o /app/out

# Build runtime image
FROM base as final
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "DuneDaqMonitoringPlatform.dll"]
