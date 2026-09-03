using Fidelis.Domain.Entities;

namespace Fidelis.Infrastructure.Persistence.Seed;

public static class FidelisDbSeeder
{
    public static void Seed(FidelisContext db)
    {
        if (db.Clinicas.Any() || db.Tutores.Any())
        {
            Console.WriteLine("Seed ignorado: banco já possui dados.");
            return;
        }

        using var transaction = db.Database.BeginTransaction();

        try
        {
            Console.WriteLine("Iniciando população de dados de demonstração");

            // CLINICAS
            var clinica1 = new Clinica(
                "Clínica Veterinária PetCare",
                "12.345.678/0001-10",
                "(11) 3333-1000",
                "contato@petcare.demo",
                "Av. Paulista, 1000 - São Paulo/SP"
            );

            var clinica2 = new Clinica(
                "Hospital Veterinário Fidelis",
                "98.765.432/0001-20",
                "(11) 3333-2000",
                "contato@fidelis.demo",
                "Rua Vergueiro, 500 - São Paulo/SP"
            );

            db.Clinicas.AddRange(clinica1, clinica2);

            // TUTORES

            var tutor1 = new Tutor(
                "123.456.789-00",
                "Ana Souza",
                "ana.souza@demo.com",
                "Demo@123",
                "(11) 99999-1001",
                "Rua das Flores, 100 - São Paulo/SP"
            );

            var tutor2 = new Tutor(
                "987.654.321-00",
                "Carlos Lima",
                "carlos.lima@demo.com",
                "Demo@456",
                "(11) 99999-2002",
                "Rua das Palmeiras, 200 - São Paulo/SP"
            );

            db.Tutores.AddRange(tutor1, tutor2);

            db.SaveChanges();

            // VETERINARIOS

            var veterinario1 = new Veterinario(
                "CRMV-SP-1001",
                "Dra. Marina Costa",
                "marina@petcare.demo",
                "Demo@123",
                "Clínica Geral",
                clinica1.Id
            );

            var veterinario2 = new Veterinario(
                "CRMV-SP-1002",
                "Dr. Rafael Alves",
                "rafael@fidelis.demo",
                "Demo@456",
                "Dermatologia",
                clinica2.Id
            );

            db.Veterinarios.AddRange(veterinario1, veterinario2);

            // PETS

            var pet1 = new Pet(
                "Thor",
                "Cachorro",
                "Golden Retriever",
                'M',
                new DateTime(2021, 5, 10),
                "https://example.com/thor.jpg",
                tutor1.Id,
                clinica1.Id
            );

            var pet2 = new Pet(
                "Luna",
                "Gato",
                "Siamês",
                'F',
                new DateTime(2022, 8, 15),
                "https://example.com/luna.jpg",
                tutor2.Id,
                clinica2.Id
            );

            db.Pets.AddRange(pet1, pet2);

            db.SaveChanges();

            // CONSULTAS

            var consulta1 = new Consulta(
                new DateTime(2026, 8, 20, 10, 0, 0),
                "Consulta de rotina",
                veterinario1.Id,
                pet1.Id,
                "Animal saudável",
                "Manter vacinação atualizada",
                new DateTime(2026, 11, 20)
            );

            var consulta2 = new Consulta(
                new DateTime(2026, 8, 22, 14, 30, 0),
                "Consulta dermatológica",
                veterinario2.Id,
                pet2.Id,
                "Dermatite leve",
                "Acompanhar evolução da pele",
                new DateTime(2026, 9, 22)
            );

            db.Consultas.AddRange(consulta1, consulta2);

            db.SaveChanges();

            // EXAMES

            var exame1 = new Exame(
                "Hemograma",
                "Hemograma completo de rotina",
                new DateTime(2026, 8, 20),
                consulta1.Id,
                "Resultados dentro dos valores de referência"
            );

            var exame2 = new Exame(
                "Exame dermatológico",
                "Avaliação de pele e pelagem",
                new DateTime(2026, 8, 22),
                consulta2.Id,
                "Dermatite leve identificada"
            );

            db.Exames.AddRange(exame1, exame2);

            // PRESCRICOES

            var prescricao1 = new Prescricao(
                "1 comprimido",
                "A cada 24 horas",
                5,
                consulta1.Id,
                "Administrar após alimentação"
            );

            var prescricao2 = new Prescricao(
                "5 ml",
                "A cada 12 horas",
                7,
                consulta2.Id,
                "Agitar antes de usar"
            );

            db.Prescricoes.AddRange(prescricao1, prescricao2);

            db.SaveChanges();

            // MEDICAMENTOS

            var medicamento1 = new Medicamento(
                "Suplemento Vitamínico",
                "Suplementação vitamínica de apoio",
                prescricao1.Id
            );

            var medicamento2 = new Medicamento(
                "Dermacare",
                "Medicamento veterinário para tratamento dermatológico",
                prescricao2.Id
            );

            db.Medicamentos.AddRange(medicamento1, medicamento2);

            // VACINACOES

            var vacinacao1 = new Vacinacao(
                "V10",
                new DateTime(2026, 7, 15),
                new DateTime(2027, 7, 15),
                pet1.Id,
                veterinario1.Id,
                "Aplicação sem intercorrências"
            );

            var vacinacao2 = new Vacinacao(
                "Antirrábica",
                new DateTime(2026, 6, 10),
                new DateTime(2027, 6, 10),
                pet2.Id,
                veterinario2.Id,
                "Dose anual"
            );

            db.Vacinacoes.AddRange(vacinacao1, vacinacao2);

            // VERMIFUGACOES

            var vermifugacao1 = new Vermifugacao(
                "Vermífugo Plus",
                new DateTime(2026, 8, 1),
                new DateTime(2027, 2, 1),
                pet1.Id,
                veterinario1.Id
            );

            var vermifugacao2 = new Vermifugacao(
                "VetWorm",
                new DateTime(2026, 7, 10),
                new DateTime(2027, 1, 10),
                pet2.Id,
                veterinario2.Id
            );

            db.Vermifugacoes.AddRange(vermifugacao1, vermifugacao2);

            // HISTORICOS PESO

            var peso1 = new HistoricoPeso(
                28.50m,
                new DateTime(2026, 8, 20),
                pet1.Id,
                "Peso estável"
            );

            var peso2 = new HistoricoPeso(
                4.80m,
                new DateTime(2026, 8, 22),
                pet2.Id,
                "Peso adequado para idade"
            );

            db.HistoricoPesos.AddRange(peso1, peso2);

            // COMPORTAMENTOS

            var comportamento1 = new Comportamento(
                "Animal dócil e colaborativo durante atendimento",
                new DateTime(2026, 8, 20),
                pet1.Id
            );

            var comportamento2 = new Comportamento(
                "Animal apresentou leve ansiedade durante consulta",
                new DateTime(2026, 8, 22),
                pet2.Id
            );

            db.Comportamentos.AddRange(comportamento1, comportamento2);

            // RECOMENDACOES

            var recomendacao1 = new Recomendacao(
                "Alimentação",
                "Manter alimentação balanceada e controle de peso",
                new DateTime(2026, 8, 20),
                pet1.Id
            );

            var recomendacao2 = new Recomendacao(
                "Cuidados dermatológicos",
                "Evitar produtos não recomendados na pelagem",
                new DateTime(2026, 8, 22),
                pet2.Id
            );

            db.Recomendacoes.AddRange(recomendacao1, recomendacao2);

            // LEMBRETES

            var lembrete1 = new Lembrete(
                "Retorno",
                "Retorno para acompanhamento clínico",
                new DateTime(2026, 11, 20),
                tutor1.Id,
                pet1.Id
            );

            var lembrete2 = new Lembrete(
                "Retorno dermatológico",
                "Avaliar evolução do tratamento dermatológico",
                new DateTime(2026, 9, 22),
                tutor2.Id,
                pet2.Id
            );

            db.Lembretes.AddRange(lembrete1, lembrete2);

            db.SaveChanges();

            transaction.Commit();

            Console.WriteLine("Dados de demonstração inseridos com sucesso.");

        } catch
        {
            transaction.Rollback();
            throw;
        }
    }
}