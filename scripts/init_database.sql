/*

====================================
Criar banco de dados e esquemas
====================================

Propósito do script:
	
	Esse script cria um novo banco de dados chamado 'DataWarehouse' após verificar se ela já existe.
	Se o banco de dados já existir ele será apagado e recriado. Além disso, o script também cria
	três esquemas para o banco de dados: 'bronze', 'silver' e 'gold'.

AVISO: 

	Executar esse script irá apagar completamente o banco de dados 'DatawareHouse' caso exista.
	Todos os dados do banco serão permanentemente apagados. Proceda com cautela e garanta que
	existam backups antes de rodar este script.
*/

-- Criar banco de dados 'DataWarehouse'

USE master;
GO

-- Dropar e recriar o banco 'DataWarehouse'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse
END;
GO

-- Criar banco de dados 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
