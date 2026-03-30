-- 230609017 Hilal Zeynep KARACA
--TABLO VE PROSEDÜRLERİ TEMİZLEME
DROP TABLE IF EXISTS Karakterler;
DROP TABLE IF EXISTS Oyuncular;
DROP TABLE IF EXISTS Oyunlar;
DROP TABLE IF EXISTS Klanlar;
DROP PROCEDURE IF EXISTS GetHighLevelCharacters;
DROP PROCEDURE IF EXISTS CalculateKlanCreditBalance;
-- Diğer tablolarI temizleme 
DROP TABLE IF EXISTS Seviye_Log;
DROP TABLE IF EXISTS Envanter;
DROP TABLE IF EXISTS Esyalar;


-- 1. TABLOLARI OLUŞTURMA
CREATE TABLE Klanlar (
    KlanID INT PRIMARY KEY,
    KlanAdi VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Oyunlar (
    OyunID INT PRIMARY KEY,
    OyunAdi VARCHAR(100) NOT NULL UNIQUE,
    Tür VARCHAR(50)
);

-- Önceki arayüz hatalarını engellemek için 
CREATE TABLE Oyuncular (
    OyuncuID INT PRIMARY KEY,
    KullaniciAdi VARCHAR(50) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    KayitTarihi DATE,
    KrediBakiyesi DECIMAL(10, 2),
    KlanID INT, 
    FOREIGN KEY (KlanID) REFERENCES Klanlar(KlanID)
);

CREATE TABLE Karakterler (
    KarakterID INT PRIMARY KEY,
    KarakterAdi VARCHAR(50) NOT NULL,
    Seviye INT DEFAULT 1,
    Guc INT DEFAULT 10,
    OyuncuID INT NOT NULL,
    OyunID INT NOT NULL,
    FOREIGN KEY (OyuncuID) REFERENCES Oyuncular(OyuncuID),
    FOREIGN KEY (OyunID) REFERENCES Oyunlar(OyunID)
);


-- 2. TEST VERİLERİNİ EKLEME 
INSERT INTO Klanlar (KlanID, KlanAdi) VALUES (101, 'Ejderha Savaşçıları');
INSERT INTO Oyunlar (OyunID, OyunAdi, Tür) VALUES (10, 'EpicQuest MMO', 'RPG');

INSERT INTO Oyuncular (OyuncuID, KullaniciAdi, Email, KayitTarihi, KrediBakiyesi, KlanID) VALUES
(1, 'GamerLord', 'g@email.com', CURDATE(), 500.50, 101),
(5, 'TestUser', 't@email.com', CURDATE(), 200.00, 101);

INSERT INTO Karakterler (KarakterID, KarakterAdi, Seviye, Guc, OyuncuID, OyunID) VALUES
(100, 'KilicUstasi', 55, 120, 1, 10),
(104, 'TankGorki', 60, 200, 5, 10);


-- 3. İSTER 1: PROSEDÜRÜ OLUŞTURMA
DELIMITER //

CREATE PROCEDURE GetHighLevelCharacters (
    IN InputOyunID INT,
    IN MinSeviye INT
)
BEGIN
    SELECT
        K.KarakterAdi,
        K.Seviye,
        O.KullaniciAdi AS SahipKullaniciAdi
    FROM
        Karakterler K
    INNER JOIN
        Oyuncular O ON K.OyuncuID = O.OyuncuID
    WHERE
        K.OyunID = InputOyunID
        AND K.Seviye > MinSeviye
    ORDER BY
        K.Seviye DESC;
END //

DELIMITER ;


-- 4. İSTER 1 TEST ÇAĞRISI (KANIT SORGUSU)
-- Beklenen sonuç: TankGorki (60) ve KilicUstasi (55)
CALL GetHighLevelCharacters(10, 45);