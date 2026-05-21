FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

COPY . .

RUN dotnet publish Fidelis.Api/Fidelis.Api.csproj \
-c Release \
-o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

COPY --from=build /app/publish .

RUN adduser --disabled-password appuser

USER appuser

EXPOSE 8080

ENTRYPOINT ["dotnet", "Fidelis.Api.dll"]