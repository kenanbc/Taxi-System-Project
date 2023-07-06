-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jul 06, 2023 at 09:14 PM
-- Server version: 5.7.36
-- PHP Version: 7.4.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `taxi_sistem`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
CREATE TABLE IF NOT EXISTS `admin` (
  `admin_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) DEFAULT NULL,
  `lozinka` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`admin_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`admin_id`, `username`, `lozinka`) VALUES
(1, 'kenanbabic', 'sifra123');

-- --------------------------------------------------------

--
-- Table structure for table `korisnik`
--

DROP TABLE IF EXISTS `korisnik`;
CREATE TABLE IF NOT EXISTS `korisnik` (
  `korisnik_id` int(11) NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) DEFAULT NULL,
  `lozinka` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`korisnik_id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `korisnik`
--

INSERT INTO `korisnik` (`korisnik_id`, `ime`, `lozinka`) VALUES
(1, 'aminaosmanhodzic', 'sifra123'),
(2, 'aniskaric', 'sifra123'),
(3, 'belmaosmic', 'sifra123'),
(12, 'nusretavdic', 'sifra');

-- --------------------------------------------------------

--
-- Table structure for table `vozac`
--

DROP TABLE IF EXISTS `vozac`;
CREATE TABLE IF NOT EXISTS `vozac` (
  `vozac_id` int(11) NOT NULL AUTO_INCREMENT,
  `ime` varchar(50) DEFAULT NULL,
  `prezime` varchar(50) DEFAULT NULL,
  `broj_telefona` varchar(50) DEFAULT NULL,
  `adresa` varchar(50) DEFAULT NULL,
  `vozilo_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`vozac_id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `vozac`
--

INSERT INTO `vozac` (`vozac_id`, `ime`, `prezime`, `broj_telefona`, `adresa`, `vozilo_id`) VALUES
(1, 'Hamid', 'Rustemovic', '061995927', 'Klokotnica', 1),
(2, 'Ramiz', 'Omerbasic', '062896937', 'Mese Selimovica 12', NULL),
(3, 'Nusret', 'Basic', '062456310', 'Rudarska 16', 3),
(4, 'Adnan', 'Hilmic', '063427516', 'Dzafer mahala 14', 2),
(5, 'Damir', 'Bajric', '064453015', 'Rudarska 51', 6),
(6, 'Ahmed', 'Halilovic', '066318219', 'Rudarska 25', 4),
(7, 'Muhibija', 'Besic', '061590876', 'VI Bosanske brigade 63', 24),
(8, 'Hilmija', 'Muslimovic', '064412584', 'Krecanska 12', 23),
(9, 'Muradif', 'Ramic', '065678222', '2. Oktobra', 13),
(10, 'Fazlija', 'Tokic', '062412412', 'Alije Isakovica 21', 10),
(11, 'Jasmin', 'Bekric', '062234190', 'Bulevar 49', 25),
(12, 'Josip', 'Topic', '063149291', 'Mese Selimovica 54', 26);

-- --------------------------------------------------------

--
-- Table structure for table `vozila`
--

DROP TABLE IF EXISTS `vozila`;
CREATE TABLE IF NOT EXISTS `vozila` (
  `vozilo_id` int(11) NOT NULL AUTO_INCREMENT,
  `marka` varchar(50) DEFAULT NULL,
  `model` varchar(50) DEFAULT NULL,
  `registracija` varchar(50) DEFAULT NULL,
  `stanje` varchar(50) DEFAULT NULL,
  `vozac_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`vozilo_id`),
  KEY `FK_vozac_id` (`vozac_id`)
) ENGINE=MyISAM AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `vozila`
--

INSERT INTO `vozila` (`vozilo_id`, `marka`, `model`, `registracija`, `stanje`, `vozac_id`) VALUES
(1, 'Volkswagen', 'Passat-B6', 'TA-932158', 'Voznja', 1),
(2, 'Volkswagen', 'Golf-6', 'TA-569252', 'Pauza', 4),
(3, 'Volkswagen', 'Golf-5', 'TA-642029', 'Voznja', 3),
(10, 'Toyota', 'Swift', 'TA-098246', 'Servis', 10),
(4, 'Renault', 'Scenic', 'J12-M-697', 'Voznja', 6),
(6, 'Renault', 'Twingo', 'TA-445191', 'Voznja', 5),
(13, 'Ford', 'Focus', 'TA-729134', 'Voznja', 9),
(23, 'Volkswagen', 'Polo', 'TA-245302', 'Voznja', 8),
(24, 'Peugeot', '407', 'TA-492104', 'Voznja', 7),
(25, 'Volkswagen', 'Touran', 'TA-516931', 'Slobodno', 11),
(26, 'Opel', 'Astra', 'TA-193013', 'Pauza', 12),
(27, 'Mercedes', 'A180', 'TA-371491', 'Slobodno', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `voznja`
--

DROP TABLE IF EXISTS `voznja`;
CREATE TABLE IF NOT EXISTS `voznja` (
  `voznja_id` int(11) NOT NULL AUTO_INCREMENT,
  `polaziste` varchar(50) DEFAULT NULL,
  `odrediste` varchar(50) DEFAULT NULL,
  `broj_putnika` int(11) DEFAULT NULL,
  `cijena_voznje` int(11) DEFAULT NULL,
  `vozilo_id` int(11) NOT NULL,
  `putnik_id` int(11) NOT NULL,
  PRIMARY KEY (`voznja_id`),
  KEY `FK_vozilo_id` (`vozilo_id`)
) ENGINE=MyISAM AUTO_INCREMENT=20 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `voznja`
--

INSERT INTO `voznja` (`voznja_id`, `polaziste`, `odrediste`, `broj_putnika`, `cijena_voznje`, `vozilo_id`, `putnik_id`) VALUES
(2, 'Slatina', 'Sjenjak', 2, 7, 1, 1),
(3, 'Tusanj', 'Gradina', 4, 6, 2, 2),
(4, 'Gradina', 'Rudarska', 3, 10, 3, 3),
(5, 'Mosnik', 'Slatina', 1, 5, 4, 2),
(8, 'Slatina', 'Skver', 2, 11, 2, 3),
(9, 'Mosnik', 'Sjenjak', 1, 10, 4, 3),
(10, 'Kicelj', 'Tusanj', 4, 9, 1, 1),
(11, 'Skver', 'Gradina', 2, 15, 1, 3),
(12, 'Tusanj', 'Bulevar', 6, 12, 13, 3),
(13, 'Slatina', 'Tusanj', 2, 15, 23, 3),
(14, 'Lukavac', 'Stupine', 5, 8, 4, 1),
(15, 'Stanica', 'Skver', 5, 11, 6, 3),
(16, 'Slatina', 'Lukavac', 2, 9, 1, 2),
(17, 'Brcanska', 'Slatina', 2, 13, 4, 3),
(18, 'Bulevar', 'Tusanj', 4, 14, 3, 3),
(19, 'Slatina', 'Tusanj', 2, 5, 24, 1);

-- --------------------------------------------------------

--
-- Table structure for table `zarada`
--

DROP TABLE IF EXISTS `zarada`;
CREATE TABLE IF NOT EXISTS `zarada` (
  `zarada_id` int(11) NOT NULL AUTO_INCREMENT,
  `cijena_voznje` int(11) DEFAULT NULL,
  `vozac_id` int(11) NOT NULL,
  `voznja_id` int(11) NOT NULL,
  PRIMARY KEY (`zarada_id`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `zarada`
--

INSERT INTO `zarada` (`zarada_id`, `cijena_voznje`, `vozac_id`, `voznja_id`) VALUES
(1, 7, 1, 2),
(2, 6, 2, 3),
(3, 10, 3, 4),
(4, 5, 4, 5),
(5, 11, 2, 8),
(6, 10, 4, 9),
(7, 11, 5, 15),
(8, 9, 1, 16),
(9, 9, 1, 10),
(10, 15, 1, 11),
(11, 12, 9, 12),
(12, 15, 8, 13),
(13, 8, 4, 14),
(14, 13, 4, 17),
(15, 14, 3, 18),
(16, 5, 7, 19);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
