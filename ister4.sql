-- 230609017 Hilal Zeynep Karaca
--GEREKLİ TEMİZLİKLER: TÜM ESKİ TABLOLARI VE PROSEDÜRLERİ SİLEREK BAĞIMSIZLIK SAĞLAMA
DROP TRIGGER IF EXISTS trg_SeviyeDegisikligiLoglama;
DROP PROCEDURE IF EXISTS GeriAlSeviyeDegisikligi;
DROP TABLE IF EXISTS Seviye_Log;
DROP TABLE IF EXISTS Karakterler;
DROP TABLE IF EXISTS Oyuncular;
DROP TABLE IF EXISTS Oyunlar;
DROP TABLE IF EXISTS Klanlar;

-- 1. TEMEL TABLOLARI YENİDEN OLUŞTURMA
CREATE TABLE Klanlar (KlanID INT PRIMARY KEY, KlanAdi VARCHAR(100) NOT NULL UNIQUE);
CREATE TABLE Oyunlar (OyunID INT PRIMARY KEY, OyunAdi VARCHAR(100) NOT NULL UNIQUE, Tür VARCHAR(50));
CREATE TABLE Oyuncular (
    OyuncuID INT PRIMARY KEY, KullaniciAdi VARCHAR(50) NOT NULL UNIQUE, Email VARCHAR(100) NOT NULL UNIQUE, 
    KayitTarihi DATE, KrediBakiyesi DECIMAL(10, 2), KlanID INT, FOREIGN KEY (KlanID) REFERENCES Klanlar(KlanID)
);
CREATE TABLE Karakterler (
    KarakterID INT PRIMARY KEY, KarakterAdi VARCHAR(50) NOT NULL, Seviye INT DEFAULT 1, Guc INT DEFAULT 10,
    OyuncuID INT NOT NULL, OyunID INT NOT NULL, FOREIGN KEY (OyuncuID) REFERENCES Oyuncular(OyuncuID), 
    FOREIGN KEY (OyunID) REFERENCES Oyunlar(OyunID)
);
-- İSTER 3/4 LOG TABLOSU
CREATE TABLE Seviye_Log (
    LogID INT PRIMARY KEY AUTO_INCREMENT, KarakterID INT NOT NULL, EskiSeviye INT NOT NULL, YeniSeviye INT NOT NULL,
    DegisimZamani DATETIME DEFAULT NOW(), FOREIGN KEY (KarakterID) REFERENCES Karakterler(KarakterID)
);

-- 2. TEST VERİLERİNİ EKLEME (KANIT İÇİN GEREKLİ VERİLER)
INSERT INTO Klanlar (KlanID, KlanAdi) VALUES (101, 'Ejderha Savaşçıları');
INSERT INTO Oyunlar (OyunID, OyunAdi, Tür) VALUES (10, 'EpicQuest MMO', 'RPG');
INSERT INTO Oyuncular (OyuncuID, KullaniciAdi, Email, KayitTarihi, KrediBakiyesi, KlanID) VALUES
(1, 'GamerLord', 'g@email.com', CURDATE(), 500.50, 101);
INSERT INTO Karakterler (KarakterID, KarakterAdi, Seviye, Guc, OyuncuID, OyunID) VALUES
(100, 'KilicUstasi', 55, 120, 1, 10); 

-- İŞLEM ÖNCESİ DURUMU AYARLAMA (Seviyeyi 65 yap ve log kaydını ekle)
UPDATE Karakterler SET Seviye = 65 WHERE KarakterID = 100; -- Mevcut seviye 65
INSERT INTO Seviye_Log (KarakterID, EskiSeviye, YeniSeviye) VALUES (100, 55, 65); -- Log: 55'ten 65'e yükselmiş


-- 3. İSTER 4: Geri Alma Prosedürü (CURSOR kullanımını basitleştirilmiş, stabil versiyon)
DELIMITER //

CREATE PROCEDURE GeriAlSeviyeDegisikligi (
    IN InputKarakterID INT
)
BEGIN
    -- Log tablosundan en son kaydın LogID'si ve EskiSeviye değerini al
    DECLARE SonLogID INT;
    DECLARE EskiSeviyeDegeri INT;

    SELECT LogID, EskiSeviye INTO SonLogID, EskiSeviyeDegeri
    FROM Seviye_Log
    WHERE KarakterID = InputKarakterID
    ORDER BY LogID DESC -- En son log kaydını bulmak için
    LIMIT 1;

    -- Eğer karakter için log kaydı bulunduysa işlemi yap
    IF SonLogID IS NOT NULL THEN
        -- a) Karakterin seviyesini logdaki EskiSeviye değeriyle GÜNCELLE
        UPDATE Karakterler
        SET Seviye = EskiSeviyeDegeri
        WHERE KarakterID = InputKarakterID;

        -- b) Log kaydını Seviye_Log tablosundan SİL
        DELETE FROM Seviye_Log
        WHERE LogID = SonLogID;
    END IF;
END //

DELIMITER ;


-- 4. İSTER 4 TEST ÇAĞRILARI (KANIT İÇİN SORGULAR) (5 Puan)

-- 1. KONTROL: İŞLEMDEN ÖNCE (Seviye 65, Logda 1 kayıt olmalı)
SELECT '--- 1. DURUM: İŞLEMDEN ÖNCE ---' AS Durum;
SELECT Seviye AS MevcutSeviye FROM Karakterler WHERE KarakterID = 100;
SELECT * FROM Seviye_Log WHERE KarakterID = 100; 

-- PROSEDÜR ÇAĞRISI
CALL GeriAlSeviyeDegisikligi(100);

-- 2. KONTROL: İŞLEMDEN SONRA (Seviye 55, Logda 0 kayıt olmalı)
SELECT '--- 2. DURUM: İŞLEMDEN SONRA ---' AS Durum;
SELECT Seviye AS YeniSeviye FROM Karakterler WHERE KarakterID = 100; -- Beklenen: 55
SELECT * FROM Seviye_Log WHERE KarakterID = 100; -- Beklenen: Boş sonuç