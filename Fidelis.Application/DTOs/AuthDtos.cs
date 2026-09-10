using System.ComponentModel.DataAnnotations;

namespace Fidelis.Application.DTOs;

public class LoginRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string Senha { get; set; } = string.Empty;

    [Required]
    public string Tipo { get; set; } = string.Empty;
}

public class LoginResponse
{
    public string Tipo { get; set; } = string.Empty;

    public int? TutorId { get; set; }

    public int? VeterinarioId { get; set; }

    public string Nome { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string Token { get; set; } = string.Empty;

    public DateTime ExpiraEm { get; set; }
}