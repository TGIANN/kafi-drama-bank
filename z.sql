-- --------------------------------------------------------
-- Sunucu:                       127.0.0.1
-- Sunucu sürümü:                10.4.18-MariaDB - mariadb.org binary distribution
-- Sunucu İşletim Sistemi:       Win64
-- HeidiSQL Sürüm:               11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- tablo yapısı dökülüyor es_extended.banklog
CREATE TABLE IF NOT EXISTS `banklog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `money` varchar(50) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `sender` varchar(50) DEFAULT NULL,
  `iban` varchar(50) DEFAULT NULL,
  `profilepicture` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4;

-- es_extended.banklog: ~0 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `banklog` DISABLE KEYS */;
/*!40000 ALTER TABLE `banklog` ENABLE KEYS */;

-- tablo yapısı dökülüyor es_extended.banklogsontransfer
CREATE TABLE IF NOT EXISTS `banklogsontransfer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) DEFAULT NULL,
  `isim` varchar(50) DEFAULT NULL,
  `foto` varchar(50) DEFAULT NULL,
  `iban` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4;

-- es_extended.banklogsontransfer: ~1 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `banklogsontransfer` DISABLE KEYS */;
INSERT INTO `banklogsontransfer` (`id`, `identifier`, `isim`, `foto`, `iban`) VALUES
	(28, 'c16d8191f1855aaaa21d1660b4168e373842eb5a', 'Sadasd Asdasd', 'Gönderilen Profil Resim', '1');
/*!40000 ALTER TABLE `banklogsontransfer` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
