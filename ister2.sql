-- 230609017 Hilal Zeynep Karaca
-- Mevcut prosedürü temizle (varsa)
DROP PROCEDURE IF EXISTS CalculateKlanCreditBalance;

-- İSTER 2: Klanın Toplam Kredi Bakiyesini Hesaplayan Prosedür (15 Puan)
DELIMITER //

CREATE PROCEDURE CalculateKlanCreditBalance (
    IN InputKlanID INT,
    OUT TotalCredit DECIMAL(10, 2) -- Sonucu döndürecek OUT parametresi
)
BEGIN
    -- KlanID'ye göre Oyuncular tablosundaki KrediBakiyesi toplamını hesaplar
    SELECT
        SUM(KrediBakiyesi) INTO TotalCredit
    FROM
        Oyuncular
    WHERE
        KlanID = InputKlanID;
    
    -- Eğer klana ait oyuncu yoksa ve SUM NULL değer döndürürse, sonucu 0.00 olarak ayarla
    IF TotalCredit IS NULL THEN
        SET TotalCredit = 0.00;
    END IF;
END //

DELIMITER ;


-- İSTER 2 TEST ÇAĞRISI (KANIT SORGUSU)
-- Klan ID 101 için toplam kredi bakiyesini hesaplayacak.
-- Not: Bu testin sonucu, Oyuncular tablosundaki verilere göre 700.50 olmuştur.
SET @Klan101Total = 0; -- Sonucu saklayacak kullanıcı değişkeni tanımlama
CALL CalculateKlanCreditBalance(101, @Klan101Total);
SELECT 
    'Klan ID 101 Toplam Kredi Bakiyesi' AS Aciklama, 
    @Klan101Total AS ToplamBakiye; -- Sonucu gösterme