-- 230609017 Hilal Zeynep Karaca
-- İSTER 3 İÇİN GEREKLİ LOG TABLOSUNU OLUŞTURMA
DROP TABLE IF EXISTS Seviye_Log;

CREATE TABLE Seviye_Log (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    KarakterID INT NOT NULL,
    EskiSeviye INT INT NOT NULL,
    YeniSeviye INT NOT NULL,
    DegisimZamani DATETIME DEFAULT NOW(),
    -- Karakterler tablosuna yabancı anahtar referansı
    FOREIGN KEY (KarakterID) REFERENCES Karakterler(KarakterID) 
);

-- Mevcut tetikleyiciyi temizle (varsa)
DROP TRIGGER IF EXISTS trg_SeviyeDegisikligiLoglama;

-- İSTER 3: Tetikleyici Tanımı
DELIMITER //

CREATE TRIGGER trg_SeviyeDegisikligiLoglama
AFTER UPDATE ON Karakterler -- Karakterler tablosu güncellendikten hemen sonra çalışır
FOR EACH ROW -- Güncellenen her bir satır için çalışır
BEGIN
    -- Yalnızca Seviye sütununda bir değişiklik varsa loglama işlemini gerçekleştir
    IF NEW.Seviye <> OLD.Seviye THEN
        INSERT INTO Seviye_Log (
            KarakterID,
            EskiSeviye,
            YeniSeviye,
            DegisimZamani
        )
        VALUES (
            NEW.KarakterID, -- Güncellenen karakterin ID'si
            OLD.Seviye,     -- Güncelleme öncesi seviye (eski değer)
            NEW.Seviye,     -- Güncelleme sonrası seviye (yeni değer)
            NOW()           -- İşlem zamanı
        );
    END IF;
END //

DELIMITER ;


-- İSTER 3 TEST ÇAĞRILARI (KANIT SORGULARI)

-- 1. TEST ADIMI: Karakter ID 100'ün seviyesini 65'e yükselt.
-- Bu işlem tetikleyiciyi otomatik olarak çalıştırmalıdır.
UPDATE Karakterler
SET Seviye = 65
WHERE KarakterID = 100;

-- 2. KANIT SORGUSU: Seviye_Log tablosunu sorgula
-- Çıktı, seviye değişiminin loglandığını kanıtlayacaktır (55 -> 65).
SELECT * FROM Seviye_Log WHERE KarakterID = 100;