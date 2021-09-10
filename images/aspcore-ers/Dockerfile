# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /src
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build

WORKDIR /src
RUN git clone https://github.com/DUNE-DAQ/daqerrordisplay.git 

WORKDIR "/src/daqerrordisplay/"
RUN dotnet restore
#COPY . .
COPY appsettings.json ./
RUN dotnet build "DuneDaqErrorReporting.csproj" -c Release -o /app/build

# build app
RUN dotnet publish -c Release -o /app/out

# Build runtime image
FROM base as final
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "DuneDaqErrorReporting.dll"]
