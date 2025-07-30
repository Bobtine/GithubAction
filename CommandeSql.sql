-- Utilisation de la base
USE TestProduitsDB;
GO

-- Remplace par le nom exact de ton identité managée pour l'appservice
CREATE USER [azure-api-demo123] FROM EXTERNAL PROVIDER;

ALTER ROLE db_datareader ADD MEMBER [azure-api-demo123];
ALTER ROLE db_datawriter ADD MEMBER [azure-api-demo123];


-- Utilisation de la base
USE TestProduitsDB;
GO

-- Création de la table Categories
CREATE TABLE Categories (
    IdCategorie INT PRIMARY KEY IDENTITY(1,1),
    NomCategorie NVARCHAR(100) NOT NULL
);
GO

-- Création de la table Produits
CREATE TABLE Produits (
    IdProduit INT PRIMARY KEY IDENTITY(1,1),
    NomProduit NVARCHAR(150) NOT NULL,
    Prix DECIMAL(10, 2) NOT NULL,
    IdCategorie INT FOREIGN KEY REFERENCES Categories(IdCategorie)
);
GO

-- Insertion de données de test dans Categories
INSERT INTO Categories (NomCategorie)
VALUES 
    ('Électronique'),
    ('Vêtements'),
    ('Alimentation'),
    ('Bricolage'),
    ('Livres');
GO

-- Insertion de données de test dans Produits
INSERT INTO Produits (NomProduit, Prix, IdCategorie)
VALUES 
    ('Téléphone Samsung', 799.99, 1),
    ('T-shirt en coton', 19.99, 2),
    ('Baguette de pain', 1.25, 3),
    ('Perceuse sans fil', 89.90, 4),
    ('Roman "1984"', 12.50, 5),
    ('Casque Bluetooth', 59.99, 1),
    ('Pantalon jeans', 49.99, 2),
    ('Céréales bio', 4.95, 3),
    ('Tournevis étoile', 5.00, 4),
    ('Livre de recettes', 15.00, 5);
GO

-- Vérification du contenu
SELECT * FROM Categories;
SELECT * FROM Produits;
