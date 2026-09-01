CREATE TABLE IF NOT EXISTS `__EFMigrationsHistory` (
    `MigrationId` varchar(150) CHARACTER SET utf8mb4 NOT NULL,
    `ProductVersion` varchar(32) CHARACTER SET utf8mb4 NOT NULL,
    CONSTRAINT `PK___EFMigrationsHistory` PRIMARY KEY (`MigrationId`)
) CHARACTER SET=utf8mb4;

START TRANSACTION;
DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    ALTER DATABASE CHARACTER SET utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `CLINICAS` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Nome` varchar(100) CHARACTER SET utf8mb4 NOT NULL,
        `Cnpj` varchar(18) CHARACTER SET utf8mb4 NOT NULL,
        `Telefone` varchar(15) CHARACTER SET utf8mb4 NOT NULL,
        `Email` varchar(75) CHARACTER SET utf8mb4 NOT NULL,
        `Endereco` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
        CONSTRAINT `PK_CLINICAS` PRIMARY KEY (`Id`)
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `TUTORES` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Cpf` varchar(14) CHARACTER SET utf8mb4 NOT NULL,
        `Nome` varchar(75) CHARACTER SET utf8mb4 NOT NULL,
        `Email` varchar(75) CHARACTER SET utf8mb4 NOT NULL,
        `Senha` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `Telefone` varchar(15) CHARACTER SET utf8mb4 NOT NULL,
        `Endereco` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
        `DataCriacao` datetime(6) NOT NULL,
        CONSTRAINT `PK_TUTORES` PRIMARY KEY (`Id`)
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `VETERINARIOS` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Crmv` varchar(13) CHARACTER SET utf8mb4 NOT NULL,
        `Nome` varchar(75) CHARACTER SET utf8mb4 NOT NULL,
        `Email` varchar(75) CHARACTER SET utf8mb4 NOT NULL,
        `Senha` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `Especialidade` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `DataCriacao` datetime(6) NOT NULL,
        `ClinicaId` int NOT NULL,
        CONSTRAINT `PK_VETERINARIOS` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_VETERINARIOS_CLINICAS_ClinicaId` FOREIGN KEY (`ClinicaId`) REFERENCES `CLINICAS` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `PETS` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Nome` varchar(30) CHARACTER SET utf8mb4 NOT NULL,
        `Especie` varchar(20) CHARACTER SET utf8mb4 NOT NULL,
        `Raca` varchar(20) CHARACTER SET utf8mb4 NOT NULL,
        `Sexo` varchar(1) CHARACTER SET utf8mb4 NOT NULL,
        `DataNascimento` datetime(6) NOT NULL,
        `Status` varchar(1) CHARACTER SET utf8mb4 NOT NULL,
        `FotoUrl` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
        `TutorId` int NOT NULL,
        `ClinicaId` int NULL,
        CONSTRAINT `PK_PETS` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_PETS_CLINICAS_ClinicaId` FOREIGN KEY (`ClinicaId`) REFERENCES `CLINICAS` (`Id`) ON DELETE SET NULL,
        CONSTRAINT `FK_PETS_TUTORES_TutorId` FOREIGN KEY (`TutorId`) REFERENCES `TUTORES` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `COMPORTAMENTOS` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Data` datetime(6) NOT NULL,
        `Descricao` longtext CHARACTER SET utf8mb4 NOT NULL,
        `PetId` int NOT NULL,
        CONSTRAINT `PK_COMPORTAMENTOS` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_COMPORTAMENTOS_PETS_PetId` FOREIGN KEY (`PetId`) REFERENCES `PETS` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `CONSULTAS` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `DataHora` datetime(6) NOT NULL,
        `Tipo` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `Diagnostico` longtext CHARACTER SET utf8mb4 NULL,
        `Observacoes` longtext CHARACTER SET utf8mb4 NULL,
        `DataRetorno` datetime(6) NULL,
        `VeterinarioId` int NOT NULL,
        `PetId` int NOT NULL,
        CONSTRAINT `PK_CONSULTAS` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_CONSULTAS_PETS_PetId` FOREIGN KEY (`PetId`) REFERENCES `PETS` (`Id`) ON DELETE RESTRICT,
        CONSTRAINT `FK_CONSULTAS_VETERINARIOS_VeterinarioId` FOREIGN KEY (`VeterinarioId`) REFERENCES `VETERINARIOS` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `HISTORICO_PESOS` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `PesoKg` decimal(7,2) NOT NULL,
        `DataMedicao` datetime(6) NOT NULL,
        `Observacao` longtext CHARACTER SET utf8mb4 NULL,
        `PetId` int NOT NULL,
        CONSTRAINT `PK_HISTORICO_PESOS` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_HISTORICO_PESOS_PETS_PetId` FOREIGN KEY (`PetId`) REFERENCES `PETS` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `LEMBRETES` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Tipo` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `Descricao` longtext CHARACTER SET utf8mb4 NOT NULL,
        `DataPrevista` datetime(6) NOT NULL,
        `Status` varchar(1) CHARACTER SET utf8mb4 NOT NULL,
        `TutorId` int NOT NULL,
        `PetId` int NOT NULL,
        CONSTRAINT `PK_LEMBRETES` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_LEMBRETES_PETS_PetId` FOREIGN KEY (`PetId`) REFERENCES `PETS` (`Id`) ON DELETE RESTRICT,
        CONSTRAINT `FK_LEMBRETES_TUTORES_TutorId` FOREIGN KEY (`TutorId`) REFERENCES `TUTORES` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `RECOMENDACOES` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Tipo` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `Descricao` longtext CHARACTER SET utf8mb4 NOT NULL,
        `DataRecomendacao` datetime(6) NOT NULL,
        `PetId` int NOT NULL,
        CONSTRAINT `PK_RECOMENDACOES` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_RECOMENDACOES_PETS_PetId` FOREIGN KEY (`PetId`) REFERENCES `PETS` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `VACINACOES` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `DataAplicacao` datetime(6) NOT NULL,
        `DataProxima` datetime(6) NOT NULL,
        `VacinaAplicada` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `Observacao` longtext CHARACTER SET utf8mb4 NULL,
        `PetId` int NOT NULL,
        `VeterinarioId` int NOT NULL,
        CONSTRAINT `PK_VACINACOES` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_VACINACOES_PETS_PetId` FOREIGN KEY (`PetId`) REFERENCES `PETS` (`Id`) ON DELETE RESTRICT,
        CONSTRAINT `FK_VACINACOES_VETERINARIOS_VeterinarioId` FOREIGN KEY (`VeterinarioId`) REFERENCES `VETERINARIOS` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `VERMIFUGACOES` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Produto` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `DataAplicacao` datetime(6) NOT NULL,
        `DataProxima` datetime(6) NOT NULL,
        `PetId` int NOT NULL,
        `VeterinarioId` int NOT NULL,
        CONSTRAINT `PK_VERMIFUGACOES` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_VERMIFUGACOES_PETS_PetId` FOREIGN KEY (`PetId`) REFERENCES `PETS` (`Id`) ON DELETE RESTRICT,
        CONSTRAINT `FK_VERMIFUGACOES_VETERINARIOS_VeterinarioId` FOREIGN KEY (`VeterinarioId`) REFERENCES `VETERINARIOS` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `EXAMES` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Tipo` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `Descricao` longtext CHARACTER SET utf8mb4 NOT NULL,
        `Resultado` longtext CHARACTER SET utf8mb4 NULL,
        `Data` datetime(6) NOT NULL,
        `ConsultaId` int NOT NULL,
        CONSTRAINT `PK_EXAMES` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_EXAMES_CONSULTAS_ConsultaId` FOREIGN KEY (`ConsultaId`) REFERENCES `CONSULTAS` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `PRESCRICOES` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Dosagem` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `Frequencia` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `DuracaoDias` int NOT NULL,
        `Observacao` longtext CHARACTER SET utf8mb4 NULL,
        `ConsultaId` int NOT NULL,
        CONSTRAINT `PK_PRESCRICOES` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_PRESCRICOES_CONSULTAS_ConsultaId` FOREIGN KEY (`ConsultaId`) REFERENCES `CONSULTAS` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE TABLE `MEDICAMENTOS` (
        `Id` int NOT NULL AUTO_INCREMENT,
        `Nome` varchar(50) CHARACTER SET utf8mb4 NOT NULL,
        `Descricao` longtext CHARACTER SET utf8mb4 NOT NULL,
        `PrescricaoId` int NOT NULL,
        CONSTRAINT `PK_MEDICAMENTOS` PRIMARY KEY (`Id`),
        CONSTRAINT `FK_MEDICAMENTOS_PRESCRICOES_PrescricaoId` FOREIGN KEY (`PrescricaoId`) REFERENCES `PRESCRICOES` (`Id`) ON DELETE RESTRICT
    ) CHARACTER SET=utf8mb4;

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_COMPORTAMENTOS_PetId` ON `COMPORTAMENTOS` (`PetId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_CONSULTAS_PetId` ON `CONSULTAS` (`PetId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_CONSULTAS_VeterinarioId` ON `CONSULTAS` (`VeterinarioId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_EXAMES_ConsultaId` ON `EXAMES` (`ConsultaId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_HISTORICO_PESOS_PetId` ON `HISTORICO_PESOS` (`PetId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_LEMBRETES_PetId` ON `LEMBRETES` (`PetId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_LEMBRETES_TutorId` ON `LEMBRETES` (`TutorId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_MEDICAMENTOS_PrescricaoId` ON `MEDICAMENTOS` (`PrescricaoId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_PETS_ClinicaId` ON `PETS` (`ClinicaId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_PETS_TutorId` ON `PETS` (`TutorId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_PRESCRICOES_ConsultaId` ON `PRESCRICOES` (`ConsultaId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_RECOMENDACOES_PetId` ON `RECOMENDACOES` (`PetId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_VACINACOES_PetId` ON `VACINACOES` (`PetId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_VACINACOES_VeterinarioId` ON `VACINACOES` (`VeterinarioId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_VERMIFUGACOES_PetId` ON `VERMIFUGACOES` (`PetId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_VERMIFUGACOES_VeterinarioId` ON `VERMIFUGACOES` (`VeterinarioId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    CREATE INDEX `IX_VETERINARIOS_ClinicaId` ON `VETERINARIOS` (`ClinicaId`);

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

DROP PROCEDURE IF EXISTS MigrationsScript;
DELIMITER //
CREATE PROCEDURE MigrationsScript()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20260831184514_MySqlInitial') THEN

    INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
    VALUES ('20260831184514_MySqlInitial', '9.0.14');

    END IF;
END //
DELIMITER ;
CALL MigrationsScript();
DROP PROCEDURE MigrationsScript;

COMMIT;

