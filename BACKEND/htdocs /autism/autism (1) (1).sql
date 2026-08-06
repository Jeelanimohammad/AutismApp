-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 16, 2025 at 11:05 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `autism`
--

-- --------------------------------------------------------

--
-- Table structure for table `character_analysis`
--

CREATE TABLE `character_analysis` (
  `id` int(11) NOT NULL,
  `symptom_name` varchar(255) NOT NULL,
  `image_url` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `character_analysis`
--

INSERT INTO `character_analysis` (`id`, `symptom_name`, `image_url`) VALUES
(1, 'Symptom 1', 'http://172.25.59.31/autism/uploads/1758704074_image_1.png'),
(2, 'Symptom 2', 'http://172.25.59.31/autism/uploads/1758704099_image_2.png'),
(3, 'Symptom 3', 'http://172.25.59.31/autism/uploads/1758704111_image_3.png'),
(4, 'Symptom 4', 'http://172.25.59.31/autism/uploads/1758704121_image_4.png'),
(5, 'Symptom 5', 'http://172.25.59.31/autism/uploads/1758704133_image_5.png'),
(6, 'Symptom 6', 'http://172.25.59.31/autism/uploads/1758704145_image_6.png'),
(7, 'Symptom 7', 'http://172.25.59.31/autism/uploads/1758704154_image_7.png');

-- --------------------------------------------------------

--
-- Table structure for table `doctordetails`
--

CREATE TABLE `doctordetails` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctordetails`
--

INSERT INTO `doctordetails` (`id`, `name`, `email`, `password`, `specialization`, `phone`) VALUES
(192211906, 'sandhya', 'sand@gmail.com', '123456', 'pediatrics', '9030553952'),
(192211907, 'Dr. Kalyan', 'kalyan@example.com', 'doctor123', 'Pediatrics', '9876543210');

-- --------------------------------------------------------

--
-- Table structure for table `doctors`
--

CREATE TABLE `doctors` (
  `id` int(11) NOT NULL,
  `doctor_id` varchar(10) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `specialization` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctors`
--

INSERT INTO `doctors` (`id`, `doctor_id`, `name`, `email`, `password`, `phone`, `specialization`, `created_at`) VALUES
(1, '', 'sandhya', 'sandhya@gmail.com', '1234', NULL, NULL, '2025-09-18 09:04:39'),
(4, 'D1001', 'Dr. John Smith', 'johnsmith@gmail.com', '123456', '9876543210', 'Autism Therapy', '2025-10-07 05:14:11'),
(5, 'D904', 'Teja', 'teja@gmail.com', 'abcdefg', '7890006788', 'pediatrics', '2025-10-07 05:19:19'),
(6, 'D1234', 'Dr. Sandhya', 'sandhya@example.com', '123456', '9876543210', 'Pediatrician', '2025-10-07 05:26:47'),
(7, '1357', 'sri', 'sri@gmail.com', 's1234567', '9515454644', 'python', '2025-10-07 07:43:22'),
(8, 'doc123', 'sam', 'sam@gmail.com', '123456', '9009877788', 'pediatrics', '2025-10-08 06:01:34'),
(16, 'doc903', 'keerthi', 'keerthi@gmail.com', '1234567', '9837656489', 'pediatrics', '2025-10-15 05:20:17'),
(18, 't56', 'doctor', 'doctor@gmail.com', '34656656564', '8765974366', 'qew', '2025-10-16 05:25:59'),
(19, 't46', 'afs', 'dsa@gmail.com', '325666566', '5444444745', 'fdg', '2025-10-16 05:30:01'),
(20, 'v33', 'rewt', 'ew@gmail.com', '43568789', '3546895685', 'ghn', '2025-10-16 05:32:10');

-- --------------------------------------------------------

--
-- Table structure for table `parents`
--

CREATE TABLE `parents` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password`
--

CREATE TABLE `password` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `id` int(11) NOT NULL,
  `patient_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `sex` varchar(10) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `password` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`id`, `patient_id`, `name`, `age`, `dob`, `sex`, `phone`, `created_at`, `password`) VALUES
(161, 'P123', 'John Doe', 5, '2025-10-09', 'Male', '9876543210', '2025-10-09 09:29:08', '$2y$10$uSl0x4GlN1tnrvZD/aIsFO7HUYnPwxc6GQwPiIH/aSd/Y6zZMXTqe'),
(162, 'P001', 'Priya R', 38, '1987-06-12', 'Female', '9876543210', '2025-10-10 03:20:51', 'mypassword'),
(165, 'P612', 'samith', 2, '2023-10-11', 'Male', '7555544337', '2025-10-11 06:02:22', '123454'),
(166, 'p907', 'tyy', 2, '2023-10-11', 'Male', '9997654567', '2025-10-11 07:48:02', '1234'),
(167, 'p976', 'wer', 2, '2023-10-11', 'Male', '6776557767', '2025-10-11 08:28:28', '123'),
(168, 'p456', 'sandh', 4, '2021-10-11', 'Male', '8996444333', '2025-10-11 08:55:22', '123'),
(169, 'p956', 'erht', 2, '2023-10-13', 'Male', '9777886678', '2025-10-13 03:01:08', '123'),
(170, 'p234', 'swetiee', 4, '2021-10-13', 'Female', '9058885990', '2025-10-13 05:26:03', '1234'),
(171, 'p677', 'tejasri', 5, '2020-10-14', 'Female', '9047593003', '2025-10-14 04:30:56', '123'),
(172, 'p234', 'keerthi', 8, '2017-10-15', 'Female', '9776544799', '2025-10-15 04:14:57', '123'),
(173, 'P889', 'samith', 1, '2024-10-15', 'Male', '8768885677', '2025-10-15 05:28:23', '1234'),
(174, 'y678', 'sandhya', 3, '2022-10-15', 'Female', '5698955535', '2025-10-15 06:08:59', '1234'),
(175, 'y56', 'rewe', 3, '2022-10-16', 'Male', '9697646757', '2025-10-16 04:09:08', '4677'),
(176, 'UY6', 'EWRW', 4, '2021-10-16', 'Male', '3553246557', '2025-10-16 04:48:43', '76575');

-- --------------------------------------------------------

--
-- Table structure for table `registration`
--

CREATE TABLE `registration` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `specialization` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `symptoms`
--

CREATE TABLE `symptoms` (
  `id` int(11) NOT NULL,
  `symptom_name` varchar(255) NOT NULL,
  `explanation` text DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `age_group` enum('<3','>3') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `symptoms`
--

INSERT INTO `symptoms` (`id`, `symptom_name`, `explanation`, `image_url`, `age_group`) VALUES
(1, 'symptom1', 'Child is not looking at the direction point', 'http://172.25.59.31/autism/uploads/image_1.png\n', '<3'),
(2, 'symptom2', 'Child is not sharing things when asked', 'http://172.25.59.31/autism/uploads/image_2.png\r\n', '<3'),
(3, 'symptom3', 'Child is not imitating my actions', 'http://172.25.59.31/autism/uploads/image_3.png\r\n', '<3'),
(4, 'symptom4', 'Child is finding difficulty to express Smile', 'http://172.25.59.31/autism/uploads/image_4.png\r\n', '<3'),
(5, 'symptom5', 'Has poor Eye contact', 'http://172.25.59.31/autism/uploads/image_5.png\r\n', '<3'),
(6, 'symptom6', 'My child is finding it difficult to understand the gestures', 'http://172.25.59.31/autism/uploads/image_6.png\r\n', '<3'),
(7, 'symptom7', 'My child Prefers to be Alone', 'http://172.25.59.31/autism/uploads/image_7.png\r\n', '<3'),
(8, 'sym01', 'Child Prefers to be Alone', 'http://172.25.59.31/autism/uploads/image_01.png\n', '>3'),
(9, 'sym02', 'Sometimes it feels like child can\'t hear well', 'http://172.25.59.31/autism/uploads/image_02.png\r\n', '>3'),
(10, 'sym03', 'Child grabs elders hands to his/her point of interest', 'http://172.25.59.31/autism/uploads/image_03.png\r\n', '>3'),
(11, 'sym04', 'Child does not involve in imaginative play', 'http://172.25.59.31/autism/uploads/image_04.png\r\n', '>3'),
(12, 'sym05', 'Child has poor eye contact', 'http://172.25.59.31/autism/uploads/image_05.png\r\n', '>3'),
(13, 'sym06', 'Child has abnormal gestures and behviours', 'http://172.25.59.31/autism/uploads/image_06.png\r\n', '>3'),
(14, 'sym07', 'Child does not like to be hugged or touched', 'http://172.25.59.31/autism/uploads/image_07.png\r\n', '>3'),
(15, 'sym08', 'Child is not indulging in imaginative play', 'http://172.25.59.31/autism/uploads/image_08.png\r\n', '>3'),
(16, 'sym09', 'Child is not responding to usual teaching techniques', 'http://172.25.59.31/autism/uploads/image_09.png\r\n', '>3'),
(17, 'sym10', 'Child exhibits strange or savant abilities', 'http://172.25.59.31/autism/uploads/image_10.png\r\n', '>3');

-- --------------------------------------------------------

--
-- Table structure for table `symptom_responses`
--

CREATE TABLE `symptom_responses` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `symptom_name` varchar(255) NOT NULL,
  `response` enum('Yes','No') NOT NULL,
  `conclusion` varchar(250) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `symptom_responses`
--

INSERT INTO `symptom_responses` (`id`, `patient_id`, `symptom_name`, `response`, `conclusion`, `created_at`) VALUES
(287, 167, 'symptom3', 'No', '', '2025-10-11 08:28:42'),
(288, 167, 'symptom4', 'No', '', '2025-10-11 08:28:42'),
(289, 167, 'symptom1', 'No', '', '2025-10-11 08:28:42'),
(290, 167, 'symptom2', 'No', '', '2025-10-11 08:28:42'),
(291, 167, 'symptom7', 'No', '', '2025-10-11 08:28:42'),
(292, 167, 'symptom5', 'No', '', '2025-10-11 08:28:42'),
(293, 167, 'symptom6', 'No', '', '2025-10-11 08:28:42'),
(304, 162, 'symptom3', 'No', '', '2025-10-11 08:36:32'),
(305, 162, 'symptom4', 'No', '', '2025-10-11 08:36:32'),
(306, 162, 'symptom1', 'Yes', '', '2025-10-11 08:36:32'),
(307, 162, 'symptom2', 'No', '', '2025-10-11 08:36:32'),
(308, 162, 'symptom7', 'No', '', '2025-10-11 08:36:32'),
(309, 162, 'symptom5', 'No', '', '2025-10-11 08:36:32'),
(310, 162, 'symptom6', 'No', '', '2025-10-11 08:36:32'),
(311, 168, 'sym06', 'No', '', '2025-10-11 08:55:42'),
(312, 168, 'sym05', 'No', '', '2025-10-11 08:55:42'),
(313, 168, 'sym08', 'No', '', '2025-10-11 08:55:42'),
(314, 168, 'sym07', 'No', '', '2025-10-11 08:55:42'),
(315, 168, 'sym02', 'No', '', '2025-10-11 08:55:42'),
(316, 168, 'sym01', 'Yes', '', '2025-10-11 08:55:42'),
(317, 168, 'sym04', 'No', '', '2025-10-11 08:55:42'),
(318, 168, 'sym03', 'No', '', '2025-10-11 08:55:42'),
(319, 168, 'sym10', 'No', '', '2025-10-11 08:55:42'),
(320, 168, 'sym09', 'No', '', '2025-10-11 08:55:42'),
(321, 169, 'symptom3', 'No', '', '2025-10-13 03:01:25'),
(322, 169, 'symptom4', 'No', '', '2025-10-13 03:01:25'),
(323, 169, 'symptom1', 'Yes', '', '2025-10-13 03:01:25'),
(324, 169, 'symptom2', 'No', '', '2025-10-13 03:01:25'),
(325, 169, 'symptom7', 'No', '', '2025-10-13 03:01:25'),
(326, 169, 'symptom5', 'No', '', '2025-10-13 03:01:25'),
(327, 169, 'symptom6', 'No', '', '2025-10-13 03:01:25'),
(328, 170, 'sym06', 'Yes', '', '2025-10-15 04:15:32'),
(329, 170, 'sym05', 'Yes', '', '2025-10-15 04:15:32'),
(330, 170, 'sym08', 'Yes', '', '2025-10-15 04:15:32'),
(331, 170, 'sym07', 'Yes', '', '2025-10-15 04:15:32'),
(332, 170, 'sym02', 'Yes', '', '2025-10-15 04:15:32'),
(333, 170, 'sym01', 'Yes', '', '2025-10-15 04:15:32'),
(334, 170, 'sym04', 'Yes', '', '2025-10-15 04:15:32'),
(335, 170, 'sym03', 'Yes', '', '2025-10-15 04:15:32'),
(336, 170, 'sym10', 'Yes', '', '2025-10-15 04:15:32'),
(337, 170, 'sym09', 'Yes', '', '2025-10-15 04:15:32'),
(338, 171, 'symptom3', 'No', '', '2025-10-14 04:31:13'),
(339, 171, 'symptom4', 'No', '', '2025-10-14 04:31:13'),
(340, 171, 'symptom1', 'Yes', '', '2025-10-14 04:31:13'),
(341, 171, 'symptom2', 'No', '', '2025-10-14 04:31:13'),
(342, 171, 'symptom7', 'No', '', '2025-10-14 04:31:13'),
(343, 171, 'symptom5', 'No', '', '2025-10-14 04:31:13'),
(344, 171, 'symptom6', 'No', '', '2025-10-14 04:31:13'),
(345, 161, 'Lack of eye contact', 'Yes', '', '2025-10-16 04:00:19'),
(346, 161, 'Repeats words', 'No', '', '2025-10-16 04:00:19'),
(347, 175, 'symptom3', 'No', '', '2025-10-16 04:14:27'),
(348, 175, 'symptom4', 'No', '', '2025-10-16 04:14:27'),
(349, 175, 'symptom1', 'No', '', '2025-10-16 04:14:27'),
(350, 175, 'symptom2', 'No', '', '2025-10-16 04:14:27'),
(351, 175, 'symptom7', 'No', '', '2025-10-16 04:14:27'),
(352, 175, 'symptom5', 'No', '', '2025-10-16 04:14:27'),
(353, 175, 'symptom6', 'No', '', '2025-10-16 04:14:27'),
(354, 175, 'sym06', 'No', '', '2025-10-16 05:24:13'),
(355, 175, 'sym05', 'No', '', '2025-10-16 05:24:13'),
(356, 175, 'sym08', 'No', '', '2025-10-16 05:24:13'),
(357, 175, 'sym07', 'No', '', '2025-10-16 05:24:13'),
(358, 175, 'sym02', 'No', '', '2025-10-16 05:24:13'),
(359, 175, 'sym01', 'No', '', '2025-10-16 05:24:13'),
(360, 175, 'sym04', 'No', '', '2025-10-16 05:24:13'),
(361, 175, 'sym03', 'No', '', '2025-10-16 05:24:13'),
(362, 175, 'sym10', 'No', '', '2025-10-16 05:24:13'),
(363, 175, 'sym09', 'No', '', '2025-10-16 05:24:13');

-- --------------------------------------------------------

--
-- Table structure for table `welcome`
--

CREATE TABLE `welcome` (
  `id` int(11) NOT NULL,
  `doctor_name` varchar(100) NOT NULL,
  `doctor_email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `welcome`
--

INSERT INTO `welcome` (`id`, `doctor_name`, `doctor_email`, `password`, `specialization`, `phone`) VALUES
(1, 'teja', 'teja@gmail.com', 'abcdefg', 'pediatrics', '9030553952');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `character_analysis`
--
ALTER TABLE `character_analysis`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `doctordetails`
--
ALTER TABLE `doctordetails`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `parents`
--
ALTER TABLE `parents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `password`
--
ALTER TABLE `password`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `registration`
--
ALTER TABLE `registration`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `symptoms`
--
ALTER TABLE `symptoms`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `symptom_responses`
--
ALTER TABLE `symptom_responses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_patient` (`patient_id`),
  ADD KEY `fk_symptom` (`symptom_name`);

--
-- Indexes for table `welcome`
--
ALTER TABLE `welcome`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `doctor_email` (`doctor_email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `character_analysis`
--
ALTER TABLE `character_analysis`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `doctordetails`
--
ALTER TABLE `doctordetails`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=192211908;

--
-- AUTO_INCREMENT for table `doctors`
--
ALTER TABLE `doctors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `parents`
--
ALTER TABLE `parents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `password`
--
ALTER TABLE `password`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=177;

--
-- AUTO_INCREMENT for table `registration`
--
ALTER TABLE `registration`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `symptoms`
--
ALTER TABLE `symptoms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `symptom_responses`
--
ALTER TABLE `symptom_responses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=364;

--
-- AUTO_INCREMENT for table `welcome`
--
ALTER TABLE `welcome`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `symptom_responses`
--
ALTER TABLE `symptom_responses`
  ADD CONSTRAINT `fk_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
