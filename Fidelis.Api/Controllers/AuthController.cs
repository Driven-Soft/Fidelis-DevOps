using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

using Fidelis.Application.DTOs;
using Fidelis.Infrastructure.Persistence;

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace Fidelis.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly FidelisContext _context;
    private readonly IConfiguration _configuration;

    public AuthController(
        FidelisContext context,
        IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (!ModelState.IsValid)
            return ValidationProblem(ModelState);

        if (request.Tipo.Equals(
                "TUTOR",
                StringComparison.OrdinalIgnoreCase))
        {
            var tutor = await _context.Tutores
                .FirstOrDefaultAsync(t =>
                    t.Email == request.Email &&
                    t.Senha == request.Senha);

            if (tutor is null)
            {
                return Unauthorized(new
                {
                    mensagem = "Email ou senha inválidos."
                });
            }

            var expiraEm = DateTime.UtcNow.AddHours(2);

            var token = GerarToken(
                tutor.Id,
                tutor.Email,
                tutor.Nome,
                "TUTOR",
                expiraEm);

            return Ok(new LoginResponse
            {
                Tipo = "TUTOR",
                TutorId = tutor.Id,
                Nome = tutor.Nome,
                Email = tutor.Email,
                Token = token,
                ExpiraEm = expiraEm
            });
        }

        if (request.Tipo.Equals(
                "VETERINARIO",
                StringComparison.OrdinalIgnoreCase))
        {
            var veterinario = await _context.Veterinarios
                .FirstOrDefaultAsync(v =>
                    v.Email == request.Email &&
                    v.Senha == request.Senha);

            if (veterinario is null)
            {
                return Unauthorized(new
                {
                    mensagem = "Email ou senha inválidos."
                });
            }

            var expiraEm = DateTime.UtcNow.AddHours(2);

            var token = GerarToken(
                veterinario.Id,
                veterinario.Email,
                veterinario.Nome,
                "VETERINARIO",
                expiraEm);

            return Ok(new LoginResponse
            {
                Tipo = "VETERINARIO",
                VeterinarioId = veterinario.Id,
                Nome = veterinario.Nome,
                Email = veterinario.Email,
                Token = token,
                ExpiraEm = expiraEm
            });
        }

        return BadRequest(new
        {
            mensagem = "Tipo de usuário inválido."
        });
    }

    private string GerarToken(
        int id,
        string email,
        string nome,
        string tipo,
        DateTime expiraEm)
    {
        var jwtKey = _configuration["JWT_KEY"];

        if (string.IsNullOrWhiteSpace(jwtKey))
        {
            throw new InvalidOperationException(
                "A variável de ambiente JWT_KEY não foi configurada."
            );
        }

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, email),
            new Claim(ClaimTypes.Name, nome),
            new Claim(ClaimTypes.Role, tipo),
            new Claim("tipo", tipo)
        };

        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtKey)
        );

        var credentials = new SigningCredentials(
            key,
            SecurityAlgorithms.HmacSha256
        );

        var token = new JwtSecurityToken(
            issuer: "Fidelis.Api",
            audience: "Fidelis.Mobile",
            claims: claims,
            expires: expiraEm,
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}