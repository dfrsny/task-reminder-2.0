-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 12, 2024 at 03:07 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_otp`
--

-- --------------------------------------------------------

--
-- Table structure for table `akun`
--

CREATE TABLE `akun` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(200) NOT NULL,
  `phone` varchar(100) NOT NULL,
  `pasw` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `akun`
--

INSERT INTO `akun` (`id`, `username`, `email`, `phone`, `pasw`) VALUES
(1, 'agus5', 'aguspurwanto@gmail.com', '190231284', 'agus123'),
(7, 'ww', 'ww', 'ww', 'ww'),
(8, 'dian', 'dian@gmail.com', '6285742094207', '123');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `otp_device`
--

CREATE TABLE `otp_device` (
  `id` int(11) NOT NULL,
  `nomor` varchar(255) NOT NULL,
  `otp` int(11) NOT NULL,
  `waktu` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `otp_device`
--

INSERT INTO `otp_device` (`id`, `nomor`, `otp`, `waktu`) VALUES
(1, '89637865226', 541473, 1730312269),
(31, '6282366950912', 327851, 1733358876),
(32, '6282239841198', 616674, 1733359943),
(33, '6282241922313', 355202, 1733575806),
(34, '6285742094207', 467465, 1733963992);

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `deadline` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tasks_dian`
--

CREATE TABLE `tasks_dian` (
  `id` int(11) NOT NULL,
  `judul_task` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `deadline` datetime NOT NULL,
  `status_reminder` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks_dian`
--

INSERT INTO `tasks_dian` (`id`, `judul_task`, `description`, `deadline`, `status_reminder`, `created_at`) VALUES
(1, 'dian', 'cek', '2024-12-15 12:00:00', 0, '2024-12-12 00:41:02');

-- --------------------------------------------------------

--
-- Table structure for table `tasks_fansya`
--

CREATE TABLE `tasks_fansya` (
  `id` int(11) NOT NULL,
  `judul_task` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `deadline` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks_fansya`
--

INSERT INTO `tasks_fansya` (`id`, `judul_task`, `description`, `deadline`, `created_at`) VALUES
(1, 'ngetest fan', 'jumatan', '2024-12-06 13:00:00', '2024-12-06 04:57:56');

-- --------------------------------------------------------

--
-- Table structure for table `tasks_farid`
--

CREATE TABLE `tasks_farid` (
  `id` int(11) NOT NULL,
  `judul_task` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `deadline` datetime NOT NULL,
  `status_reminder` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks_farid`
--

INSERT INTO `tasks_farid` (`id`, `judul_task`, `description`, `deadline`, `status_reminder`, `created_at`) VALUES
(1, 'masak mie rit', 'masak mie pas hujan hujan gini enak kan', '2024-12-06 16:00:00', 0, '2024-12-06 08:08:59'),
(2, 'tes', 'test rit', '2024-12-12 12:00:00', 0, '2024-12-12 00:36:22'),
(3, 'tes', 'test rit', '2024-12-12 12:00:00', 0, '2024-12-12 00:36:33');

-- --------------------------------------------------------

--
-- Table structure for table `tasks_resnu`
--

CREATE TABLE `tasks_resnu` (
  `id` int(11) NOT NULL,
  `judul_task` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `deadline` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks_resnu`
--

INSERT INTO `tasks_resnu` (`id`, `judul_task`, `description`, `deadline`, `created_at`) VALUES
(1, 'lagi ngetes ', 'lagi ngetes ke no orang nu, numpang ya', '2024-12-06 15:30:00', '2024-12-06 06:48:09');

-- --------------------------------------------------------

--
-- Table structure for table `tasks_sely`
--

CREATE TABLE `tasks_sely` (
  `id` int(11) NOT NULL,
  `judul_task` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `deadline` datetime NOT NULL,
  `status_reminder` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks_sely`
--

INSERT INTO `tasks_sely` (`id`, `judul_task`, `description`, `deadline`, `status_reminder`, `created_at`) VALUES
(1, 'sely', 'jangan lupa beliin mie ayam 1', '2024-12-09 15:00:00', 0, '2024-12-07 12:38:47');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `status` enum('gratis','premium') DEFAULT 'gratis',
  `task_limit` int(11) DEFAULT 20,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `phone`, `username`, `email`, `password`, `status`, `task_limit`, `created_at`) VALUES
(19, '6282239841198', 'fansya', 'fansya@gmail.com', '$2y$10$X5iUh8nOBgYDY2UgMn2NqerUz.9YiClH3e69WP2hDlJ5uY38L3ZrS', 'gratis', 19, '2024-12-06 04:57:28'),
(20, '6289504862863', 'resnu', 'resnu@gmail.com', '$2y$10$hC9LhPduaBcWQ2K2TP0yDO./UN6HXaEKKmMySl/hMv/o1CbNFo8ty', 'gratis', 19, '2024-12-06 06:47:29'),
(22, '6281324452192', 'farid', 'farid', '$2y$10$ycBz9bQcn8zaN7snqnVgZu7dArmHRU/H/KCygaHV5IPZ.HpdK1Ddu', 'gratis', 19, '2024-12-06 08:08:13'),
(23, '6282241922313', 'sely', 'sely@gmail.com', '$2y$10$nj8tAyVGIxJZTTYzPIGdsuoeoykj.VGupqOsPVYnXJ2YFbYtFOv2u', 'gratis', 19, '2024-12-07 12:38:11'),
(24, '6285742094207', 'dian', 'dian@gmail.com', '$2y$10$3lgrEwHeMPEAtLScB5AlDu.IYM3e3HSiA6zbXrn6ilgbxg0lNYGTK', 'gratis', 39, '2024-12-12 00:39:36');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `akun`
--
ALTER TABLE `akun`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `task_id` (`task_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `otp_device`
--
ALTER TABLE `otp_device`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tasks_dian`
--
ALTER TABLE `tasks_dian`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tasks_fansya`
--
ALTER TABLE `tasks_fansya`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tasks_farid`
--
ALTER TABLE `tasks_farid`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tasks_resnu`
--
ALTER TABLE `tasks_resnu`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tasks_sely`
--
ALTER TABLE `tasks_sely`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `akun`
--
ALTER TABLE `akun`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `otp_device`
--
ALTER TABLE `otp_device`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tasks_dian`
--
ALTER TABLE `tasks_dian`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tasks_fansya`
--
ALTER TABLE `tasks_fansya`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tasks_farid`
--
ALTER TABLE `tasks_farid`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tasks_resnu`
--
ALTER TABLE `tasks_resnu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tasks_sely`
--
ALTER TABLE `tasks_sely`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
