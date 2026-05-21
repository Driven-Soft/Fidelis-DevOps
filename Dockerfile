FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build

WORKDIR /src

COPY . .

RUN dotnet publish Fidelis.Api/Fidelis.Api.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview

WORKDIR /app

COPY --from=build /app/publish .

USER 1001

EXPOSE 8080

ENTRYPOINT ["dotnet", "Fidelis.Api.dll"]