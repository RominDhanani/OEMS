-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 10, 2026 at 09:39 AM
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
-- Database: `OEMS`
--
CREATE DATABASE IF NOT EXISTS `OEMS` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `OEMS`;

-- --------------------------------------------------------

--
-- Table structure for table `expansion_funds`
--

CREATE TABLE `expansion_funds` (
  `id` int(11) NOT NULL,
  `manager_id` int(11) NOT NULL,
  `requested_amount` decimal(15,2) NOT NULL,
  `approved_amount` decimal(15,2) DEFAULT NULL,
  `justification` text NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','ALLOCATED') DEFAULT 'PENDING',
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` int(11) DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expansion_funds`
--

INSERT INTO `expansion_funds` (`id`, `manager_id`, `requested_amount`, `approved_amount`, `justification`, `status`, `requested_at`, `reviewed_at`, `reviewed_by`, `rejection_reason`, `created_at`, `updated_at`) VALUES
(22, 20, 800.00, 800.00, 'Expansion fund for approved expense: headohone  (ID: 37)', 'ALLOCATED', '2026-02-05 10:39:44', '2026-02-05 10:53:17', 1, NULL, '2026-02-05 10:39:44', '2026-02-05 10:57:58'),
(23, 20, 6000.00, 6000.00, 'Expansion fund for approved expense: buy a Moniter (ID: 36)', 'ALLOCATED', '2026-02-05 10:44:55', '2026-02-05 10:52:58', 1, NULL, '2026-02-05 10:44:55', '2026-02-05 10:55:05'),
(24, 20, 500.00, 500.00, 'Expansion fund for approved expense: buy water bottle (ID: 40)', 'ALLOCATED', '2026-02-06 11:09:29', '2026-02-06 11:11:17', 1, NULL, '2026-02-06 11:09:29', '2026-02-06 11:12:04'),
(25, 18, 300.00, 300.00, 'Expansion fund for approved expense: buy A4 Size paper (ID: 42)', 'ALLOCATED', '2026-02-09 10:40:51', '2026-02-09 10:43:53', 1, NULL, '2026-02-09 10:40:51', '2026-02-09 10:44:45'),
(38, 18, 1500.00, 1500.00, 'Expansion fund for approved expense: buy HDD (ID: 53)', 'ALLOCATED', '2026-02-10 09:51:10', '2026-02-10 09:53:01', 1, NULL, '2026-02-10 09:51:10', '2026-02-10 10:12:22'),
(41, 20, 500.00, 500.00, 'Expansion fund for approved expense: buy mouse (ID: 55)', 'ALLOCATED', '2026-02-10 11:50:25', '2026-02-10 11:51:01', 1, NULL, '2026-02-10 11:50:25', '2026-02-10 11:52:12'),
(43, 18, 7000.00, 7000.00, 'Expansion fund for approved expense: for wifi bill (ID: 58)', 'ALLOCATED', '2026-02-11 06:56:03', '2026-02-11 06:56:53', 1, NULL, '2026-02-11 06:56:03', '2026-02-11 06:57:13'),
(58, 20, 1500.00, 1500.00, 'Expansion fund for approved expense: for watter bill (ID: 59)', 'ALLOCATED', '2026-02-11 10:43:33', '2026-02-11 12:02:05', 1, NULL, '2026-02-11 10:43:33', '2026-02-11 12:02:19'),
(60, 18, 4000.00, 4000.00, 'Expansion fund for approved expense: website hosting (ID: 62)', 'ALLOCATED', '2026-02-12 06:32:13', '2026-02-12 06:39:16', 1, NULL, '2026-02-12 06:32:13', '2026-02-12 06:40:05'),
(61, 18, 400.00, 400.00, 'Expansion for Team Expense: Domain purchase (ID: 61)', 'ALLOCATED', '2026-03-11 07:09:42', '2026-03-23 08:39:54', 1, NULL, '2026-03-11 07:09:42', '2026-03-23 08:40:39'),
(64, 18, 2000.00, 2000.00, 'Expansion fund for approved expense: for company client (ID: 65)', 'ALLOCATED', '2026-04-01 05:44:48', '2026-04-01 07:47:36', 1, NULL, '2026-04-01 05:44:48', '2026-04-01 07:48:59'),
(67, 18, 2600.00, 2600.00, 'Expansion fund for approved expense: web hosting (ID: 69)', 'ALLOCATED', '2026-04-02 06:51:06', '2026-04-02 06:55:15', 1, NULL, '2026-04-02 06:51:06', '2026-04-02 07:06:26'),
(68, 20, 2000.00, 2000.00, 'Expansion fund for approved expense: birthday celebration (ID: 70)', 'ALLOCATED', '2026-04-02 09:29:04', '2026-04-09 04:28:14', 1, NULL, '2026-04-02 09:29:04', '2026-04-09 04:29:25');

-- --------------------------------------------------------

--
-- Table structure for table `expansion_fund_documents`
--

CREATE TABLE `expansion_fund_documents` (
  `id` int(11) NOT NULL,
  `expansion_fund_id` int(11) NOT NULL,
  `document_path` varchar(500) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `file_type` varchar(50) NOT NULL,
  `file_size` int(11) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `category` varchar(100) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `expense_date` date NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('PENDING_APPROVAL','APPROVED','REJECTED','RECEIPT_APPROVED','FUND_ALLOCATED','COMPLETED') DEFAULT 'PENDING_APPROVAL',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `fund_provided_at` timestamp NULL DEFAULT NULL,
  `receipt_confirmed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`id`, `user_id`, `title`, `category`, `department`, `amount`, `expense_date`, `description`, `status`, `approved_by`, `approved_at`, `rejection_reason`, `fund_provided_at`, `receipt_confirmed_at`, `created_at`, `updated_at`) VALUES
(36, 19, 'buy a Moniter', 'Equipment', 'IT', 6000.00, '2026-02-04', 'buy a new moniter for new employee', 'COMPLETED', 20, '2026-02-05 10:36:17', NULL, NULL, '2026-02-05 11:03:14', '2026-02-05 10:14:32', '2026-02-05 11:03:14'),
(37, 19, 'headohone ', 'Equipment', 'Sales', 800.00, '2026-02-05', 'buy a new headphone', 'COMPLETED', 20, '2026-02-05 10:36:11', NULL, NULL, '2026-02-05 11:03:19', '2026-02-05 10:34:00', '2026-02-05 11:03:19'),
(38, 20, 'client meeting', 'Travel', 'Sales', 1500.00, '2026-02-05', 'travel for a client meeting in surat', 'COMPLETED', 1, '2026-02-05 11:20:13', NULL, NULL, '2026-02-05 11:22:12', '2026-02-05 11:01:14', '2026-02-05 11:22:12'),
(39, 20, 'dinner', 'Meals & Entertainment', 'Marketing', 2000.00, '2026-02-05', 'marketing team dinner', 'COMPLETED', 1, '2026-02-05 11:20:10', NULL, NULL, '2026-02-05 11:22:24', '2026-02-05 11:02:35', '2026-02-05 11:22:24'),
(40, 19, 'buy water bottle', 'Office Supplies', 'Marketing', 500.00, '2026-02-05', 'buy new water bottle', 'COMPLETED', 20, '2026-02-06 11:09:14', NULL, NULL, '2026-02-06 11:14:00', '2026-02-06 10:29:57', '2026-02-06 11:14:00'),
(42, 21, 'buy A4 Size paper', 'Office Supplies', 'Finance', 300.00, '2026-02-09', 'buy A4 size paper ', 'COMPLETED', 18, '2026-02-09 10:39:07', NULL, NULL, '2026-02-09 10:47:00', '2026-02-09 10:37:03', '2026-02-09 10:47:00'),
(46, 18, 'sports day celebration', 'Meals & Entertainment', 'Marketing', 3000.00, '2026-02-09', 'sports day celebration', 'COMPLETED', 1, '2026-02-10 05:58:25', NULL, NULL, '2026-02-10 06:08:38', '2026-02-10 05:57:04', '2026-02-10 06:08:38'),
(53, 21, 'buy HDD', 'Equipment', 'Marketing', 1500.00, '2026-02-10', 'buy 1TB HDD', 'COMPLETED', 18, '2026-02-10 09:50:35', NULL, NULL, '2026-02-10 11:09:04', '2026-02-10 09:49:11', '2026-02-10 11:09:04'),
(54, 18, 'for client meeting venue', 'Accommodation', 'IT', 1800.00, '2026-02-10', 'for client meeting', 'COMPLETED', 1, '2026-02-10 11:15:55', NULL, NULL, '2026-02-10 11:45:09', '2026-02-10 11:15:12', '2026-02-10 11:45:09'),
(55, 19, 'buy mouse', 'Equipment', 'Operations', 500.00, '2026-02-10', 'buy mouse', 'COMPLETED', 20, '2026-02-10 11:49:33', NULL, NULL, '2026-02-10 11:55:23', '2026-02-10 11:48:52', '2026-02-10 11:55:23'),
(58, 21, 'for wifi bill', 'Office Supplies', 'Operations', 7000.00, '2026-02-11', 'pay yearly wifi bill ', 'COMPLETED', 18, '2026-02-11 06:34:19', NULL, NULL, '2026-02-11 12:42:30', '2026-02-11 06:32:29', '2026-02-11 12:42:30'),
(59, 19, 'for watter bill', 'Office Supplies', 'Operations', 1500.00, '2026-02-11', 'for pay water bill', 'COMPLETED', 20, '2026-02-11 10:41:52', NULL, NULL, '2026-02-11 12:03:40', '2026-02-11 10:41:06', '2026-02-11 12:03:40'),
(60, 20, 'for work anniversary gift ', 'work anniversary', 'HR', 400.00, '2026-02-09', 'for work anniversary gift for employee', 'COMPLETED', 1, '2026-02-11 11:38:34', NULL, NULL, '2026-02-11 11:40:56', '2026-02-11 11:15:05', '2026-02-11 11:40:56'),
(61, 21, 'Domain purchase', 'website expense', 'IT', 400.00, '2026-02-11', 'for website domain purchase ', 'COMPLETED', 18, '2026-03-11 05:37:31', NULL, NULL, '2026-03-23 10:03:14', '2026-02-12 05:35:12', '2026-03-23 10:03:14'),
(62, 21, 'website hosting', 'website expense', 'IT', 4000.00, '2026-02-12', 'for website hosting', 'COMPLETED', 18, '2026-02-12 05:39:59', NULL, NULL, '2026-02-12 06:44:33', '2026-02-12 05:36:39', '2026-02-12 06:44:33'),
(63, 18, 'buy new laptop', 'Equipment', 'Finance', 40000.00, '2026-02-11', 'for buy new laptop for new finance department', 'COMPLETED', 1, '2026-02-12 06:42:09', NULL, NULL, '2026-02-12 06:43:41', '2026-02-12 05:38:46', '2026-02-12 06:43:41'),
(64, 18, 'battery', 'Equipment', 'Marketing', 1200.00, '2026-02-12', 'buy a laptop battery', 'COMPLETED', 1, '2026-02-12 05:52:22', NULL, NULL, '2026-02-12 06:14:05', '2026-02-12 05:39:34', '2026-02-12 06:14:05'),
(65, 21, 'for company client', 'Travel', 'Marketing', 2000.00, '2026-03-22', 'for new client meet', 'COMPLETED', 18, '2026-03-23 10:11:52', NULL, NULL, '2026-04-01 12:32:46', '2026-03-23 10:07:22', '2026-04-01 12:32:46'),
(66, 18, 'for monthly lunch', 'Meals & Entertainment', 'Marketing', 3200.00, '2026-03-22', 'for monthly team lunch', 'COMPLETED', 1, '2026-03-23 10:18:47', NULL, NULL, '2026-03-23 10:20:00', '2026-03-23 10:16:50', '2026-03-23 10:20:00'),
(68, 18, 'mouses', 'Equipment', 'HR', 600.00, '2026-03-18', 'foe new mouse buy', 'COMPLETED', 1, '2026-04-01 07:45:57', NULL, NULL, '2026-04-01 12:30:42', '2026-04-01 06:43:25', '2026-04-01 12:30:42'),
(69, 21, 'web hosting', 'website', 'IT', 2600.00, '2026-03-29', 'website hosting', 'COMPLETED', 18, '2026-04-02 04:55:36', NULL, NULL, '2026-04-02 07:21:04', '2026-04-02 04:16:53', '2026-04-02 07:21:04'),
(70, 19, 'birthday celebration', 'Meals & Entertainment', 'Operations', 2000.00, '2026-04-02', 'for employee birthday', '', 20, '2026-04-02 09:08:21', NULL, NULL, NULL, '2026-04-02 07:54:38', '2026-04-02 09:29:04'),
(71, 19, 'food', 'Meals & Entertainment', 'Sales', 1600.00, '2026-04-02', 'sales team lunch', 'RECEIPT_APPROVED', 20, '2026-04-08 06:01:35', NULL, NULL, NULL, '2026-04-02 09:10:35', '2026-04-08 06:01:35'),
(72, 19, 'light bill', 'Office Supplies', 'HR', 3000.00, '2026-04-09', 'foe bill pay', 'PENDING_APPROVAL', NULL, NULL, NULL, NULL, NULL, '2026-04-09 10:17:07', '2026-04-09 10:17:07');

-- --------------------------------------------------------

--
-- Table structure for table `expense_documents`
--

CREATE TABLE `expense_documents` (
  `id` int(11) NOT NULL,
  `expense_id` int(11) NOT NULL,
  `document_path` varchar(500) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `file_type` varchar(50) NOT NULL,
  `file_size` int(11) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expense_documents`
--

INSERT INTO `expense_documents` (`id`, `expense_id`, `document_path`, `original_filename`, `file_type`, `file_size`, `uploaded_at`) VALUES
(46, 36, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770286472535-925261165.pdf', 'Expansion_Request_REQ-0021 (11).pdf', 'application/pdf', 10397, '2026-02-05 10:14:32'),
(47, 37, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770287640939-243408536.pdf', 'Expansion_Request_REQ-0021 (10).pdf', 'application/pdf', 10397, '2026-02-05 10:34:01'),
(48, 38, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770289274009-200970223.pdf', 'Expansion_Request_REQ-0021 (10).pdf', 'application/pdf', 10397, '2026-02-05 11:01:14'),
(49, 39, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770289355444-648752976.pdf', 'Expansion_Request_REQ-0021 (10).pdf', 'application/pdf', 10397, '2026-02-05 11:02:35'),
(52, 42, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770633423505-45296360.pdf', 'allocation_usage_report (1).pdf', 'application/pdf', 11046, '2026-02-09 10:37:03'),
(56, 46, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770703023959-87092774.pdf', 'all_expenses (6).pdf', 'application/pdf', 22659, '2026-02-10 05:57:04'),
(63, 53, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770716951185-407174291.pdf', 'Expansion_REQ-0025 (1).pdf', 'application/pdf', 9969, '2026-02-10 09:49:11'),
(64, 54, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770722112819-851607158.pdf', 'my_expenses (2).pdf', 'application/pdf', 11265, '2026-02-10 11:15:12'),
(65, 55, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770724132068-126887921.pdf', 'Manager_Report_Neel_Patel (1).pdf', 'application/pdf', 12383, '2026-02-10 11:48:52'),
(68, 58, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770791549519-211227908.pdf', 'Expansion_REQ-0034.pdf', 'application/pdf', 9968, '2026-02-11 06:32:29'),
(69, 59, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770806465694-241810089.pdf', 'fund_allocation_history (2).pdf', 'application/pdf', 26110, '2026-02-11 10:41:06'),
(70, 60, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770808503750-857070217.pdf', 'received_funds (1).pdf', 'application/pdf', 18679, '2026-02-11 11:15:05'),
(71, 61, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770874511454-290877395.png', 'Screenshot-2.png', 'image/png', 113575, '2026-02-12 05:35:12'),
(72, 62, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770874599852-195448792.png', 'introduction-to-cybersecurity.png', 'image/png', 42155, '2026-02-12 05:36:40'),
(74, 64, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770874774204-946852549.pdf', 'fund_allocation_history (1).pdf', 'application/pdf', 44707, '2026-02-12 05:39:34'),
(75, 63, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770876912495-252204954.pdf', 'my_expenses (3).pdf', 'application/pdf', 13296, '2026-02-12 06:15:13'),
(76, 65, 'D:\\OFFICE_EXPENSE_MANAGEMENT\\Office_expenses_management\\backend\\uploads\\expenses\\expense-1774260441774-443235238.jpg', 'Screenshot_20260323_141942.jpg', 'image/jpeg', 331087, '2026-03-23 10:07:22'),
(77, 66, 'D:\\OFFICE_EXPENSE_MANAGEMENT\\Office_expenses_management\\backend\\uploads\\expenses\\expense-1774261007035-736715040.jpg', 'Screenshot_20260323_141942.jpg', 'image/jpeg', 331087, '2026-03-23 10:16:50'),
(79, 68, 'D:\\OFFICE_EXPENSE_MANAGEMENT\\Office_expenses_management\\backend\\uploads\\expenses\\expense-1775025805148-750551379.jpg', 'IMG-20260401-WA0003.jpg', 'image/jpeg', 184551, '2026-04-01 06:43:25'),
(80, 69, 'D:\\OFFICE_EXPENSE_MANAGEMENT\\Office_expenses_management\\backend\\uploads\\expenses\\expense-1775103397526-703212715.jpg', 'IMG-20260402-WA0020.jpg', 'image/jpeg', 596617, '2026-04-02 04:16:53'),
(81, 70, 'D:\\OFFICE_EXPENSE_MANAGEMENT\\Office_expenses_management\\backend\\uploads\\expenses\\expense-1775116478119-19179431.pdf', 'expansion_requests.pdf', 'application/pdf', 18705, '2026-04-02 07:54:38'),
(82, 71, 'D:\\OFFICE_EXPENSE_MANAGEMENT\\Office_expenses_management\\backend\\uploads\\expenses\\expense-1775121035169-999564253.pdf', 'funds_report.pdf', 'application/pdf', 20679, '2026-04-02 09:10:35'),
(83, 72, 'D:\\OFFICE_EXPENSE_MANAGEMENT\\Office_expenses_management\\backend\\uploads\\expenses\\expense-1775729827635-5547450.pdf', 'expenses_report (5).pdf', 'application/pdf', 13306, '2026-04-09 10:17:07');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `related_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `type`, `title`, `message`, `is_read`, `related_id`, `created_at`) VALUES
(30, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager1 has requested an expansion fund of Rs. 7000.00.', 1, 7, '2026-01-29 12:42:06'),
(34, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"travel for meeting \" for Rs. 2000.', 1, 21, '2026-01-30 06:03:00'),
(38, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"travel for meeting \" for Rs. 2000.', 1, 22, '2026-01-30 08:40:59'),
(41, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"travel for meeting\" for Rs. 2000.', 1, 23, '2026-01-30 08:55:11'),
(45, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"for Team lunch\" for Rs. 1500.', 1, 24, '2026-01-30 10:02:04'),
(48, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager1 has requested an expansion fund of Rs. 300.00.', 1, 8, '2026-01-30 10:06:57'),
(57, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"client dinner\" for Rs. 1000.', 1, 26, '2026-02-02 05:51:04'),
(60, 1, 'USER_REGISTERED', 'New User Registration', 'raja has registered as a USER and is pending approval.', 1, 11, '2026-02-02 10:33:04'),
(62, 1, 'USER_REGISTERED', 'New User Registration', 'raja has registered as a USER and is pending approval.', 1, 12, '2026-02-02 11:03:47'),
(64, 1, 'USER_REGISTERED', 'New User Registration', 'raja has registered as a USER and is pending approval.', 1, 13, '2026-02-02 11:07:08'),
(66, 1, 'USER_REGISTERED', 'New User Registration', 'raja has registered as a USER and is pending approval.', 1, 14, '2026-02-02 11:39:15'),
(67, 14, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 14, '2026-02-02 11:39:51'),
(68, 1, 'USER_REGISTERED', 'New User Registration', 'user8 has registered as a USER and is pending approval.', 1, 15, '2026-02-02 12:14:45'),
(70, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"client dinner\" for Rs. 2000.', 1, 27, '2026-02-03 06:52:41'),
(73, 14, 'ACCOUNT_STATUS', 'Account Deactivated', 'Your account has been deactivated by the CEO.', 1, 14, '2026-02-03 11:44:28'),
(74, 14, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 14, '2026-02-03 11:45:15'),
(75, 14, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: manager3.', 1, 14, '2026-02-03 12:50:32'),
(79, 14, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy new mouse\" for Rs. 300.00 has been approved.', 1, 28, '2026-02-03 12:55:18'),
(80, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 9, '2026-02-03 12:55:34'),
(81, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 10, '2026-02-03 12:55:40'),
(82, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 11, '2026-02-03 12:55:42'),
(83, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 12, '2026-02-03 12:55:43'),
(84, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 13, '2026-02-03 12:55:45'),
(85, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 14, '2026-02-03 12:55:47'),
(86, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 15, '2026-02-03 12:59:27'),
(87, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 16, '2026-02-03 13:00:18'),
(88, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 18, '2026-02-04 04:42:50'),
(92, 14, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy new mouse\" for Rs. 300.00 has been approved.', 1, 30, '2026-02-04 05:02:05'),
(93, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 19, '2026-02-04 05:02:43'),
(96, 14, 'FUND_ALLOCATED', 'New Fund Allocation', 'manager3 has allocated Rs. 300.00 to your account.', 1, 51, '2026-02-04 05:32:19'),
(98, 14, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for REM\" for Rs. 1600.00 has been approved.', 1, 31, '2026-02-04 05:54:28'),
(99, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 1600.00.', 1, 20, '2026-02-04 05:55:00'),
(102, 14, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy a new moniter\" for Rs. 6000.00 has been approved.', 1, 32, '2026-02-04 06:51:36'),
(103, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 6000.00.', 1, 21, '2026-02-04 06:51:55'),
(104, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager3 has submitted an expense \"team dinner\" for Rs. 2000.', 1, 34, '2026-02-04 06:54:03'),
(105, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager3 has submitted an expense \"client meeting \" for Rs. 1500.', 1, 35, '2026-02-04 06:54:58'),
(113, 14, 'FUND_ALLOCATED', 'New Fund Allocation', 'manager3 has allocated Rs. 6000.00 to your account.', 1, 56, '2026-02-04 09:48:52'),
(114, 1, 'USER_REGISTERED', 'New User Registration', 'user1 has registered as a USER and is pending approval.', 1, 16, '2026-02-04 11:52:04'),
(115, 1, 'USER_REGISTERED', 'New User Registration', 'user1 has registered as a USER and is pending approval.', 1, 17, '2026-02-04 12:06:26'),
(116, 1, 'USER_REGISTERED', 'New User Registration', 'kishan sharma has registered as a MANAGER and is pending approval.', 1, 18, '2026-02-04 13:01:02'),
(117, 1, 'USER_REGISTERED', 'New User Registration', 'Deep Dantani has registered as a USER and is pending approval.', 1, 19, '2026-02-05 05:01:59'),
(118, 18, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 18, '2026-02-05 05:23:37'),
(119, 19, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 19, '2026-02-05 05:23:59'),
(120, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:34:00'),
(122, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:34:45'),
(124, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 05:37:40'),
(125, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:37:57'),
(127, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 05:56:45'),
(128, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:56:55'),
(130, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 05:57:01'),
(131, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:58:55'),
(133, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 05:59:04'),
(134, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:59:12'),
(136, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 06:03:53'),
(137, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 06:04:56'),
(139, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 06:05:52'),
(140, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 06:06:16'),
(142, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: kishan sharma.', 1, 19, '2026-02-05 08:05:33'),
(143, 14, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: kishan sharma.', 0, 14, '2026-02-05 08:05:35'),
(144, 18, 'USER_ASSIGNED', 'New User Assigned', 'Deep Dantani has been assigned to you.', 1, 19, '2026-02-05 08:05:36'),
(145, 18, 'USER_ASSIGNED', 'New User Assigned', 'raja has been assigned to you.', 1, 14, '2026-02-05 08:05:39'),
(146, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 08:06:26'),
(147, 14, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 14, '2026-02-05 08:06:28'),
(150, 1, 'USER_REGISTERED', 'New User Registration', 'Neel Patel has registered as a MANAGER and is pending approval.', 1, 20, '2026-02-05 09:26:58'),
(151, 20, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 20, '2026-02-05 09:29:25'),
(152, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 09:29:43'),
(153, 14, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 14, '2026-02-05 09:29:45'),
(154, 20, 'USER_ASSIGNED', 'New User Assigned', 'Deep Dantani has been assigned to you.', 1, 19, '2026-02-05 09:29:46'),
(155, 20, 'USER_ASSIGNED', 'New User Assigned', 'raja has been assigned to you.', 1, 14, '2026-02-05 09:29:48'),
(156, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"buy a Moniter\" for Rs. 6000.', 1, 36, '2026-02-05 10:14:32'),
(157, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"headohone \" for Rs. 800.', 1, 37, '2026-02-05 10:34:01'),
(158, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"headohone \" for Rs. 800.00 has been approved.', 1, 37, '2026-02-05 10:36:11'),
(159, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy a Moniter\" for Rs. 6000.00 has been approved.', 1, 36, '2026-02-05 10:36:17'),
(160, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 800.00.', 1, 22, '2026-02-05 10:39:44'),
(161, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 6000.00.', 1, 23, '2026-02-05 10:44:55'),
(162, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 6000.00 has been approved for Rs. 6000.00.', 1, 23, '2026-02-05 10:52:59'),
(163, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 800.00 has been approved for Rs. 800.00.', 1, 22, '2026-02-05 10:53:17'),
(164, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 6000.00 to your account.', 1, 57, '2026-02-05 10:55:05'),
(165, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 800.00 to your account.', 1, 58, '2026-02-05 10:57:58'),
(166, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 800.00 to your account.', 1, 59, '2026-02-05 10:59:12'),
(167, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 6000.00 to your account.', 1, 60, '2026-02-05 10:59:39'),
(168, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'Neel Patel has submitted an expense \"client meeting\" for Rs. 1500.', 1, 38, '2026-02-05 11:01:14'),
(169, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'Neel Patel has submitted an expense \"dinner\" for Rs. 2000.', 1, 39, '2026-02-05 11:02:35'),
(170, 20, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"dinner\" for Rs. 2000.00 has been approved.', 1, 39, '2026-02-05 11:20:10'),
(171, 20, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"client meeting\" for Rs. 1500.00 has been approved.', 1, 38, '2026-02-05 11:20:13'),
(172, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 2000.00 to your account.', 1, 61, '2026-02-05 11:20:34'),
(173, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 62, '2026-02-05 11:21:19'),
(174, 18, 'ACCOUNT_STATUS', 'Account Deactivated', 'Your account has been deactivated by the CEO.', 1, 18, '2026-02-06 06:32:16'),
(175, 18, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 18, '2026-02-06 06:32:38'),
(176, 1, 'USER_REGISTERED', 'New User Registration', 'Manav kheni has registered as a USER and is pending approval.', 1, 21, '2026-02-06 10:26:03'),
(177, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"buy water bottle\" for Rs. 500.', 1, 40, '2026-02-06 10:29:57'),
(178, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy water bottle\" for Rs. 500.00 has been approved.', 1, 40, '2026-02-06 11:09:14'),
(179, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 500.00.', 1, 24, '2026-02-06 11:09:29'),
(180, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 500.00 has been approved for Rs. 500.00.', 1, 24, '2026-02-06 11:11:17'),
(181, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 500.00 to your account.', 1, 63, '2026-02-06 11:12:04'),
(182, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 500.00 to your account.', 1, 64, '2026-02-06 11:13:09'),
(183, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"dff\" for Rs. 5000.', 1, 41, '2026-02-06 11:14:54'),
(184, 21, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 21, '2026-02-06 11:55:53'),
(185, 21, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: kishan sharma.', 1, 21, '2026-02-06 11:56:14'),
(186, 18, 'USER_ASSIGNED', 'New User Assigned', 'Manav kheni has been assigned to you.', 1, 21, '2026-02-06 11:56:18'),
(187, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy A4 Size paper\" for Rs. 300.', 1, 42, '2026-02-09 10:37:04'),
(188, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy A4 Size paper\" for Rs. 300.00 has been approved.', 1, 42, '2026-02-09 10:39:07'),
(189, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 300.00.', 1, 25, '2026-02-09 10:40:51'),
(190, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 300.00 has been approved for Rs. 300.00.', 1, 25, '2026-02-09 10:43:53'),
(191, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 300.00 to your account.', 1, 65, '2026-02-09 10:44:46'),
(192, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 300.00 to your account.', 1, 66, '2026-02-09 10:45:46'),
(193, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 500.', 1, 26, '2026-02-09 12:52:54'),
(194, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy HDD\" for Rs. 1500.', 1, 43, '2026-02-10 05:50:10'),
(195, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy HDD\" for Rs. 1500.00 has been approved.', 1, 43, '2026-02-10 05:51:13'),
(196, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"sports day celebration\" for Rs. 3000.', 1, 44, '2026-02-10 05:53:00'),
(197, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"sports day celebration\" for Rs. 3000.', 1, 45, '2026-02-10 05:53:12'),
(198, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"sports day celebration\" for Rs. 3000.', 1, 46, '2026-02-10 05:57:04'),
(199, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"sports day celebration\" for Rs. 3000.00 has been approved.', 1, 46, '2026-02-10 05:58:25'),
(200, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 3000.00 to your account.', 1, 67, '2026-02-10 06:03:31'),
(201, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 27, '2026-02-10 06:30:20'),
(202, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy HDD\" for Rs. 1500.', 1, 47, '2026-02-10 06:34:51'),
(203, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy graphic card\" for Rs. 5200.', 1, 48, '2026-02-10 06:36:05'),
(204, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy HDD\" for Rs. 1500.00 has been approved.', 1, 47, '2026-02-10 06:36:53'),
(205, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 28, '2026-02-10 06:45:45'),
(206, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy graphic card\" for Rs. 5200.00 has been approved.', 1, 48, '2026-02-10 06:53:25'),
(207, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 29, '2026-02-10 07:16:32'),
(208, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 30, '2026-02-10 08:48:01'),
(209, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 31, '2026-02-10 08:48:34'),
(210, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 32, '2026-02-10 08:49:35'),
(211, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 33, '2026-02-10 08:49:36'),
(212, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 34, '2026-02-10 09:01:54'),
(213, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 5200.00 has been approved for Rs. 5200.00.', 1, 34, '2026-02-10 09:04:38'),
(214, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 5200.00 to your account.', 1, 68, '2026-02-10 09:16:42'),
(215, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy Graphic card\" for Rs. 5200.', 1, 49, '2026-02-10 09:25:36'),
(216, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy HDD\" for Rs. 1500.', 1, 50, '2026-02-10 09:26:32'),
(217, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy HDD\" for Rs. 1500.00 has been approved.', 1, 50, '2026-02-10 09:27:21'),
(218, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 35, '2026-02-10 09:27:34'),
(219, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy Graphic card\" for Rs. 5200.00 has been approved.', 1, 49, '2026-02-10 09:28:03'),
(220, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 36, '2026-02-10 09:28:17'),
(221, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"team dinner\" for Rs. 2500.', 1, 51, '2026-02-10 09:30:04'),
(222, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 1500.00 has been approved for Rs. 1500.00.', 1, 35, '2026-02-10 09:31:06'),
(223, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 69, '2026-02-10 09:31:35'),
(224, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 5200.00 has been approved for Rs. 5200.00.', 1, 36, '2026-02-10 09:34:40'),
(225, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 5200.00 to your account.', 1, 70, '2026-02-10 09:36:03'),
(226, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"team dinner\" for Rs. 2500.00 has been approved.', 1, 51, '2026-02-10 09:41:23'),
(227, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy Graphic card\" for Rs. 5200.', 1, 52, '2026-02-10 09:48:30'),
(228, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy HDD\" for Rs. 1500.', 1, 53, '2026-02-10 09:49:11'),
(229, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy HDD\" for Rs. 1500.00 has been approved.', 1, 53, '2026-02-10 09:50:35'),
(230, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 37, '2026-02-10 09:50:43'),
(231, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 38, '2026-02-10 09:51:10'),
(232, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy Graphic card\" for Rs. 5200.00 has been approved.', 1, 52, '2026-02-10 09:51:31'),
(233, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 39, '2026-02-10 09:51:46'),
(234, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 5200.00 has been approved for Rs. 5200.00.', 1, 39, '2026-02-10 09:52:45'),
(235, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 1500.00 has been approved for Rs. 1500.00.', 1, 38, '2026-02-10 09:53:01'),
(236, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 71, '2026-02-10 10:10:42'),
(237, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 72, '2026-02-10 10:12:22'),
(238, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 5200.00 to your account.', 1, 73, '2026-02-10 10:12:54'),
(239, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 2500.00 to your account.', 1, 74, '2026-02-10 10:42:16'),
(240, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 5200.00 to your account.', 1, 75, '2026-02-10 10:46:29'),
(241, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 1500.00 to your account.', 1, 76, '2026-02-10 11:07:04'),
(242, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 1500.00 to your account.', 1, 77, '2026-02-10 11:07:43'),
(243, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"for client meeting venue\" for Rs. 1800.', 1, 54, '2026-02-10 11:15:12'),
(244, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for client meeting venue\" for Rs. 1800.00 has been approved.', 1, 54, '2026-02-10 11:15:55'),
(245, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1800.00 to your account.', 1, 78, '2026-02-10 11:40:27'),
(246, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1800.00 to your account.', 1, 79, '2026-02-10 11:42:23'),
(247, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"buy mouse\" for Rs. 500.', 1, 55, '2026-02-10 11:48:52'),
(248, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy mouse\" for Rs. 500.00 has been approved.', 1, 55, '2026-02-10 11:49:33'),
(249, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 500.00.', 1, 40, '2026-02-10 11:49:57'),
(250, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 500.00.', 1, 41, '2026-02-10 11:50:25'),
(251, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 500.00 has been approved for Rs. 500.00.', 1, 41, '2026-02-10 11:51:01'),
(252, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 500.00 to your account.', 1, 80, '2026-02-10 11:51:12'),
(253, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 500.00 to your account.', 1, 81, '2026-02-10 11:52:12'),
(254, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 500.00 to your account.', 1, 82, '2026-02-10 11:53:22'),
(255, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 500.00 to your account.', 1, 83, '2026-02-10 11:53:52'),
(256, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"abc\" for Rs. 25000.', 1, 56, '2026-02-10 14:22:11'),
(257, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"abc\" for Rs. 25000.00 has been approved.', 1, 56, '2026-02-10 14:23:59'),
(258, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 20000.00.', 1, 42, '2026-02-10 14:24:17'),
(259, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 20000.00 has been approved for Rs. 20000.00.', 1, 42, '2026-02-10 14:25:12'),
(260, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 15000.00 to your account.', 1, 84, '2026-02-10 14:25:24'),
(261, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 15000.00 to your account.', 1, 85, '2026-02-10 14:26:23'),
(262, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"dcd\" for Rs. 500.', 1, 57, '2026-02-11 06:28:43'),
(263, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"for wifi bill\" for Rs. 7000.', 1, 58, '2026-02-11 06:32:29'),
(264, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for wifi bill\" for Rs. 7000.00 has been approved.', 1, 58, '2026-02-11 06:34:19'),
(265, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 7000.00.', 1, 43, '2026-02-11 06:56:03'),
(266, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 7000.00 has been approved for Rs. 7000.00.', 1, 43, '2026-02-11 06:56:53'),
(267, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 7000.00 to your account.', 1, 86, '2026-02-11 06:57:13'),
(268, 1, 'FUND_CANCELLED', 'Test', 'Test Msg', 1, NULL, '2026-02-11 07:47:43'),
(269, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 7000.00 to your account.', 1, 98, '2026-02-11 09:24:03'),
(270, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"for watter bill\" for Rs. 1500.', 1, 59, '2026-02-11 10:41:06'),
(271, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for watter bill\" for Rs. 1500.00 has been approved.', 1, 59, '2026-02-11 10:41:52'),
(272, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 1500.00.', 1, 57, '2026-02-11 10:42:01'),
(273, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 1500.00.', 1, 58, '2026-02-11 10:43:33'),
(274, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'Neel Patel has submitted an expense \"for work anniversary gift \" for Rs. 500.', 1, 60, '2026-02-11 11:15:05'),
(275, 20, 'EXPANSION_REJECTED', 'Expansion Request Rejected', 'Your expansion request for Rs. 1500.00 has been rejected. Reason: its not worth it', 1, 58, '2026-02-11 11:18:17'),
(276, 20, 'EXPENSE_REJECTED', 'Expense Rejected', 'Your expense \"for work anniversary gift \" for Rs. 500.00 has been rejected. Reason: its not worth it', 1, 60, '2026-02-11 11:19:14'),
(277, 20, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for work anniversary gift \" for Rs. 400.00 has been approved.', 1, 60, '2026-02-11 11:38:34'),
(278, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 400.00 to your account.', 1, 99, '2026-02-11 11:40:05'),
(279, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 1500.00 has been approved for Rs. 1500.00.', 1, 58, '2026-02-11 12:02:05'),
(280, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 100, '2026-02-11 12:02:19'),
(281, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 1500.00 to your account.', 1, 101, '2026-02-11 12:03:04'),
(282, 1, 'USER_REGISTERED', 'New User Registration', 'Romit Jani has registered as a USER and is pending approval.', 1, 22, '2026-02-11 12:14:40'),
(283, 22, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 0, 22, '2026-02-11 12:21:56'),
(284, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"Domain purchase\" for Rs. 500.', 1, 61, '2026-02-12 05:35:12'),
(285, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"website hosting\" for Rs. 4000.', 1, 62, '2026-02-12 05:36:40'),
(286, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"buy new laptop\" for Rs. 40000.', 1, 63, '2026-02-12 05:38:46'),
(287, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"battery\" for Rs. 1200.', 1, 64, '2026-02-12 05:39:34'),
(288, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"website hosting\" for Rs. 4000.00 has been approved.', 1, 62, '2026-02-12 05:39:59'),
(289, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 4000.00.', 1, 59, '2026-02-12 05:49:57'),
(290, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"battery\" for Rs. 1200.00 has been approved.', 1, 64, '2026-02-12 05:52:22'),
(291, 18, 'EXPENSE_REJECTED', 'Expense Rejected', 'Your expense \"buy new laptop\" for Rs. 40000.00 has been rejected. Reason: missing bill of purchase ', 1, 63, '2026-02-12 05:53:05'),
(292, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1200.00 to your account.', 1, 102, '2026-02-12 06:00:33'),
(293, 18, 'EXPANSION_REJECTED', 'Expansion Request Rejected', 'Your expansion request for Rs. 4000.00 has been rejected. Reason: missing purchagee invoice 1 page', 1, 59, '2026-02-12 06:10:01'),
(294, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 4000.00.', 1, 60, '2026-02-12 06:32:14'),
(295, 21, 'EXPENSE_REJECTED', 'Expense Rejected', 'Your expense \"Domain purchase\" for Rs. 500.00 has been rejected. Reason: amount is not mached to bill amount ', 1, 61, '2026-02-12 06:36:31'),
(296, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 4000.00 has been approved for Rs. 4000.00.', 1, 60, '2026-02-12 06:39:16'),
(297, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 4000.00 to your account.', 1, 103, '2026-02-12 06:40:05'),
(298, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy new laptop\" for Rs. 40000.00 has been approved.', 1, 63, '2026-02-12 06:42:09'),
(299, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 40000.00 to your account.', 1, 104, '2026-02-12 06:42:46'),
(300, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 4000.00 to your account.', 1, 105, '2026-02-12 06:44:00'),
(301, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"Domain purchase\" for Rs. 400.00 has been approved.', 1, 61, '2026-03-11 05:37:32'),
(302, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 400.', 1, 61, '2026-03-11 07:09:42'),
(303, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 400.00 has been approved for Rs. 400.00.', 1, 61, '2026-03-23 08:39:54'),
(304, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 400.00 to your account.', 1, 106, '2026-03-23 08:40:39'),
(305, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 400.0 to your account.', 1, 107, '2026-03-23 09:09:45'),
(306, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 400.0 to your account.', 1, 108, '2026-03-23 09:59:35'),
(307, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 400.0 to your account.', 1, 109, '2026-03-23 10:00:08'),
(308, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"for company client\" for Rs. 3000.', 1, 65, '2026-03-23 10:07:22'),
(309, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for company client\" for Rs. 2000.00 has been approved.', 1, 65, '2026-03-23 10:11:52'),
(310, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 2000.', 1, 62, '2026-03-23 10:12:38'),
(311, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 2000.', 1, 63, '2026-03-23 10:14:38'),
(312, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"for monthly lunch\" for Rs. 3000.', 1, 66, '2026-03-23 10:16:50'),
(313, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for monthly lunch\" for Rs. 3200.00 has been approved.', 1, 66, '2026-03-23 10:18:47'),
(314, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 3200.00 to your account.', 1, 110, '2026-03-23 10:18:57'),
(315, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 2000.', 1, 64, '2026-04-01 05:44:48'),
(316, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"mouse\" for Rs. 500.', 1, 67, '2026-04-01 06:26:58'),
(317, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"mouse\" for Rs. 500.', 1, 68, '2026-04-01 06:43:25'),
(318, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"mouses\" for Rs. 600.00 has been approved.', 1, 68, '2026-04-01 07:45:57'),
(319, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 2000.00 has been approved for Rs. 2000.00.', 1, 64, '2026-04-01 07:47:36'),
(320, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 2000.00 to your account.', 1, 111, '2026-04-01 07:48:59'),
(321, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 112, '2026-04-01 09:21:36'),
(322, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.00 to your account.', 1, 113, '2026-04-01 09:23:16'),
(323, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 114, '2026-04-01 09:24:25'),
(324, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.00 to your account.', 1, 115, '2026-04-01 09:25:02'),
(325, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.00 to your account.', 1, 116, '2026-04-01 10:37:05'),
(326, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 117, '2026-04-01 10:38:14'),
(327, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 118, '2026-04-01 10:49:15'),
(328, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.00 to your account.', 1, 119, '2026-04-01 10:50:22'),
(329, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 120, '2026-04-01 10:50:23'),
(330, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 121, '2026-04-01 11:12:53'),
(331, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.00 to your account.', 1, 122, '2026-04-01 11:14:17'),
(332, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 123, '2026-04-01 11:44:40'),
(333, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 124, '2026-04-01 11:58:21'),
(334, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 125, '2026-04-01 12:00:52'),
(335, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.0 to your account.', 1, 126, '2026-04-01 12:21:03'),
(336, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2000.00 to your account.', 1, 127, '2026-04-01 12:21:54'),
(337, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 600.00 to your account.', 1, 128, '2026-04-01 12:23:08'),
(338, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 600.00 to your account.', 1, 129, '2026-04-01 12:24:21'),
(339, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 600.00 to your account.', 1, 130, '2026-04-01 12:24:50'),
(340, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 600.00 to your account.', 1, 131, '2026-04-01 12:25:26'),
(341, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 600.00 to your account.', 1, 132, '2026-04-01 12:27:04'),
(342, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 600.00 to your account.', 1, 133, '2026-04-01 12:27:36'),
(343, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 600.00 to your account.', 1, 134, '2026-04-01 12:29:04'),
(344, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 600.00 to your account.', 1, 135, '2026-04-01 12:29:46'),
(345, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"web hosting\" for Rs. 2500.', 1, 69, '2026-04-02 04:16:53'),
(346, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"web hosting\" for Rs. 2600.00 has been approved.', 1, 69, '2026-04-02 04:55:36'),
(347, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 2600.', 1, 65, '2026-04-02 06:43:39'),
(348, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 2600.', 1, 66, '2026-04-02 06:44:08'),
(349, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 2600.', 1, 67, '2026-04-02 06:51:06'),
(350, 18, 'EXPANSION_REJECTED', 'Expansion Request Rejected', 'Your expansion request for Rs. 2600.00 has been rejected. Reason: amount is not justify', 1, 67, '2026-04-02 06:53:29'),
(351, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 2600.00 has been approved for Rs. 2600.00.', 1, 67, '2026-04-02 06:55:15'),
(352, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 2600.00 to your account.', 1, 136, '2026-04-02 07:06:26'),
(353, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 2600.0 to your account.', 1, 137, '2026-04-02 07:20:04'),
(354, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"birthday celebration\" for Rs. 2000.', 1, 70, '2026-04-02 07:54:38'),
(355, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"birthday celebration\" for Rs. 2000.00 has been approved.', 1, 70, '2026-04-02 09:08:21'),
(356, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"food\" for Rs. 1600.', 1, 71, '2026-04-02 09:10:35'),
(357, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 2000.', 1, 68, '2026-04-02 09:29:04'),
(358, 1, 'USER_REGISTERED', 'New User Registration', 'Meet Soni has registered as a USER and is pending approval.', 1, 23, '2026-04-02 11:30:51'),
(359, 23, 'ACCOUNT_STATUS', 'Account Rejected', 'Your registration request has been rejected by the CEO.', 0, 23, '2026-04-02 11:33:42'),
(360, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"food\" for Rs. 1600.00 has been approved.', 1, 71, '2026-04-08 06:01:36'),
(361, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"food\" for Rs. 1600.00 has been approved.', 1, 71, '2026-04-08 06:01:36'),
(362, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 2000.00 has been approved for Rs. 2000.00.', 1, 68, '2026-04-09 04:28:14'),
(363, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 2000.00 to your account.', 1, 138, '2026-04-09 04:29:25'),
(364, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"light bill\" for Rs. 3000.', 0, 72, '2026-04-09 10:17:07');

-- --------------------------------------------------------

--
-- Table structure for table `operational_funds`
--

CREATE TABLE `operational_funds` (
  `id` int(11) NOT NULL,
  `from_user_id` int(11) NOT NULL,
  `to_user_id` int(11) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `description` text DEFAULT NULL,
  `expansion_id` int(11) DEFAULT NULL,
  `payment_mode` enum('CASH','CHEQUE','UPI') DEFAULT NULL,
  `status` enum('PENDING','ALLOCATED','RECEIVED','COMPLETED','REJECTED') DEFAULT 'PENDING',
  `rejection_reason` text DEFAULT NULL,
  `allocated_at` timestamp NULL DEFAULT NULL,
  `received_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `cheque_number` varchar(50) DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `cheque_date` date DEFAULT NULL,
  `account_holder_name` varchar(255) DEFAULT NULL,
  `cheque_image_path` varchar(500) DEFAULT NULL,
  `upi_id` varchar(100) DEFAULT NULL,
  `transaction_id` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `operational_funds`
--

INSERT INTO `operational_funds` (`id`, `from_user_id`, `to_user_id`, `amount`, `description`, `expansion_id`, `payment_mode`, `status`, `rejection_reason`, `allocated_at`, `received_at`, `created_at`, `updated_at`, `cheque_number`, `bank_name`, `cheque_date`, `account_holder_name`, `cheque_image_path`, `upi_id`, `transaction_id`) VALUES
(57, 1, 20, 6000.00, 'Allocation for Expansion Request #23 - Expansion fund for approved expense: buy a Moniter (ID: 36)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-05 10:55:05', '2026-02-05 10:59:00', '2026-02-05 10:55:04', '2026-02-05 10:59:00', '2354862', 'HDFC Bank', '2026-02-05', 'Milan Patel', 'uploads/cheques/cheque-1770288904133-643637712.png', NULL, NULL),
(58, 1, 20, 800.00, 'Allocation for Expansion Request #22 - Expansion fund for approved expense: headohone  (ID: 37)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-05 10:57:58', '2026-02-05 10:58:51', '2026-02-05 10:57:58', '2026-02-05 10:58:51', '2354869', 'HDFC Bank', '2026-02-05', 'Milan Patel', 'uploads/cheques/cheque-1770289077994-989737917.png', NULL, NULL),
(59, 20, 19, 800.00, 'Allocation for Expansion Request #22 - Expansion fund for approved expense: headohone  (ID: 37)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-05 10:59:12', '2026-02-05 11:03:19', '2026-02-05 10:59:12', '2026-02-05 11:03:19', '2354869', 'HDFC Bank', '2026-02-04', 'Milan Patel', 'uploads/cheques/cheque-1770289077994-989737917.png', NULL, NULL),
(60, 20, 19, 6000.00, 'Allocation for Expansion Request #23 - Expansion fund for approved expense: buy a Moniter (ID: 36)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-05 10:59:39', '2026-02-05 11:03:14', '2026-02-05 10:59:39', '2026-02-05 11:03:14', '2354862', 'HDFC Bank', '2026-02-04', 'Milan Patel', 'uploads/cheques/cheque-1770288904133-643637712.png', NULL, NULL),
(61, 1, 20, 2000.00, 'Allocation for Expense #39 - dinner', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-05 11:20:34', '2026-02-05 11:22:24', '2026-02-05 11:20:34', '2026-02-05 11:22:24', NULL, NULL, NULL, NULL, NULL, 'milanpatel27@oksbi', 'PAYTMUPI7834561295'),
(62, 1, 20, 1500.00, 'Allocation for Expense #38 - client meeting', NULL, 'CASH', 'RECEIVED', NULL, '2026-02-05 11:21:19', '2026-02-05 11:22:12', '2026-02-05 11:21:19', '2026-02-05 11:22:12', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(63, 1, 20, 500.00, 'Allocation for Expansion Request #24 - Expansion fund for approved expense: buy water bottle (ID: 40)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-06 11:12:04', '2026-02-06 11:12:59', '2026-02-06 11:12:04', '2026-02-06 11:12:59', '2354869', 'SBI ', '2026-02-06', 'Milan Patel', 'uploads/cheques/cheque-1770376324324-901442479.png', NULL, NULL),
(64, 20, 19, 500.00, 'Allocation for Expansion Request #24 - Expansion fund for approved expense: buy water bottle (ID: 40)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-06 11:13:09', '2026-02-06 11:14:00', '2026-02-06 11:13:09', '2026-02-06 11:14:00', '2354869', 'SBI ', '2026-02-05', 'Milan Patel', 'uploads/cheques/cheque-1770376324324-901442479.png', NULL, NULL),
(65, 1, 18, 300.00, 'Allocation for Expansion Request #25 - Expansion fund for approved expense: buy A4 Size paper (ID: 42)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-09 10:44:45', '2026-02-09 10:45:14', '2026-02-09 10:44:45', '2026-02-09 10:45:14', '2354866', 'SBI ', '2026-02-09', 'Milan Patel', 'uploads/cheques/cheque-1770633885838-877498517.png', NULL, NULL),
(66, 18, 21, 300.00, 'Allocation for Expansion Request #25 - Expansion fund for approved expense: buy A4 Size paper (ID: 42)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-09 10:45:46', '2026-02-09 10:47:00', '2026-02-09 10:45:46', '2026-02-09 10:47:00', '2354866', 'SBI ', '2026-02-08', 'Milan Patel', 'uploads/cheques/cheque-1770633885838-877498517.png', NULL, NULL),
(67, 1, 18, 3000.00, 'Allocation for Expense #46 - sports day celebration', NULL, 'CASH', 'RECEIVED', NULL, '2026-02-10 06:03:31', '2026-02-10 06:08:38', '2026-02-10 06:03:31', '2026-02-10 06:08:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(72, 1, 18, 1500.00, 'Allocation for Expansion Request #38 - Expansion fund for approved expense: buy HDD (ID: 53)', 38, 'CHEQUE', 'RECEIVED', NULL, '2026-02-10 10:12:22', '2026-02-10 10:45:30', '2026-02-10 10:12:22', '2026-02-10 10:45:30', '2354455', 'BOB', '2026-02-10', 'Milan Patel', 'uploads/cheques/cheque-1770718342402-627089795.png', NULL, NULL),
(77, 18, 21, 1500.00, 'Allocation for Expansion Request #38 - Expansion fund for approved expense: buy HDD (ID: 53)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-10 11:07:43', '2026-02-10 11:09:04', '2026-02-10 11:07:43', '2026-02-10 11:09:04', '2354455', 'BOB', '2026-02-09', 'Milan Patel', 'uploads/cheques/cheque-1770718342402-627089795.png', NULL, NULL),
(79, 1, 18, 1800.00, 'Allocation for Expense #54 - for client meeting venue', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-10 11:42:23', '2026-02-10 11:45:09', '2026-02-10 11:42:23', '2026-02-10 11:45:09', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@oksbi', 'PAYTMUPI7834561222'),
(81, 1, 20, 500.00, 'Allocation for Expansion Request #41 - Expansion fund for approved expense: buy mouse (ID: 55)', 41, 'UPI', 'RECEIVED', NULL, '2026-02-10 11:52:12', '2026-02-10 11:53:14', '2026-02-10 11:52:12', '2026-02-10 11:53:14', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@oksbi', 'PAYTMUPI7834561288'),
(83, 20, 19, 500.00, 'Allocation for Expansion Request #41 - Expansion fund for approved expense: buy mouse (ID: 55)', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-10 11:53:52', '2026-02-10 11:55:23', '2026-02-10 11:53:52', '2026-02-10 11:55:23', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@oksbi', 'PAYTMUPI7834561288'),
(86, 1, 18, 7000.00, 'Allocation for Expansion Request #43 - Expansion fund for approved expense: for wifi bill (ID: 58)', 43, 'CASH', 'RECEIVED', NULL, '2026-02-11 06:57:13', '2026-02-11 07:34:39', '2026-02-11 06:57:13', '2026-02-11 07:34:39', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(98, 18, 21, 7000.00, 'Allocation for Expansion Request #43 - Expansion fund for approved expense: for wifi bill (ID: 58)', NULL, 'CASH', 'RECEIVED', NULL, '2026-02-11 09:24:03', '2026-02-11 12:42:30', '2026-02-11 09:24:03', '2026-02-11 12:42:30', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(99, 1, 20, 400.00, 'Allocation for Expense #60 - for work anniversary gift ', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-11 11:40:04', '2026-02-11 11:40:56', '2026-02-11 11:40:04', '2026-02-11 11:40:56', NULL, NULL, NULL, NULL, NULL, 'milanpatel27@oksbi', 'PAYTMUPI7834561366'),
(100, 1, 20, 1500.00, 'Allocation for Expansion Request #58 - Expansion fund for approved expense: for watter bill (ID: 59)', 58, 'CASH', 'RECEIVED', NULL, '2026-02-11 12:02:19', '2026-02-11 12:02:56', '2026-02-11 12:02:19', '2026-02-11 12:02:56', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(101, 20, 19, 1500.00, 'Allocation for Expansion Request #58 - Expansion fund for approved expense: for watter bill (ID: 59)', NULL, 'CASH', 'RECEIVED', NULL, '2026-02-11 12:03:04', '2026-02-11 12:03:40', '2026-02-11 12:03:04', '2026-02-11 12:03:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(102, 1, 18, 1200.00, 'Allocation for Expense #64 - battery', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-12 06:00:33', '2026-02-12 06:14:05', '2026-02-12 06:00:32', '2026-02-12 06:14:05', '2354455', 'BOI', '2026-02-11', 'Milan Patel', 'uploads/cheques/cheque-1770876032584-797488466.png', NULL, NULL),
(103, 1, 18, 4000.00, 'Allocation for Expansion Request #60 - Expansion fund for approved expense: website hosting (ID: 62)', 60, 'UPI', 'RECEIVED', NULL, '2026-02-12 06:40:05', '2026-02-12 06:43:47', '2026-02-12 06:40:05', '2026-02-12 06:43:47', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@okboi', 'PAYTMUPI7834561320'),
(104, 1, 18, 40000.00, 'Allocation for Expense #63 - buy new laptop', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-12 06:42:46', '2026-02-12 06:43:41', '2026-02-12 06:42:46', '2026-02-12 06:43:41', '2354855', 'HDFC ', '2026-02-12', 'Milan Patel', 'uploads/cheques/cheque-1770878566022-254653550.png', NULL, NULL),
(105, 18, 21, 4000.00, 'Allocation for Expansion Request #60 - Expansion fund for approved expense: website hosting (ID: 62)', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-12 06:44:00', '2026-02-12 06:44:33', '2026-02-12 06:44:00', '2026-02-12 06:44:33', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@okboi', 'PAYTMUPI7834561320'),
(106, 1, 18, 400.00, 'Allocation for Expansion Request #61 - Expansion for Team Expense: Domain purchase (ID: 61)', 61, 'UPI', 'RECEIVED', NULL, '2026-03-23 08:40:39', '2026-03-23 08:44:13', '2026-03-23 08:40:39', '2026-03-23 08:44:13', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@okboi', 'PAYTMUPI7834561361'),
(109, 18, 21, 400.00, 'Allocation for Expansion Request #61 - Expansion for Team Expense: Domain purchase (ID: 61)', NULL, 'UPI', 'RECEIVED', NULL, '2026-03-23 10:00:08', '2026-03-23 10:03:14', '2026-03-23 10:00:08', '2026-03-23 10:03:14', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@okboi', 'PAYTMUPI7834561361'),
(110, 1, 18, 3200.00, 'Allocation for Expense #66 - for monthly lunch', NULL, 'CASH', 'RECEIVED', NULL, '2026-03-23 10:18:57', '2026-03-23 10:20:00', '2026-03-23 10:18:57', '2026-03-23 10:20:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(111, 1, 18, 2000.00, 'Allocation for Expansion Request #64 - Expansion fund for approved expense: for company client (ID: 65)', 64, 'CHEQUE', 'RECEIVED', NULL, '2026-04-01 07:48:59', '2026-04-01 07:49:29', '2026-04-01 07:48:59', '2026-04-01 07:49:29', '2354455', 'HDFC Bank', '2026-04-01', 'Milan Patel', 'uploads/cheques/cheque-1775029738736-21852007.png', NULL, NULL),
(127, 18, 21, 2000.00, 'Allocation for Expansion Request #64 - Expansion fund for approved expense: for company client (ID: 65)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-04-01 12:21:54', '2026-04-01 12:32:46', '2026-04-01 12:21:54', '2026-04-01 12:32:46', '2354455', 'HDFC Bank', '2026-03-31', 'Milan Patel', 'uploads/cheques/cheque-1775029738736-21852007.png', NULL, NULL),
(135, 1, 18, 600.00, 'Allocation for Expense #68 - mouses', NULL, 'CASH', 'RECEIVED', NULL, '2026-04-01 12:29:46', '2026-04-01 12:30:42', '2026-04-01 12:29:46', '2026-04-01 12:30:42', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(136, 1, 18, 2600.00, 'Allocation for Expansion Request #67 - Expansion fund for approved expense: web hosting (ID: 69)', 67, 'UPI', 'RECEIVED', NULL, '2026-04-02 07:06:26', '2026-04-02 07:06:43', '2026-04-02 07:06:26', '2026-04-02 07:06:43', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@okboi', 'PAYTMUPI7834561297'),
(137, 18, 21, 2600.00, 'Allocation for Expansion Request #67 - Expansion fund for approved expense: web hosting (ID: 69)', NULL, 'UPI', 'RECEIVED', NULL, '2026-04-02 07:20:04', '2026-04-02 07:21:04', '2026-04-02 07:20:04', '2026-04-02 07:21:04', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@okboi', 'PAYTMUPI7834561297'),
(138, 1, 20, 2000.00, 'Allocation for Expansion Request #68 - Expansion fund for approved expense: birthday celebration (ID: 70)', 68, 'CASH', 'ALLOCATED', NULL, '2026-04-09 04:29:25', NULL, '2026-04-09 04:29:25', '2026-04-09 04:29:25', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `registration_otps`
--

CREATE TABLE `registration_otps` (
  `id` int(11) NOT NULL,
  `email` varchar(191) NOT NULL,
  `otp_code` varchar(10) DEFAULT NULL,
  `verification_token` varchar(255) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `registration_otps`
--

INSERT INTO `registration_otps` (`id`, `email`, `otp_code`, `verification_token`, `verified`, `expires_at`, `created_at`) VALUES
(2, '200525kishan@gmail.com', '946094', '6e4e88a2121996cac16d745bd9dc47131f2e551b970d77369ab166e22425766e', 1, '2026-02-04 18:39:09', '2026-02-04 12:59:09'),
(3, '200305deep@gmail.com', '616351', 'f3042e37e1008d2f8675df5fa8ea6a2613a7d0696e103f0b0b66c21e050f7b28', 1, '2026-02-05 10:39:43', '2026-02-05 04:59:43'),
(4, 'neel200402neel@gmail.com', '328139', NULL, 0, '2026-02-05 15:00:00', '2026-02-05 09:20:00'),
(5, '200402neel@gmail.com', '873653', '7ee9e2b529d9427c29affcf7edee4fd56bc56c37522a1e700ae4719e8f489f3d', 1, '2026-02-05 15:05:57', '2026-02-05 09:25:57'),
(6, '200203manav@gmail.com', '751801', 'efd46779ca589e88f639877aad5cfce53f0e7c0d72c52a9142b7ca797df4dbf5', 1, '2026-02-06 16:04:44', '2026-02-06 10:24:44'),
(7, 'romitjani03@gmail.com', '559713', 'd081f312570611436b4c10c0d23714bea16398990aa1679a02bfbe9328ae6676', 1, '2026-02-11 17:53:28', '2026-02-11 12:11:45'),
(9, '2meet2002@gmail.com', '945794', '5822b91e3d4164fc7b743234947d9e145cf1a66d507bfcb60461b4a45a6eaf7f', 1, '2026-04-02 17:10:14', '2026-04-02 10:09:52');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `mobile_number` varchar(20) DEFAULT NULL,
  `role` enum('CEO','MANAGER','USER') NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','DEACTIVATED') NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `manager_id` int(11) DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_expires` datetime DEFAULT NULL,
  `otp_code` varchar(6) DEFAULT NULL,
  `otp_expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `full_name`, `mobile_number`, `role`, `status`, `created_at`, `updated_at`, `manager_id`, `profile_image`, `reset_password_token`, `reset_password_expires`, `otp_code`, `otp_expires_at`) VALUES
(1, '02milanp@gmail.com', '$2a$10$2VDClfVFflrhqs1CuUfTZu81eBU9vNBqBmxxNs8bDDB3iLIjfeUIi', 'Milan Patel', '9723585876', 'CEO', 'APPROVED', '2026-01-16 06:45:58', '2026-04-10 04:35:10', NULL, '/uploads/profiles/profile-1770891365846-664420197.webp', NULL, NULL, '109097', '2026-04-03 18:09:36'),
(14, 'battingraja436@gmail.com', '$2a$10$Mds.PX3.6j18FJ8QwvVn8e5kGNR0/yHCSw95vfm4RyT9irpGDiCN.', 'raja', '6524595872', 'USER', 'APPROVED', '2026-02-02 11:39:15', '2026-04-10 04:42:16', 20, NULL, NULL, NULL, NULL, NULL),
(18, '200525kishan@gmail.com', '$2a$10$Hpsy.gcRp4pWFsBmjDzwh.TPfx/o17AmIfEjc.vh7If0LVyxNwqSO', 'kishan sharma', '7865214561', 'MANAGER', 'APPROVED', '2026-02-04 13:01:02', '2026-04-10 04:38:14', NULL, '/uploads/profiles/profile-1774859566950-169597945.jpg', '9f216d33fc33ac1095643655356467a4e956ef72', '2026-04-10 11:06:11', NULL, NULL),
(19, '200305deep@gmail.com', '$2a$10$r15B.tTON0PnmhEq0WGCruh4dtbfprIWuAztdr8COcGsig6THP1UW', 'Deep Dantani', '7869214569', 'USER', 'APPROVED', '2026-02-05 05:01:59', '2026-03-24 06:55:36', 20, '/uploads/profiles/profile-1770892273590-926934662.webp', NULL, NULL, NULL, NULL),
(20, '200402neel@gmail.com', '$2a$10$5r5CNZVsv5h8IdHWE/E.We2MxP6p6ZS31hzQe33VFgNXWXoyAD7vG', 'Neel Patel', '7865214563', 'MANAGER', 'APPROVED', '2026-02-05 09:26:58', '2026-04-10 04:40:10', NULL, '/uploads/profiles/profile-1770892232270-178136670.webp', NULL, NULL, NULL, NULL),
(21, '200203manav@gmail.com', '$2a$10$iETGsDLzxADsWjDlMapZF.9rc4iIc1Z22zQYqiRbnjNXU9nmxplHa', 'Manav kheni', '9743585877', 'USER', 'APPROVED', '2026-02-06 10:26:02', '2026-04-02 07:52:03', 18, '/uploads/profiles/profile-1775116268199-44646363.jpg', NULL, NULL, NULL, NULL),
(22, 'romitjani03@gmail.com', '$2a$10$btIvtLdVC2tocpd/7.gpoe1KNOt3iClRgcPmzYQ0.t/C3alzP4bhK', 'Romit Jani', '7723585876', 'USER', 'APPROVED', '2026-02-11 12:14:40', '2026-02-11 12:21:56', NULL, NULL, NULL, NULL, NULL, NULL),
(23, '2meet2002@gmail.com', '$2a$10$KEl4st93dniTMuWHsSBZiOg8/VFy0Ei7TxHEo/rYRCykgOXgQK3re', 'Meet Soni', '9876543210', 'USER', 'REJECTED', '2026-04-02 11:30:51', '2026-04-02 11:33:42', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_sessions`
--

CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` varchar(700) NOT NULL,
  `device_info` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_active` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_sessions`
--

INSERT INTO `user_sessions` (`id`, `user_id`, `token`, `device_info`, `active`, `created_at`, `last_active`) VALUES
(1, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzIwOTE2MzAsImV4cCI6MTc3MjE3ODAzMH0.snKX-n7Ar4iNsKk6gICdOM__YudOPjBiqmwbL31Aqlk', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-02-26 07:40:30', '2026-02-26 07:40:30'),
(2, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzIxMTAyMzEsImV4cCI6MTc3MjE5NjYzMX0.Ese56N33FgqnNY6ztjIKOKf4SMzmJeVaBS-hgtZda8o', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Sa', 1, '2026-02-26 12:50:31', '2026-02-26 12:50:31'),
(4, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzIxMTAyNjUsImV4cCI6MTc3MjE5NjY2NX0.6nsmrw-OfxFbGGIu-vE62L0sxNHFXZiXlorTwYj2g_c', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Sa', 1, '2026-02-26 12:51:05', '2026-02-26 12:51:05'),
(5, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMwNDEyMjcsImV4cCI6MTc3MzEyNzYyN30.Y4fOCG5eLCo4wqTEl6KG56tVAY8kcJiuuStTAD18av4', 'Unknown Device', 1, '2026-03-09 07:27:07', '2026-03-09 07:27:07'),
(6, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMwNTYyNzMsImV4cCI6MTc3MzE0MjY3M30._3oLKNypM-EhIQaJMSL4aTneHu6jHlMVXam1lKlHA_s', 'Unknown Device', 1, '2026-03-09 11:37:53', '2026-03-09 11:37:53'),
(7, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMwNTc3MjQsImV4cCI6MTc3MzE0NDEyNH0.DHOuQtxDo-lvbEGrybwhpd7c6LSZUa5dgusBAENW0NA', 'Unknown Device', 1, '2026-03-09 12:02:10', '2026-03-09 12:02:10'),
(8, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMwNTc4ODksImV4cCI6MTc3MzE0NDI4OX0.SLAbFFSwooMZLtO1fmtJz9CImfjfSOdV_UR5Uk_vqEc', 'Unknown Device', 1, '2026-03-09 12:04:49', '2026-03-09 12:04:49'),
(9, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMwNTc4OTEsImV4cCI6MTc3MzE0NDI5MX0.jusw9lzaOXxBQu6Iqel792XUdGbNXAQaodud-6O6P-E', 'Unknown Device', 1, '2026-03-09 12:04:51', '2026-03-09 12:04:51'),
(10, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMwNTc5MDcsImV4cCI6MTc3MzE0NDMwN30.4e8HglWGgWSi_HRa4xjs48zZy9LGUP6QTl0AUMmQ4uY', 'Unknown Device', 1, '2026-03-09 12:05:07', '2026-03-09 12:05:07'),
(11, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMwNTgzNjcsImV4cCI6MTc3MzE0NDc2N30.7uye2cAkqahEE64PCLbusPFFl4WLZRmIV0oCunYM4E0', 'Unknown Device', 1, '2026-03-09 12:12:47', '2026-03-09 12:12:47'),
(12, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMwNjA0NjQsImV4cCI6MTc3MzE0Njg2NH0.l9DpIfv2plOa6YGyhJ7R4NzILEg0PGmW2JJysV_bff0', 'Unknown Device', 1, '2026-03-09 12:47:44', '2026-03-09 12:47:44'),
(13, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMxMjIyMzgsImV4cCI6MTc3MzIwODYzOH0.bHbYLBgxjx5zBkMDTnDvP8GktdtmHMm77CHeDEdVIsc', 'Unknown Device', 1, '2026-03-10 05:57:18', '2026-03-10 05:57:18'),
(14, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3MzEyMjU0OCwiZXhwIjoxNzczMjA4OTQ4fQ.nYASDM3T_bO3n5rEBrBhkGZzw1axzi7gRS174dzPWvA', 'Unknown Device', 1, '2026-03-10 06:02:28', '2026-03-10 06:02:28'),
(15, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3MzEyMjYyMSwiZXhwIjoxNzczMjA5MDIxfQ.sOuEBzbgUl2Tp1h1H8P1msV4LiVdD1NPr0mDjO1aPig', 'Unknown Device', 1, '2026-03-10 06:03:41', '2026-03-10 06:03:41'),
(17, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3MzEyMzE2MiwiZXhwIjoxNzczMjA5NTYyfQ.Ry4M0bXcwNmSoWT8VWQuHq8LveUoC0RRzWIdH8B5nFw', 'Unknown Device', 1, '2026-03-10 06:12:42', '2026-03-10 06:12:42'),
(18, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMDcwNjgsImV4cCI6MTc3MzI5MzQ2OH0.QimXcr0w_8MGWjPuYF2s2cPwN2plLzBjXjTSCbdbiEg', 'Unknown Device', 1, '2026-03-11 05:31:08', '2026-03-11 05:31:08'),
(21, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMTE4MTIsImV4cCI6MTc3MzI5ODIxMn0._nkrbc2mYmSJulQre_NJ6fSCS0Fr-Vqtix-L0qUjeGE', 'Unknown Device', 1, '2026-03-11 06:50:12', '2026-03-11 06:50:12'),
(24, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMTQ0NzIsImV4cCI6MTc3MzMwMDg3Mn0.8jOwhR13V47RignfP5sG5T1yst81j-PU0l3Uyt6QBUQ', 'Unknown Device', 1, '2026-03-11 07:34:32', '2026-03-11 07:34:32'),
(25, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMTU1NTAsImV4cCI6MTc3MzMwMTk1MH0.37NhSXN2MlC17wmxrYZKVFghEMhDAIdhCxwV-B_5r34', 'Unknown Device', 1, '2026-03-11 07:52:31', '2026-03-11 07:52:31'),
(26, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMjAxNDgsImV4cCI6MTc3MzMwNjU0OH0.89UqHSpTycVXk1XOifxFuPEDXUQfsHv0q_p1mZgSE-k', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Sa', 1, '2026-03-11 09:09:08', '2026-03-11 09:09:08'),
(27, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMzMyMDAsImV4cCI6MTc3MzMxOTYwMH0.CO6yvjw8jaAVM83hDbNbpnt5Jc_cotENdS8QJ7sfgcI', 'Unknown Device', 1, '2026-03-11 12:46:40', '2026-03-11 12:46:40'),
(28, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMzMzODQsImV4cCI6MTc3MzMxOTc4NH0.kcwU9cOASRtpawARy4Ua9VU7ITvLauTO9qEOnoJn260', 'Unknown Device', 1, '2026-03-11 12:49:44', '2026-03-11 12:49:44'),
(29, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMzM1OTAsImV4cCI6MTc3MzMxOTk5MH0.qYDHDjShMzgCQUzNWdzm9IBMYD0LK0DWZaVtdOyVGfo', 'Unknown Device', 1, '2026-03-11 12:53:10', '2026-03-11 12:53:10'),
(30, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMzM2MzAsImV4cCI6MTc3MzMyMDAzMH0.I3WKBM5SGWwPWa3PT7Jb8jAdJtqMKH255ObAzlr0uAc', 'Unknown Device', 1, '2026-03-11 12:53:50', '2026-03-11 12:53:50'),
(31, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyMzM5MjgsImV4cCI6MTc3MzMyMDMyOH0.jlSYC7TNdEVPakPzp5wMvVypwifLaJRiRFQggXRp9tk', 'Unknown Device', 1, '2026-03-11 12:58:48', '2026-03-11 12:58:48'),
(32, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyOTI1NjMsImV4cCI6MTc3MzM3ODk2M30.aenT_AFkPKYmDoWVHXP883wuzqbXvrh558-c1_gPpB8', 'Unknown Device', 1, '2026-03-12 05:16:03', '2026-03-12 05:16:03'),
(33, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyOTI2MTAsImV4cCI6MTc3MzM3OTAxMH0.4N2IsyZ5BuzArTSc-O8vUYUgYElmjxvmFxwC0cN7W6c', 'Unknown Device', 1, '2026-03-12 05:16:50', '2026-03-12 05:16:50'),
(34, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyOTI2NTAsImV4cCI6MTc3MzM3OTA1MH0.042swwtcXLCBjg4-Tb4nQfFQWKGPKvgYcIvGXq9qpwU', 'Unknown Device', 1, '2026-03-12 05:17:30', '2026-03-12 05:17:30'),
(35, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyOTI3MTgsImV4cCI6MTc3MzM3OTExOH0.fw-AuRZIyCBePLlgmWcqcrrj3TJB626DnJC49OUAja8', 'Unknown Device', 1, '2026-03-12 05:18:38', '2026-03-12 05:18:38'),
(36, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyOTcxMDAsImV4cCI6MTc3MzM4MzUwMH0.42TVvQUOrWGMI5WPF1pJIoqY9lZCIx7isVAeaf35VTE', 'samsung SM-G770F (Android 13)', 1, '2026-03-12 06:31:40', '2026-03-12 06:31:40'),
(37, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyOTcyNjgsImV4cCI6MTc3MzM4MzY2OH0.Q5NWiYuZl4ZmoAetL_KUIxyvS9Ok3xxYz_nJvQ9ToJk', 'samsung SM-G770F (Android 13)', 1, '2026-03-12 06:34:28', '2026-03-12 06:34:28'),
(38, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMyOTc4MDAsImV4cCI6MTc3MzM4NDIwMH0.IcVGVcYz7oE1Szxx8TrbzuiGowHOrQ6Ur4JfFXzdVdc', 'samsung SM-G770F (Android 13)', 1, '2026-03-12 06:43:20', '2026-03-12 06:43:20'),
(39, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMzNzk4NTYsImV4cCI6MTc3MzQ2NjI1Nn0.r5zK1scdo4MEXNzkGU-sqbr33018qNnWu6BtHXUOg0w', 'samsung SM-G770F (Android 13)', 1, '2026-03-13 05:30:56', '2026-03-13 05:30:56'),
(40, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMzNzk5NzcsImV4cCI6MTc3MzQ2NjM3N30.X4bfyvPfe0-mUWWXblCUB86nchuafyQDnFB51Hf3qck', 'samsung SM-G770F (Android 13)', 1, '2026-03-13 05:32:57', '2026-03-13 05:32:57'),
(41, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMzODIxMjYsImV4cCI6MTc3MzQ2ODUyNn0.sjKENvEurLTSnuqdWOO1Y_acm0tohSZj3R6_R8tylHw', 'samsung SM-G770F (Android 13)', 1, '2026-03-13 06:08:46', '2026-03-13 06:08:46'),
(42, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMzODIxODcsImV4cCI6MTc3MzQ2ODU4N30.qmlGMHrJk2l-OdyRNvnmKxRglROkybXBjzIEDuE8mj4', 'samsung SM-G770F (Android 13)', 1, '2026-03-13 06:09:47', '2026-03-13 06:09:47'),
(43, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMzODIzMDQsImV4cCI6MTc3MzQ2ODcwNH0.83xr3pRN7tS7WVsVaJfjDRbqlNAlXr3cgzAyKLVvvVY', 'samsung SM-G770F (Android 13)', 1, '2026-03-13 06:11:44', '2026-03-13 06:11:44'),
(44, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMzODQwMjgsImV4cCI6MTc3MzQ3MDQyOH0.PJY3L0ZMNzDneoSelcb7K0AEPYajOL-X9EixcQBOOss', 'samsung SM-G770F (Android 13)', 1, '2026-03-13 06:40:28', '2026-03-13 06:40:28'),
(45, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMzODQ0NzgsImV4cCI6MTc3MzQ3MDg3OH0.2h_PkW8vZtzJvf5DCaF2KSWPSQLQXY07A_duP9nidC4', 'Unknown Device', 1, '2026-03-13 06:47:58', '2026-03-13 06:47:58'),
(46, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzMzOTcyMDUsImV4cCI6MTc3MzQ4MzYwNX0.9usBxVhvBgTyA_lC0YcUSxwRbuRGAfbS9rwBekkk3E8', 'Unknown Device', 1, '2026-03-13 10:20:05', '2026-03-13 10:20:05'),
(47, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NDM5MDQsImV4cCI6MTc3MzczMDMwNH0.ioPgKCaDnxstQuuCFv7s4R253B5LaH3r64dZIbPukOE', 'Unknown Device', 1, '2026-03-16 06:51:44', '2026-03-16 06:51:44'),
(48, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NDQxMDAsImV4cCI6MTc3MzczMDUwMH0.zoCC_PPNX-k17Vp64VpcZW2rRYxdEmzgKS2-AMAQt_s', 'Unknown Device', 1, '2026-03-16 06:55:00', '2026-03-16 06:55:00'),
(49, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NDQyNDAsImV4cCI6MTc3MzczMDY0MH0.nQh0EBjYMfkRH6F-VuAT5JXsgX30zFrv3klJu5BCHTg', 'Unknown Device', 1, '2026-03-16 06:57:20', '2026-03-16 06:57:20'),
(50, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NDQ0MTAsImV4cCI6MTc3MzczMDgxMH0.8eCGPS9m46iJJxaf_mrcqRdGk0ILugmK3Rsr0AjLe24', 'Unknown Device', 1, '2026-03-16 07:00:10', '2026-03-16 07:00:10'),
(51, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NDQ2ODcsImV4cCI6MTc3MzczMTA4N30.gT1YVzzJYXBddXqmzoghY8WZ6j7SgQWMa7bDxkaqEwY', 'Unknown Device', 1, '2026-03-16 07:04:47', '2026-03-16 07:04:47'),
(52, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NDYwMzIsImV4cCI6MTc3MzczMjQzMn0.sOY0kn2DRg0jOm8QV0thNMWFpi3dTc6zMadKFQh9OSI', 'Unknown Device', 1, '2026-03-16 07:27:12', '2026-03-16 07:27:12'),
(53, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NDYwMzIsImV4cCI6MTc3MzczMjQzMn0.sOY0kn2DRg0jOm8QV0thNMWFpi3dTc6zMadKFQh9OSI', 'Unknown Device', 1, '2026-03-16 07:27:12', '2026-03-16 07:27:12'),
(54, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NDY0MjQsImV4cCI6MTc3MzczMjgyNH0.zacrQoGPYnrIa2OXUCakeHMQMU8WUKHb0IZGRqTROko', 'Unknown Device', 1, '2026-03-16 07:33:46', '2026-03-16 07:33:46'),
(55, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NDc1MzgsImV4cCI6MTc3MzczMzkzOH0.Q467GwkTW27gf6bTjYnX3tOr5MdrY-fNlXrrcBrGM7M', 'Unknown Device', 1, '2026-03-16 07:52:19', '2026-03-16 07:52:19'),
(56, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NTY5NjksImV4cCI6MTc3Mzc0MzM2OX0.8XU6RXUt-BwMjcW4MFgzPbe_-6Ugivs6q6Yu04JBvFM', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Sa', 1, '2026-03-16 10:29:29', '2026-03-16 10:29:29'),
(57, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3MzY1NzE2MiwiZXhwIjoxNzczNzQzNTYyfQ.7cCkm2rKB5ugtDT_nG_bi7W-pgEDNZbhyFlnFCTBO7k', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Sa', 1, '2026-03-16 10:32:42', '2026-03-16 10:32:42'),
(58, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3MzY1ODkwNCwiZXhwIjoxNzczNzQ1MzA0fQ.l4ZsMfP1jBl2ZTS5J9sAlhk2Axs2GCK_pENlaAPiZbY', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Sa', 1, '2026-03-16 11:01:44', '2026-03-16 11:01:44'),
(60, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM2NTk0MzEsImV4cCI6MTc3Mzc0NTgzMX0.r1vMKBjFyWlb1w7RbIhtXMi3dyW6gg585A7XndAWJbE', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Sa', 1, '2026-03-16 11:10:31', '2026-03-16 11:10:31'),
(61, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM3MzAyNzYsImV4cCI6MTc3MzgxNjY3Nn0.ZAitnCirtGtx9aE9Xvj9BmN7cyGdrsMQ9t8Kf0ug8oM', 'Unknown Device', 1, '2026-03-17 06:51:16', '2026-03-17 06:51:16'),
(62, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM3MzA0MDMsImV4cCI6MTc3MzgxNjgwM30.U3di0aXnok_JLxU7f49ZecaWXNe8zJqsLEY07wg4iMw', 'Unknown Device', 1, '2026-03-17 06:53:23', '2026-03-17 06:53:23'),
(63, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM3MzE2NTYsImV4cCI6MTc3MzgxODA1Nn0.aTgLAQTXzgP8USTYeX9kdz2djTsVnJi0FcBdUWEmOyw', 'Unknown Device', 1, '2026-03-17 07:14:16', '2026-03-17 07:14:16'),
(66, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3MzczMTg0MCwiZXhwIjoxNzczODE4MjQwfQ.hMqfLLxI43xOz88udBLzqqpSfBt3Ysicqal2dDDsrqI', 'Unknown Device', 1, '2026-03-17 07:17:20', '2026-03-17 07:17:20'),
(67, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3MzczMTk3OCwiZXhwIjoxNzczODE4Mzc4fQ.dFKiiN41JyBcDLmwQAXY-09-oPk-QezTV3AiJrTNvVA', 'Unknown Device', 1, '2026-03-17 07:19:38', '2026-03-17 07:19:38'),
(68, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM3MzI5MjgsImV4cCI6MTc3MzgxOTMyOH0.wErDWzPMjDQ-5Z-T07VmQo5BZlYToDLHlJgZPz5XCHw', 'Unknown Device', 1, '2026-03-17 07:35:28', '2026-03-17 07:35:28'),
(69, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM3MzQyNTYsImV4cCI6MTc3MzgyMDY1Nn0.8RV-j88_oNUCOPMfpNpmzrZOp_AGYIW1hIa62iRtFHY', 'Unknown Device', 1, '2026-03-17 07:57:36', '2026-03-17 07:57:36'),
(70, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM3NDc1ODQsImV4cCI6MTc3MzgzMzk4NH0.muaBjeG6mW6ggJXxd20nwQwNo3tiX2ulP-fH8Gq5pJs', 'Unknown Device', 1, '2026-03-17 11:39:44', '2026-03-17 11:39:44'),
(71, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM3NDg2NDIsImV4cCI6MTc3MzgzNTA0Mn0.Nw6aM8VXuWk-zwaVtsoJwxmNpfNAbYTy3oiunC_I3DE', 'Unknown Device', 1, '2026-03-17 11:57:22', '2026-03-17 11:57:22'),
(72, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM3NTIwMjMsImV4cCI6MTc3MzgzODQyM30.u-dJNROysWOnKPD3Tz6JW6voxKBAHtka26gnye8Vvsg', 'Unknown Device', 1, '2026-03-17 12:53:43', '2026-03-17 12:53:43'),
(73, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM4MTQzMDcsImV4cCI6MTc3MzkwMDcwN30.5ZJmCTNOWYpcxLya5M0LEhyhL98uXrhXfGOvUczHp44', 'Unknown Device', 1, '2026-03-18 06:11:47', '2026-03-18 06:11:47'),
(74, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM4MTc3NTAsImV4cCI6MTc3MzkwNDE1MH0.ux845F6Xz9vvv7lw3VleJq9s-Py_rRKg5JSm0MMQEO4', 'Unknown Device', 1, '2026-03-18 07:09:15', '2026-03-18 07:09:15'),
(75, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM4MTc3ODMsImV4cCI6MTc3MzkwNDE4M30.upLO1_TzSqKmSBIULxFg-QYs20vO1Hx8sgLMAiIC33A', 'Unknown Device', 1, '2026-03-18 07:09:43', '2026-03-18 07:09:43'),
(76, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM4MjA5MTUsImV4cCI6MTc3MzkwNzMxNX0.F9Y-AvaE1_ybOUqLcGULyeysE7iZ-wqAnR2o-ItQj0I', 'Unknown Device', 1, '2026-03-18 08:01:55', '2026-03-18 08:01:55'),
(77, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM4MjEyMjAsImV4cCI6MTc3MzkwNzYyMH0.1sm8mKLDXy72oKnokwaMqkNaC349mrqilNmgidlUm4o', 'samsung SM-G770F (Android 13)', 1, '2026-03-18 08:07:00', '2026-03-18 08:07:00'),
(78, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM4MzA3MjYsImV4cCI6MTc3MzkxNzEyNn0.xiEWUy2ezymmha_VaC9kKykTyeoUh_b-dJjeWz9WeV4', 'samsung SM-G770F (Android 13)', 1, '2026-03-18 10:45:26', '2026-03-18 10:45:26'),
(79, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM4MzM2MTYsImV4cCI6MTc3MzkyMDAxNn0.KcvYfSz9Eaau-I3mbym1R9bRGCeBwwBGjRtfIifXX3U', 'samsung SM-G770F (Android 13)', 1, '2026-03-18 11:33:36', '2026-03-18 11:33:36'),
(80, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzM4MzM3NTksImV4cCI6MTc3MzkyMDE1OX0.XqPs0uYIKeDg7xDg-ns3MBLBDw84K3CF5Myi3WxwYwM', 'samsung SM-G770F (Android 13)', 1, '2026-03-18 11:35:59', '2026-03-18 11:35:59'),
(85, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNDMwODYsImV4cCI6MTc3NDMyOTQ4Nn0.N0kpyeDc_2_QNnKl3pRmlwqbO_R2k5AB5vNjglfae8s', 'Unknown Device', 1, '2026-03-23 05:18:06', '2026-03-23 05:18:06'),
(86, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDI0MzIwNiwiZXhwIjoxNzc0MzI5NjA2fQ.gSlLY-NMRSTYWsYH3lRhYRPB14gi-ZN4B_9AF3g6YCg', 'Unknown Device', 1, '2026-03-23 05:20:06', '2026-03-23 05:20:06'),
(87, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDI0MzQwMCwiZXhwIjoxNzc0MzI5ODAwfQ.RZI5b4bXvdqBorL35VgsZxwO56ZPQhDo8bcBP_TDP1M', 'Unknown Device', 1, '2026-03-23 05:23:20', '2026-03-23 05:23:20'),
(97, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNTUxODIsImV4cCI6MTc3NDM0MTU4Mn0.RjCNi-TnEDB24cwylqJHkhTF8mPUAQaHdeJOrhGjc6k', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-23 08:39:42', '2026-03-23 08:39:42'),
(100, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNTU0ODEsImV4cCI6MTc3NDM0MTg4MX0.2_r8g-B6I7szjqHg6Q4epqhCLylntsMQ9MxcSJSzEqo', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-23 08:44:41', '2026-03-23 08:44:41'),
(103, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNTU1OTksImV4cCI6MTc3NDM0MTk5OX0.c04jM0-4ueMi3MgWXIx9hBhMaDutda-3abAYBir3teY', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-23 08:46:39', '2026-03-23 08:46:39'),
(105, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNTcwNTAsImV4cCI6MTc3NDM0MzQ1MH0.Otk5l9fYqMUyhvMFRxMifS8sm-M6yGHW59MQY9tp5f0', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-23 09:10:50', '2026-03-23 09:10:50'),
(108, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNTc5MDMsImV4cCI6MTc3NDM0NDMwM30.DPAQWBS-sStvLurKIUh8Am2RBFj74zZIo5IzZpEWSOM', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-23 09:25:03', '2026-03-23 09:25:03'),
(111, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNTg2OTcsImV4cCI6MTc3NDM0NTA5N30.ic0TcNO-Y2UU4pJJi-KO48SZo37BbJoIRCPLQEd6oFw', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-23 09:38:17', '2026-03-23 09:38:17'),
(112, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNTk0ODEsImV4cCI6MTc3NDM0NTg4MX0.XCmnD3ALOHeQ1bZYFPaLlEqBOAPV3tivt4NIBwKqSYA', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-23 09:51:21', '2026-03-23 09:51:21'),
(114, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNTk1MTMsImV4cCI6MTc3NDM0NTkxM30.vh0amaQwoyUiC4qAQwKLcz9FtqbWrvgxfHFuxqq1ZkI', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-23 09:51:53', '2026-03-23 09:51:53'),
(116, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDI2MDA4MSwiZXhwIjoxNzc0MzQ2NDgxfQ.Mp7cimP5JBdvMCaHSxqZntw2S1LwF3E15QkA9DgSTWc', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-23 10:01:21', '2026-03-23 10:01:21'),
(117, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDI2MDExNSwiZXhwIjoxNzc0MzQ2NTE1fQ.jJaG-t5a9QeUhvOt4_Mv0w6HqME8JDTQUXwHjElBbpE', 'samsung SM-G770F (Android 13)', 1, '2026-03-23 10:01:55', '2026-03-23 10:01:55'),
(120, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQyNjEwNzYsImV4cCI6MTc3NDM0NzQ3Nn0.SJSRVsJ8N6KzgDAeJias8aZ95Hu-CAvtMldnaaJa2UY', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-23 10:17:56', '2026-03-23 10:17:56'),
(125, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDMzNTEzNiwiZXhwIjoxNzc0NDIxNTM2fQ.BOZBVWKjL3R8JNAxan9hrujq_7DpMixZZB9NxfVK218', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-24 06:52:16', '2026-03-24 06:52:16'),
(127, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQzMzU5NzAsImV4cCI6MTc3NDQyMjM3MH0.9mW11s88zRJGSJNePHFIWzsTsLc0pWltMQN-KPGnfdU', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-24 07:06:10', '2026-03-24 07:06:10'),
(128, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDMzNjAwNCwiZXhwIjoxNzc0NDIyNDA0fQ.lzxUYWLBGf9s74i7UvcbOsumgzy3ayHRKjN97nREdHg', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-24 07:06:44', '2026-03-24 07:06:44'),
(129, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDMzNjEyOSwiZXhwIjoxNzc0NDIyNTI5fQ.MOL-KXiUbAYArv-1BxzNCA5HJv7JoQkf9F_qLjTFJq0', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-24 07:08:49', '2026-03-24 07:08:49'),
(131, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDMzNjc5NiwiZXhwIjoxNzc0NDIzMTk2fQ.Dt98sZOe2eSlG9dj78gtpjND-uLE_UTrKLC1QjqPFXk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-24 07:19:56', '2026-03-24 07:19:56'),
(136, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDM0NTI4MiwiZXhwIjoxNzc0NDMxNjgyfQ.N-FNLJHzokzCAvdE861M5Tax3RCb-cyIq1UeyqqRYaE', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-24 09:41:22', '2026-03-24 09:41:22'),
(137, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDM0NTg4NCwiZXhwIjoxNzc0NDMyMjg0fQ.WOZy7sRsIsN8Kl6_5_rxhzb2QyyAgiVm5Eba5MT67Vw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-24 09:51:24', '2026-03-24 09:51:24'),
(147, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQ2MDE1MTAsImV4cCI6MTc3NDY4NzkxMH0.XNJrOjiQgIxld5PShGTIYQG3zjIM5t8bZg6kGAhN7xk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-27 08:51:50', '2026-03-27 08:51:50'),
(150, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQ2MTIxODUsImV4cCI6MTc3NDY5ODU4NX0.Oxpz7GMZcZLYcK6X05zsKuVM69_2lg7wItVsvsRzlgs', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-03-27 11:49:45', '2026-03-27 11:49:45'),
(161, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDg2NDYwOSwiZXhwIjoxNzc0OTUxMDA5fQ.iaDDkTx7sTXhI_1zjz593-xqCL9xbOYQ97pvkHaFwjg', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-30 09:56:49', '2026-03-30 09:56:49'),
(162, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDg2ODk5NywiZXhwIjoxNzc0OTU1Mzk3fQ.CPzpaC5cM2qY5bjHI3AoisZbJuRDcXVwd8edZpHLQsA', 'Unknown Device', 1, '2026-03-30 11:09:57', '2026-03-30 11:09:57'),
(163, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDg3MTcxNCwiZXhwIjoxNzc0OTU4MTE0fQ.kNxr1MpMv0s2_YmWLluULYk_9xAC136PFXLo2z_vkMo', 'samsung SM-G770F (Android 13)', 1, '2026-03-30 11:55:14', '2026-03-30 11:55:14'),
(164, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDg3MzM0OCwiZXhwIjoxNzc0OTU5NzQ4fQ.5eberfhyEDNZhRsFWoGqw1FpU52J8yEPaXaCYzNY5SM', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-30 12:22:28', '2026-03-30 12:22:28'),
(165, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzQ4NzM4NzcsImV4cCI6MTc3NDk2MDI3N30.GDq9wWlSVwmsAp-hoSn-4gv2GpV1AAwzY-K5R_ZRRIY', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-30 12:31:17', '2026-03-30 12:31:17'),
(166, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDkzMDYwMywiZXhwIjoxNzc1MDE3MDAzfQ.fXlO54Q1yzFa2NLaSK6DV2TueuGKWwT0QhILbmaR4uw', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 04:16:43', '2026-03-31 04:16:43'),
(167, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDkzMDc0OSwiZXhwIjoxNzc1MDE3MTQ5fQ.3EsjCZGpZ0HrN5oLUW3yUYZ0k8lAksN8Q0JXQLD8X1w', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 04:19:10', '2026-03-31 04:19:10'),
(168, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDkzMDk2MywiZXhwIjoxNzc1MDE3MzYzfQ.ElOvi5s9rNQ0mrFcyt5PtrrdCun8-DlQ10dE2m5tEaE', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-31 04:22:43', '2026-03-31 04:22:43'),
(169, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDkzNTE3MywiZXhwIjoxNzc1MDIxNTczfQ.X7LdhNB2XTm5AthggG7W_6MwwlNoCwUyqQuUHextMDk', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 05:32:53', '2026-03-31 05:32:53'),
(170, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDkzNTI1NSwiZXhwIjoxNzc1MDIxNjU1fQ.0EDNiTyJXM_Tz8lpGADqj5qBH9xlG45AYloeC6TfDFQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-31 05:34:15', '2026-03-31 05:34:15'),
(171, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDkzNTM4OSwiZXhwIjoxNzc1MDIxNzg5fQ.zTBZ9ufnufX5TGKWOtbYrxiLVonjlbuJQZpyDkb9eRY', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 05:36:29', '2026-03-31 05:36:29'),
(172, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDkzNTM5NywiZXhwIjoxNzc1MDIxNzk3fQ.nou2Izr7vA_1aF3zssixnApFOuHO6YZQmXQx-EgoflQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-31 05:36:37', '2026-03-31 05:36:37'),
(173, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDkzNjY2NiwiZXhwIjoxNzc1MDIzMDY2fQ.SHS3Eq1yqu10uM4FaT7GjBt62FiVjwIJTQbkRfwzVgI', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 05:57:46', '2026-03-31 05:57:46'),
(174, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDkzNjc2MywiZXhwIjoxNzc1MDIzMTYzfQ.O3Q-Xk7F7iilj7Jhibu0_gvWClNXgHavm6I8YXVhp_w', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 05:59:23', '2026-03-31 05:59:23'),
(175, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDk0MzE4NCwiZXhwIjoxNzc1MDI5NTg0fQ.Kosr62vMhbaUT_hrAT0mGX8QRGzyQbrYKaKWiwyk-7I', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 07:46:24', '2026-03-31 07:46:24'),
(176, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDk1NTA0MCwiZXhwIjoxNzc1MDQxNDQwfQ.vJs9a0pfdTB09NINLOqAHyP9W8qaiZcI2v72D56-NG0', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-31 11:04:00', '2026-03-31 11:04:00'),
(177, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NDk1NTMzMCwiZXhwIjoxNzc1MDQxNzMwfQ.ioXTXber64q-RxHQo37BSmFxKZboOtXg1efU_3WdU2s', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-03-31 11:08:50', '2026-03-31 11:08:50'),
(178, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDk1NTc2MCwiZXhwIjoxNzc1MDQyMTYwfQ.x8pP1p_SJsSRzC02GzrBOHoPY20HC_6jzv12hhwod-c', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 11:16:00', '2026-03-31 11:16:00'),
(179, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDk1Njg3MSwiZXhwIjoxNzc1MDQzMjcxfQ.t2CFmGeR03Jk0zAgoYvHh6ugKckDtyWtNU1nCJCZMd8', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 11:34:31', '2026-03-31 11:34:31'),
(180, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NDk1NzE4NiwiZXhwIjoxNzc1MDQzNTg2fQ.2_Mo9WWMGRZ9JKQoYemJoDJsi8VGBHe53bWfPJZbrXE', 'samsung SM-G770F (Android 13)', 1, '2026-03-31 11:39:46', '2026-03-31 11:39:46'),
(181, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAxNzM5NSwiZXhwIjoxNzc1MTAzNzk1fQ.eoml_j7Hnu_Gws5TUO8vfyzl3jzW1jPDDnRlMI-akQE', 'Unknown Device', 1, '2026-04-01 04:23:15', '2026-04-01 04:23:15'),
(182, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAxODM0NiwiZXhwIjoxNzc1MTA0NzQ2fQ.K90BmynxaAVYkX6lDi7INn3wuINquF1aI6LA7ixd_Kc', 'Unknown Device', 1, '2026-04-01 04:39:06', '2026-04-01 04:39:06'),
(183, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAyMDU2MCwiZXhwIjoxNzc1MTA2OTYwfQ.c8wMs7kK8c7x2kQwfoQY2BXYU1vefegL0dmL2rlaqS4', 'Unknown Device', 1, '2026-04-01 05:16:00', '2026-04-01 05:16:00'),
(184, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAyMjEyMiwiZXhwIjoxNzc1MTA4NTIyfQ.mUam_glZMrr_Q9pND-9nyFrT2Uu7JEA5Fngf4KOULU8', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 05:42:02', '2026-04-01 05:42:02'),
(185, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAyMjMzNSwiZXhwIjoxNzc1MTA4NzM1fQ.9tJxmYB7UMBYnU6zZfqdRNSMmfNLMW5a_lTp6UNNFFM', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 05:45:35', '2026-04-01 05:45:35'),
(186, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwMjU5MzIsImV4cCI6MTc3NTExMjMzMn0.o7uqgGRmS2s8FGCj91mUBZKfEzhtFboSC_KH-9NdcpQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 06:45:32', '2026-04-01 06:45:32'),
(187, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAyNjAwNCwiZXhwIjoxNzc1MTEyNDA0fQ.NhPOdkSccK5mN5EGULhXUj8Ln8iBKZGik2XxROf2dOA', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 06:46:44', '2026-04-01 06:46:44'),
(188, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwMjk1MDUsImV4cCI6MTc3NTExNTkwNX0.LMLhHzc2jNaO6xoV09UKeGMuyid2e0bX7kMx-W_VatQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 07:45:05', '2026-04-01 07:45:05'),
(189, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAyOTU5MCwiZXhwIjoxNzc1MTE1OTkwfQ.cKvIm__ivVK-JGfSuUudkH8kI8vF-DWgjFN6JRj_110', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 07:46:30', '2026-04-01 07:46:30'),
(190, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwMjk2NDEsImV4cCI6MTc3NTExNjA0MX0.C56QIYebSrl7eRx8cyW82cqmHvYms9u74ROEDx0b2VM', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 07:47:21', '2026-04-01 07:47:21'),
(191, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwMzQ5MTMsImV4cCI6MTc3NTEyMTMxM30.sxb_5CzT_J30giJ72D8H631VQIpodFygAG0VU9uAi-o', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 09:15:13', '2026-04-01 09:15:13'),
(192, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwMzUwMDgsImV4cCI6MTc3NTEyMTQwOH0.A3TSvGzH9Al04rHUBhPjp-xMJT0PpGeKuNCc_wBvdGw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 09:16:48', '2026-04-01 09:16:48'),
(193, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwMzUwMjQsImV4cCI6MTc3NTEyMTQyNH0.yhDnujFJjNJEwEwL9Xk-PhsnRiAL3VAz_NQhIyj-LZI', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 09:17:04', '2026-04-01 09:17:04'),
(194, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAzNTA5NCwiZXhwIjoxNzc1MTIxNDk0fQ.Hb6MXvHmx7M2--EzZDDrNgeU0w8loHg-54TeHvmmhI8', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 09:18:14', '2026-04-01 09:18:14'),
(195, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwMzY1NjIsImV4cCI6MTc3NTEyMjk2Mn0.uVvkVcNUA5GxH_PT5VQdOkwn3FQ9sYlluc5ntvAtNuQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 09:42:42', '2026-04-01 09:42:42'),
(196, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAzNzAxOCwiZXhwIjoxNzc1MTIzNDE4fQ.lQsGyAobHA6aAgoMC58_mW7LDHZpwNPA1vixY58NwO8', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 09:50:18', '2026-04-01 09:50:18'),
(197, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTAzOTQxNywiZXhwIjoxNzc1MTI1ODE3fQ.9-4Y55xuOocsG5RerIY-E7JiyNdSyI731U0xG8mAnhk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 10:30:17', '2026-04-01 10:30:17'),
(198, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTA0Mzg2NiwiZXhwIjoxNzc1MTMwMjY2fQ.PQ7aa2ar1k9LwQuk9AG-5e-uKDLaToTWxyRyhWk7aTM', 'samsung SM-G770F (Android 13)', 1, '2026-04-01 11:44:26', '2026-04-01 11:44:26'),
(199, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwNDUzMDUsImV4cCI6MTc3NTEzMTcwNX0.u4iRiHSQ6p7LjeNlqYC7OGVvxonIdmgDusvVGjXohNU', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 12:08:25', '2026-04-01 12:08:25'),
(200, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwNDYwMDEsImV4cCI6MTc3NTEzMjQwMX0.Q9NTU5g0oBeqPl_u3d0128AAOIZ2Qp1E3GI7i0M1Muk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 12:20:01', '2026-04-01 12:20:01'),
(201, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTA0NjAxNSwiZXhwIjoxNzc1MTMyNDE1fQ.NjsPtMDqRHoxQo_8blzXBrbXU2LpVp6g3TV7x1HrkPw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 12:20:15', '2026-04-01 12:20:15'),
(202, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwNDYxNjIsImV4cCI6MTc3NTEzMjU2Mn0.pwRshFlKSjeyNKORhDr_91gzzxHLdzOyoSo8sbpQNEI', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 12:22:42', '2026-04-01 12:22:42'),
(203, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUwNDY2MTQsImV4cCI6MTc3NTEzMzAxNH0.yElKObpCxISk-Vsa-kKQG1yOlbIuKxQclv9BEyB957M', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 12:30:14', '2026-04-01 12:30:14'),
(204, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTA0NjYyMiwiZXhwIjoxNzc1MTMzMDIyfQ.X9Dv6MIQdmeRxffwuqPBh3TST6oirYkKf9H_gcNB8Og', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 12:30:22', '2026-04-01 12:30:22'),
(205, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTA0NjY4MCwiZXhwIjoxNzc1MTMzMDgwfQ.RFNrWQg7lmM8rAfHIL3SN9WbsB-yaDydQQm8qpXScYE', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-01 12:31:20', '2026-04-01 12:31:20'),
(206, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTA0NjczNiwiZXhwIjoxNzc1MTMzMTM2fQ.xsq2fnwiH7BSHiK6MI4X-YcxT2bj5pS1uzo-p9edG7M', 'samsung SM-G770F (Android 13)', 1, '2026-04-01 12:32:16', '2026-04-01 12:32:16'),
(207, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTEwMzExNCwiZXhwIjoxNzc1MTg5NTE0fQ.vKxI9Rn9maJXvNpaNOHm-4nZl7sAvsFYTYeDq_gJBIQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:11:54', '2026-04-02 04:11:54'),
(208, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMDM1ODksImV4cCI6MTc3NTE4OTk4OX0.CCTsSyAyUiKutusmBCLBpZ8GJ13pTnJc7AjbsUh7hOk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:19:49', '2026-04-02 04:19:49'),
(209, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMDM5MDYsImV4cCI6MTc3NTE5MDMwNn0.NKOLYZA2ClL9R6BVltFJD600tkH0kDQQvuFPD8S6aQQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:25:06', '2026-04-02 04:25:06'),
(210, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMDQ2MTMsImV4cCI6MTc3NTE5MTAxM30.8VJhi_FZc-aNWf8UlS0gZ6n56fuBPnAHJ56sYnr36jI', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:36:53', '2026-04-02 04:36:53'),
(211, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTEwNDYyNywiZXhwIjoxNzc1MTkxMDI3fQ.-rkAspdcxXLInKrM8UDv7Uyo9_GaGdCO8GHWc_jvMaU', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:37:07', '2026-04-02 04:37:07'),
(212, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTEwNTM5NCwiZXhwIjoxNzc1MTkxNzk0fQ.GDmFOz89Y8VKjHRPUkMkDZJX5f8s9iDg1Q9wdBTlWYk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:49:54', '2026-04-02 04:49:54'),
(213, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNTU1NywiZXhwIjoxNzc1MTkxOTU3fQ.h8Y3-oZLN2LrnsOf7yZcC-ZUwrOo36U_Iewv3RhRnqQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:52:37', '2026-04-02 04:52:37'),
(214, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMDU2NjksImV4cCI6MTc3NTE5MjA2OX0.1jocztOlNnG3LHQM-P-kl8-qMDFCdfZ9fslCfTQdXik', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:54:29', '2026-04-02 04:54:29'),
(215, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNTY5MywiZXhwIjoxNzc1MTkyMDkzfQ.BSh8bik-pSkXrSMfjDdwbDeh4-6Ld8b3czTLKLkV4aE', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:54:53', '2026-04-02 04:54:53'),
(216, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNTcwNiwiZXhwIjoxNzc1MTkyMTA2fQ.xzFsuxxwjoILfZOFq9zwlcsNtWA5zQNzvKZxNRcK9Yw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:55:06', '2026-04-02 04:55:06'),
(217, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNTcyNiwiZXhwIjoxNzc1MTkyMTI2fQ.XAp_xy2Ui9d9zOlBrxvM1WEfuCOtrcBDTES6vdcoRGo', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:55:26', '2026-04-02 04:55:26'),
(218, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNTc0OCwiZXhwIjoxNzc1MTkyMTQ4fQ.G4-B4N5mh_cjCmUEl0EHjHNCvZCdCQ4PQwzhaYu1eHc', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 04:55:48', '2026-04-02 04:55:48'),
(219, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMDYwMDYsImV4cCI6MTc3NTE5MjQwNn0.8b2hUIoXzUrGnYWfdIi8UWG-omZOx4-EaiJWAUmQnGA', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 05:00:06', '2026-04-02 05:00:06'),
(220, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNjE1MCwiZXhwIjoxNzc1MTkyNTUwfQ.N4oUUqSvvlfgP3cePCrPM2G2R16TamZO6A_JahlPKmU', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 05:02:30', '2026-04-02 05:02:30'),
(221, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNzA1MCwiZXhwIjoxNzc1MTkzNDUwfQ.LFRTG6HI1OmttX5V7gWRFM6BW8NW8BF0yimvVwHOwpQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 05:17:30', '2026-04-02 05:17:30'),
(222, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNzcwNiwiZXhwIjoxNzc1MTk0MTA2fQ.RF1a7DXUKx0kDoLVYPjpBws3eJjLzYrTygpO_5zLCG8', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 05:28:26', '2026-04-02 05:28:26'),
(223, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNzg2NiwiZXhwIjoxNzc1MTk0MjY2fQ.sVBh2BiBvVV0UrS8L7SE2QZixMal80Jx_IXJ8sId3Vk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 05:31:06', '2026-04-02 05:31:06'),
(224, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEwNzkxMywiZXhwIjoxNzc1MTk0MzEzfQ.723KOFaloa3l8CMppEJEc6FNBYjVAkRCN58aS0IW_PM', 'samsung SM-G770F (Android 13)', 1, '2026-04-02 05:31:53', '2026-04-02 05:31:53'),
(225, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMTI3NzEsImV4cCI6MTc3NTE5OTE3MX0.Kt8TLgt4PEOLoFW0lKTzuZ8UOGdhNzbLdF2HR466tG0', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 06:52:51', '2026-04-02 06:52:51'),
(226, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMTI4ODksImV4cCI6MTc3NTE5OTI4OX0.X4Aw4RSN5v2HfbZHtFJv9aU-8Abl_YLcLIPzURvmcYE', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 06:54:49', '2026-04-02 06:54:49'),
(227, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTExNDM1NiwiZXhwIjoxNzc1MjAwNzU2fQ.CfN_yWQvGf0ygjsobw3PQntR4UQeqxm96LWxNo0siGs', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:19:16', '2026-04-02 07:19:16'),
(228, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTExNDQzOCwiZXhwIjoxNzc1MjAwODM4fQ._MAOoO0WIVSq8nSFC9rPYpYBu9hIpe-8v7U0mk7odYk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:20:38', '2026-04-02 07:20:38'),
(229, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNDQ0NiwiZXhwIjoxNzc1MjAwODQ2fQ.gxmnnBM_o8lPdDDBLgxqHzXvVVVALlWGiJwzBf1Z3A4', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:20:46', '2026-04-02 07:20:46'),
(230, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNDY2NiwiZXhwIjoxNzc1MjAxMDY2fQ.9wG7F77CnN4vJcS3jUu0Cfc40cd_0MStt5rFqHX1L5w', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:24:26', '2026-04-02 07:24:26'),
(231, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNDY3NywiZXhwIjoxNzc1MjAxMDc3fQ.vU9o0IMdIr_9rh2xGC59j9XqfEFGpcE8BvOf6MsA9wY', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:24:37', '2026-04-02 07:24:37'),
(232, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNDcwMSwiZXhwIjoxNzc1MjAxMTAxfQ.LRUf0aNDDU3HjJznH8YkOidEyD3_Hyny51sMqvgXROU', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:25:01', '2026-04-02 07:25:01'),
(233, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNDc5MywiZXhwIjoxNzc1MjAxMTkzfQ.ax3gszQVvCQmoF1lEziTrG3_pfVuwt_q_xLsQJ9pgxk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:26:33', '2026-04-02 07:26:33'),
(234, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNDc5OSwiZXhwIjoxNzc1MjAxMTk5fQ.v97YvGF5hbbMWi5YR1_mR2HbqKVn1rnt5Bd5N_Iz6Vs', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:26:39', '2026-04-02 07:26:39'),
(235, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNDgzNiwiZXhwIjoxNzc1MjAxMjM2fQ.POou4y-PjBywwv1Qd2TLwXjQswpLB87bqyyHYWK_OYU', 'samsung SM-G770F (Android 13)', 1, '2026-04-02 07:27:16', '2026-04-02 07:27:16'),
(236, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNjI5NSwiZXhwIjoxNzc1MjAyNjk1fQ.n36oCWgfDJqFeFMnJ_7Fq7OJEwm8O5nuriEetyzL0tk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:51:35', '2026-04-02 07:51:35'),
(237, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNjMzNiwiZXhwIjoxNzc1MjAyNzM2fQ.WkW6pRlZ3Wn2V_8q8hyl2_uLHvpgoK24sP3sCWbv9Ho', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:52:16', '2026-04-02 07:52:16');
INSERT INTO `user_sessions` (`id`, `user_id`, `token`, `device_info`, `active`, `created_at`, `last_active`) VALUES
(238, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTExNjM4NiwiZXhwIjoxNzc1MjAyNzg2fQ.JFgA8XQjS6JscucK_CuEGyjeAiMCi5Ay2w0AvcM40rc', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:53:06', '2026-04-02 07:53:06'),
(239, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTExNjUyMCwiZXhwIjoxNzc1MjAyOTIwfQ.edpblJi10IBX--1S5vGKJzw9TVm3msUuoilNZyr6sjs', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:55:20', '2026-04-02 07:55:20'),
(240, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTExNjU1NiwiZXhwIjoxNzc1MjAyOTU2fQ.vCJUMbiyJayi6PP3HAFksKG2vccm_LOo1qjtJCiWpwg', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 07:55:56', '2026-04-02 07:55:56'),
(241, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyMDYwMiwiZXhwIjoxNzc1MjA3MDAyfQ.lRAMdNhPfRSiu4TxTxdrM6mC5a17y-Aed2H2nO-Lx1w', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 09:03:22', '2026-04-02 09:03:22'),
(242, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyMDYwNywiZXhwIjoxNzc1MjA3MDA3fQ.BfbjQXwQDPNl2qNfjGsbvja7xHOostZZ4vAl-XMVNUE', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 09:03:27', '2026-04-02 09:03:27'),
(243, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMjA2MTksImV4cCI6MTc3NTIwNzAxOX0.qS58BsdCaPljzh13pdyElGLXWvzp2G0K0dV5U2woCgI', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 09:03:39', '2026-04-02 09:03:39'),
(244, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyMDY4NSwiZXhwIjoxNzc1MjA3MDg1fQ.jvVDuyyBXlBD6ysijKCGtqTDW_t2YAath5xK-460h0Y', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 09:04:45', '2026-04-02 09:04:45'),
(245, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyMDgyMSwiZXhwIjoxNzc1MjA3MjIxfQ.dtpG24I0p3gq8cx9yG0eaAwYGFdbIY3HiHK8m2LZfoU', 'samsung SM-G770F (Android 13)', 1, '2026-04-02 09:07:01', '2026-04-02 09:07:01'),
(246, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyMDg1NCwiZXhwIjoxNzc1MjA3MjU0fQ.4UT7yPXB6g_dfSMClaqcjgWNfb12C0MRX7i-x7e9Pvw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 09:07:34', '2026-04-02 09:07:34'),
(247, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyMDg4MywiZXhwIjoxNzc1MjA3MjgzfQ.HNRZuWY6bfv5DvTV8dZs8-hRNDoXFOgP1fvZ8aSy0z8', 'samsung SM-G770F (Android 13)', 1, '2026-04-02 09:08:03', '2026-04-02 09:08:03'),
(248, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTEyMDk1MCwiZXhwIjoxNzc1MjA3MzUwfQ.UzisQGyrtfmHGd78odm0kUel5sWXgMdyYq9sZh01yG0', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 09:09:10', '2026-04-02 09:09:10'),
(249, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTEyMjE3NiwiZXhwIjoxNzc1MjA4NTc2fQ.QOb-DqacaDt_phh5oJU7Cc75BHo1b1vT1CBSrPn3Fdg', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 09:29:36', '2026-04-02 09:29:36'),
(250, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyMjMzMiwiZXhwIjoxNzc1MjA4NzMyfQ.c5DbTycQmzH5kH6nLYRcBcl4lVz5dFVsXlPtSYRzNIg', 'Unknown Device', 1, '2026-04-02 09:32:12', '2026-04-02 09:32:12'),
(251, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyMzc0MCwiZXhwIjoxNzc1MjEwMTQwfQ.V4MBR45B6mF3cM7sOKDbnoU5WttRwmNroiHI9MXpUv8', 'samsung SM-G770F (Android 13)', 1, '2026-04-02 09:55:40', '2026-04-02 09:55:40'),
(252, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMjM5NTgsImV4cCI6MTc3NTIxMDM1OH0.OLJ894m1xdCoibmRHOiYWrRdC8HLOz9VXBRAP0cc-Tg', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 09:59:18', '2026-04-02 09:59:18'),
(253, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMjYwOTMsImV4cCI6MTc3NTIxMjQ5M30.hzkJ4XNdUDQIcIgsZobq-ee3ELsYwAHPTceeD_AsHJc', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 10:34:53', '2026-04-02 10:34:53'),
(254, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyODA5MiwiZXhwIjoxNzc1MjE0NDkyfQ.dyLlHTMhoQnQbWJuZ-nc_S_SDJpej0VReCk-rV68iD8', 'samsung SM-G770F (Android 13)', 1, '2026-04-02 11:08:12', '2026-04-02 11:08:12'),
(255, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEyODE0NCwiZXhwIjoxNzc1MjE0NTQ0fQ.xwovkfcyyBfyzdzbyLmVyq6lNkjrFFS1vMNWAu2bqgk', 'Unknown Device', 1, '2026-04-02 11:09:04', '2026-04-02 11:09:04'),
(256, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMjg2MzUsImV4cCI6MTc3NTIxNTAzNX0.tlhU-bZcvEqUuMgVdPbVUSE8Ag3mg4Qws3CrIxEhy9E', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 11:17:15', '2026-04-02 11:17:15'),
(257, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMjk0ODEsImV4cCI6MTc3NTIxNTg4MX0.Q4mJO7uVLnaW0dqPoAqpFchwt1bR0jf_rElTWXLGTro', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 11:31:21', '2026-04-02 11:31:21'),
(258, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTEzMTIwNSwiZXhwIjoxNzc1MjE3NjA1fQ.HrpTZ79ZWe_Hkp4mPA3Gbd-pe20zdhWnsaTbuZ3cUUU', 'Unknown Device', 1, '2026-04-02 12:00:05', '2026-04-02 12:00:05'),
(259, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUxMzM0ODgsImV4cCI6MTc3NTIxOTg4OH0.TOEzUk29iie2vtRbXkPI1mS2MJ1R88V7iuzp2zuVFOY', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-02 12:38:08', '2026-04-02 12:38:08'),
(260, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTE5MDQ0NywiZXhwIjoxNzc1Mjc2ODQ3fQ.z7RfecVajk_vhTW4Kzfmieo9aTRZEsNVowdm_aLbOjM', 'samsung SM-G770F (Android 13)', 1, '2026-04-03 04:27:28', '2026-04-03 04:27:28'),
(261, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTE5NTk4MCwiZXhwIjoxNzc1MjgyMzgwfQ.2flMm9zQ8dHr6c9VsRiZiAalb0eFOtR0cJrkhNzFFsw', 'Xiaomi 22031116AI (Android 13)', 1, '2026-04-03 05:59:40', '2026-04-03 05:59:40'),
(262, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTE5ODEwNCwiZXhwIjoxNzc1Mjg0NTA0fQ.9IDkL3P1m_rbrZiObewPQwFoXBJUaxn5tz3-diohvBI', 'samsung SM-G770F (Android 13)', 1, '2026-04-03 06:35:04', '2026-04-03 06:35:04'),
(263, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTE5OTUyOSwiZXhwIjoxNzc1Mjg1OTI5fQ.-4SgospoJduWLQtLFQ8053NpSi__efUcY--D_cdfGBM', 'samsung SM-G770F (Android 13)', 1, '2026-04-03 06:58:49', '2026-04-03 06:58:49'),
(264, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTIxNjY2NSwiZXhwIjoxNzc1MzAzMDY1fQ.rLr17OMGEv_Ch5UixA9qieG1gSbE2YnhJeARVSA117Y', 'samsung SM-G770F (Android 13)', 1, '2026-04-03 11:44:25', '2026-04-03 11:44:25'),
(265, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTIxODkxMiwiZXhwIjoxNzc1MzA1MzEyfQ.4QoBEBOUdZw-hRVPd-DBOtPylXjMY4FhxoNQiYrcE0g', 'samsung SM-G770F (Android 13)', 1, '2026-04-03 12:21:52', '2026-04-03 12:21:52'),
(266, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUyMTk2MjEsImV4cCI6MTc3NTMwNjAyMX0.JxnqSdpuLJgcr_lbwVtJBRIS4uICMXF2SJ7cK8Gdz4o', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-03 12:33:41', '2026-04-03 12:33:41'),
(267, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUyMTk5OTYsImV4cCI6MTc3NTMwNjM5Nn0.AOoQuoc_Vth2CLbe1pqjz8hkHJeajFqd_Cjmdk6sZwc', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-03 12:39:56', '2026-04-03 12:39:56'),
(268, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUyMjAwMDIsImV4cCI6MTc3NTMwNjQwMn0.xBooKZn8fIFTmPvH71Ba-rO4yz-l2LpnDddGvYkoKgI', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-03 12:40:02', '2026-04-03 12:40:02'),
(269, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUyMjAwMDcsImV4cCI6MTc3NTMwNjQwN30.YG380gXwJT_-jeaEWx6FbLVSoC__6Ufkp-vBbFKH214', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-03 12:40:07', '2026-04-03 12:40:07'),
(270, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUyMjAwMTEsImV4cCI6MTc3NTMwNjQxMX0.lKVDUpswlAUAS4iTEvejBnPRwYjRTDsfHYUS1T-o0Jw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-03 12:40:11', '2026-04-03 12:40:11'),
(271, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUyMjAwMTcsImV4cCI6MTc3NTMwNjQxN30.7uk9vWu_Vkvneo-b0g-CQI8KpE7c2b4_lcosGbU_Nls', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-03 12:40:17', '2026-04-03 12:40:17'),
(272, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzUyMjAwMjEsImV4cCI6MTc3NTMwNjQyMX0.O1kfOk0flK_E6VOOOLf6_8StRYdbceurZpFZ_mDRZ04', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-03 12:40:21', '2026-04-03 12:40:21'),
(273, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTIyMDI0NiwiZXhwIjoxNzc1MzA2NjQ2fQ.KhIKVIH96uDeNzXrAsumRzSlt3tfMTmc_hivD1l4Y1U', 'samsung SM-G770F (Android 13)', 1, '2026-04-03 12:44:06', '2026-04-03 12:44:06'),
(274, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTQ1MTEzMywiZXhwIjoxNzc1NTM3NTMzfQ.ufbjZLNCgnAN06bsuBuE9IaiC4c3_XhDX-uZSKidWP8', 'samsung SM-G770F (Android 13)', 1, '2026-04-06 04:52:13', '2026-04-06 04:52:13'),
(275, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTQ1ODg5OSwiZXhwIjoxNzc1NTQ1Mjk5fQ.-q9fGgm1NM3d0cbTnrTNGA6CKKmoN3_HuW4a2vUe2qU', 'Unknown Device', 1, '2026-04-06 07:01:41', '2026-04-06 07:01:41'),
(276, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTQ1OTk3MywiZXhwIjoxNzc1NTQ2MzczfQ.OZ9TQitk8sMBjr3JKedGYuGi7DSufPZy1D7h4Fz527I', 'samsung SM-G770F (Android 13)', 1, '2026-04-06 07:19:33', '2026-04-06 07:19:33'),
(277, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTQ2ODg3MSwiZXhwIjoxNzc1NTU1MjcxfQ.AHU-BilyQXWAXjhKDfXABd99MtHPOhqGPdPkymRwLD0', 'samsung SM-G770F (Android 13)', 1, '2026-04-06 09:47:51', '2026-04-06 09:47:51'),
(278, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTQ3MzkzMSwiZXhwIjoxNzc1NTYwMzMxfQ.k7Dz6v49XnwhD5LxhLoNFvQGdzDNXFjVXcVT_k63YSQ', 'samsung SM-G770F (Android 13)', 1, '2026-04-06 11:12:11', '2026-04-06 11:12:11'),
(279, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTYyMzIxMywiZXhwIjoxNzc1NzA5NjEzfQ.aP3wojl7mGrXLFuI__8_kSUJAOKSkGjSEZQbauG-Xbc', 'samsung SM-G770F (Android 13)', 1, '2026-04-08 04:40:13', '2026-04-08 04:40:13'),
(280, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTY0Mjk3OCwiZXhwIjoxNzc1NzI5Mzc4fQ.EMsLXF3TgB6vkcBuoG9y6rdLQXRYCPtLyfOof9PPEPc', 'samsung SM-G770F (Android 13)', 1, '2026-04-08 10:09:39', '2026-04-08 10:09:39'),
(281, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzU2NDYxMzQsImV4cCI6MTc3NTczMjUzNH0.9Oh_XhKrzYYoerQT1B9fO29khM6edVdL3NpqKWWOk4M', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-08 11:02:14', '2026-04-08 11:02:14'),
(282, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTY0ODg5OSwiZXhwIjoxNzc1NzM1Mjk5fQ.fRqazYrpd2q6v1uXNws3XqDYDj_2WgkEC0t5v_BZQcw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-08 11:48:19', '2026-04-08 11:48:19'),
(283, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTY0OTI5NiwiZXhwIjoxNzc1NzM1Njk2fQ.Q0GhMLiQjjKnBI2OKsOxAzgFRoB8CRxkN1OZ-Hzia-c', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-08 11:54:56', '2026-04-08 11:54:56'),
(284, 21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIxLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTY0OTMxOCwiZXhwIjoxNzc1NzM1NzE4fQ.y5naAfV9_V0Xrn2EeOVMn7gpOAa1vjkRcX5xskc0qmE', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-08 11:55:18', '2026-04-08 11:55:18'),
(285, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTY0OTMzNSwiZXhwIjoxNzc1NzM1NzM1fQ.aSiHSIUkBKJPfsxkycMR6OUUBULno2gwcav2RKfWiUo', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-08 11:55:35', '2026-04-08 11:55:35'),
(286, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTY0OTM1MSwiZXhwIjoxNzc1NzM1NzUxfQ.37Sre_-JWDP9mXZszXULiMofLSODkCUohQcHsvDakeM', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-08 11:55:51', '2026-04-08 11:55:51'),
(287, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTY0OTM5NCwiZXhwIjoxNzc1NzM1Nzk0fQ.-RHool4cFYwt-bCe1ESDnWNFR6G352NMhYVkyw4WaaM', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-08 11:56:34', '2026-04-08 11:56:34'),
(288, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTY1MTc2NywiZXhwIjoxNzc1NzM4MTY3fQ.onmDoo1lLLq1t5-K3ON9qYybEFyuGHMF7aICenI8fWk', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-08 12:36:07', '2026-04-08 12:36:07'),
(289, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzU2NTI4NjgsImV4cCI6MTc3NTczOTI2OH0.Hp1LeabUB4jIYFynyOnpm-NH9FXLUGdt-41r7TLYkbM', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-08 12:54:28', '2026-04-08 12:54:28'),
(290, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzU3MDg3MzEsImV4cCI6MTc3NTc5NTEzMX0.jJbF-6eaIyx38vaCDj6GPVXfGayjtPnRt2XyS9-KmNs', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-09 04:25:31', '2026-04-09 04:25:31'),
(291, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTcwODc1MiwiZXhwIjoxNzc1Nzk1MTUyfQ.TzQ0TSfro95nGvWmCI7rv7XTeyMg6Li8ys90KiOKLbQ', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-09 04:25:52', '2026-04-09 04:25:52'),
(292, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTcwODc2NSwiZXhwIjoxNzc1Nzk1MTY1fQ.q6QRn-CWEhBxWAXtrIUW3TxZtLAymZMeCtcHRjskCg8', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-09 04:26:05', '2026-04-09 04:26:05'),
(293, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTcwODgwNywiZXhwIjoxNzc1Nzk1MjA3fQ.7azI5g-Loz2_CFPgtUoysJlpV0ltC1cpuvxVxN7V5sU', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-09 04:26:47', '2026-04-09 04:26:47'),
(294, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTcwODgxOSwiZXhwIjoxNzc1Nzk1MjE5fQ.CrImaYw2h4yLGLad0dAkUcbKdYw91dK5B-60_P_nNxQ', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-09 04:26:59', '2026-04-09 04:26:59'),
(295, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzU3MDg4ODcsImV4cCI6MTc3NTc5NTI4N30.qZXaQ0Nua03bBgS8mnvMHOwh-a5ikupI8SP2M3YShV0', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-09 04:28:07', '2026-04-09 04:28:07'),
(296, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTcwODk3OCwiZXhwIjoxNzc1Nzk1Mzc4fQ.jSX52AbbHdYRz2iP5m_zhciVgXeV8J51UabDlfWNjmw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-09 04:29:38', '2026-04-09 04:29:38'),
(297, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTcwOTA3OSwiZXhwIjoxNzc1Nzk1NDc5fQ.sgHiKgnmQQPois7upZEWVlYR0hZ3ZRdBn8zGXMhOEOA', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-09 04:31:19', '2026-04-09 04:31:19'),
(298, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTcxMDAwMCwiZXhwIjoxNzc1Nzk2NDAwfQ.3g19woGIqK2uk8cGCl3hSVjqcReJ-tNWvPr9JaFFNsM', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-09 04:46:40', '2026-04-09 04:46:40'),
(299, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTcxMjE5NiwiZXhwIjoxNzc1Nzk4NTk2fQ._y-bRdki7QVrydk_LPCpJAXAMo2vrUOPZk5NInJF-Nc', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-09 05:23:16', '2026-04-09 05:23:16'),
(300, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTcxMjIwNSwiZXhwIjoxNzc1Nzk4NjA1fQ.kmiUqc-3uMLJrNTAC-SV7Ur9dCDaac2PozgobEj0qkw', 'Browser: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', 1, '2026-04-09 05:23:25', '2026-04-09 05:23:25'),
(301, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTcyOTQwNywiZXhwIjoxNzc1ODE1ODA3fQ.l_NkkbC5Sblxf9YIcgETikOwXQxuL87cfpv3zEXTFu0', 'samsung SM-G770F (Android 13)', 1, '2026-04-09 10:10:07', '2026-04-09 10:10:07'),
(302, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTcyOTYyOSwiZXhwIjoxNzc1ODE2MDI5fQ.ryMbfVEsK2KwtiGRjAlCAe6MPz-E-m0-nBbPHfOb0Ws', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-09 10:13:49', '2026-04-09 10:13:49'),
(303, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTcyOTY0NSwiZXhwIjoxNzc1ODE2MDQ1fQ.eKiZKEOVXW2uMr2kQ5C9op6bub7VmyvJwqjYEBcPrjw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-09 10:14:05', '2026-04-09 10:14:05'),
(304, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTcyOTY4NywiZXhwIjoxNzc1ODE2MDg3fQ.tzIl1ui_f0bPRBqfmOZFAo6ti8GXyy6SGmlzJtoWm4w', 'samsung SM-G770F (Android 13)', 1, '2026-04-09 10:14:47', '2026-04-09 10:14:47'),
(305, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTcyOTcwNiwiZXhwIjoxNzc1ODE2MTA2fQ.JhC59C5t-eg8C2eo2BjfcqyjdYlW0nVrXYDOK1npAvw', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-09 10:15:06', '2026-04-09 10:15:06'),
(306, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTczNjMzNiwiZXhwIjoxNzc1ODIyNzM2fQ.v407Yr02VnetmvlZyHQUd1Obag92_fU7cFO4zvnLIMQ', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-09 12:05:36', '2026-04-09 12:05:36'),
(307, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJDRU8iLCJpYXQiOjE3NzU3MzczMTgsImV4cCI6MTc3NTgyMzcxOH0.R2AAfSrDziAcf8sOOG37V44J5XW3fcJEfO1noCTHScE', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-09 12:21:58', '2026-04-09 12:21:58'),
(308, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTc5NTE1MywiZXhwIjoxNzc1ODgxNTUzfQ.V-YuwUbi7MRDavBdlaGO8C1Qt9FzwZDZdYOLBr_RIVE', 'Unknown Device', 1, '2026-04-10 04:25:53', '2026-04-10 04:25:53'),
(309, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTc5NTg3MywiZXhwIjoxNzc1ODgyMjczfQ.Bz-YYFBNkO1vhYanLIsYUQqh9Um_IKLpn0koL9G-Y9E', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-10 04:37:53', '2026-04-10 04:37:53'),
(310, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTc5NTkwMSwiZXhwIjoxNzc1ODgyMzAxfQ.nT1tcZE6iA0wW6Ng_-NLktVd51o5U1z3iNt0YMBrybk', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-10 04:38:21', '2026-04-10 04:38:21'),
(311, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE0LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTc5NTk2MCwiZXhwIjoxNzc1ODgyMzYwfQ.Hf56icbTJtYBVz6-ScUbGXBjAwL9IY84E9PSF5Jxpl8', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-10 04:39:20', '2026-04-10 04:39:20'),
(312, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTc5NTk4NywiZXhwIjoxNzc1ODgyMzg3fQ.jbaQn8i_1nAMhOxGn15sXuDtbZ-2YLQE1KDYyZcpfPM', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-10 04:39:47', '2026-04-10 04:39:47'),
(313, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE0LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTc5NjExNywiZXhwIjoxNzc1ODgyNTE3fQ.pfQF8NzHxQ-cgPYXxbPXY9_3XBZGNG0_Iy6uC_FcD9o', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-10 04:41:57', '2026-04-10 04:41:57'),
(314, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE0LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTc5NjE4MiwiZXhwIjoxNzc1ODgyNTgyfQ.D9jOA_Y3RF8xepeTNzJoFaijseMlQ41kppHBzEJPDGE', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-10 04:43:02', '2026-04-10 04:43:02'),
(315, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTc5NjE5MSwiZXhwIjoxNzc1ODgyNTkxfQ.UbHLqQFEMzweyXXxhHR57scg1a-fQxf9FG7uIC5f8N8', 'Browser: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Sa', 1, '2026-04-10 04:43:11', '2026-04-10 04:43:11'),
(316, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTc5NzMwMSwiZXhwIjoxNzc1ODgzNzAxfQ.YAxNXElFNAdd0BaCqUzZea5cGo5II48A12E_HMbQYr4', 'Unknown Device', 1, '2026-04-10 05:01:41', '2026-04-10 05:01:41'),
(317, 20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIwLCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTc5OTA0OCwiZXhwIjoxNzc1ODg1NDQ4fQ.m9bG5i6Lxw00hmkEYctuuEyUbj9tXlJEH7CrrQSH1qk', 'Unknown Device', 1, '2026-04-10 05:30:48', '2026-04-10 05:30:48'),
(318, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTc5OTA5NywiZXhwIjoxNzc1ODg1NDk3fQ.Q5G7lRZnQQ91ZeUCMGB8_XQbvlqRPlSXz44MN1VFRfw', 'Unknown Device', 1, '2026-04-10 05:31:37', '2026-04-10 05:31:37'),
(319, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE5LCJyb2xlIjoiVVNFUiIsImlhdCI6MTc3NTc5OTk2NywiZXhwIjoxNzc1ODg2MzY3fQ.aOOQxW8sHk2Mdi91k0SAAng-v61fNvGg-P5S2kxBctI', 'Unknown Device', 1, '2026-04-10 05:46:07', '2026-04-10 05:46:07'),
(320, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTgwMjcwMCwiZXhwIjoxNzc1ODg5MTAwfQ.b_zDg_UhtYSNaC_G9m7oBqiZrpx8ARa-FRkg1l309F4', 'Unknown Device', 1, '2026-04-10 06:31:40', '2026-04-10 06:31:40'),
(321, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTgwMzc5OCwiZXhwIjoxNzc1ODkwMTk4fQ.VW-3yET63SE-BIWS5sbJbhZ17NaxB6fpMSi4gaCa4go', 'Unknown Device', 1, '2026-04-10 06:49:58', '2026-04-10 06:49:58'),
(322, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE4LCJyb2xlIjoiTUFOQUdFUiIsImlhdCI6MTc3NTgwNTkxNSwiZXhwIjoxNzc1ODkyMzE1fQ.Pzo6VOMAWxM7jhN-SYGBWGzaNGF52j6ckh4fjgjXrEk', 'Unknown Device', 1, '2026-04-10 07:25:15', '2026-04-10 07:25:15');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `expansion_funds`
--
ALTER TABLE `expansion_funds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reviewed_by` (`reviewed_by`),
  ADD KEY `idx_manager` (`manager_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `expansion_fund_documents`
--
ALTER TABLE `expansion_fund_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_expansion_fund` (`expansion_fund_id`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_expense_date` (`expense_date`);

--
-- Indexes for table `expense_documents`
--
ALTER TABLE `expense_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_expense` (`expense_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_notif` (`user_id`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_created` (`created_at`);

--
-- Indexes for table `operational_funds`
--
ALTER TABLE `operational_funds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_from_user` (`from_user_id`),
  ADD KEY `idx_to_user` (`to_user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `fk_fund_expansion` (`expansion_id`);

--
-- Indexes for table `registration_otps`
--
ALTER TABLE `registration_otps`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_manager_id` (`manager_id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `expansion_funds`
--
ALTER TABLE `expansion_funds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT for table `expansion_fund_documents`
--
ALTER TABLE `expansion_fund_documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT for table `expense_documents`
--
ALTER TABLE `expense_documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=84;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=365;

--
-- AUTO_INCREMENT for table `operational_funds`
--
ALTER TABLE `operational_funds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=139;

--
-- AUTO_INCREMENT for table `registration_otps`
--
ALTER TABLE `registration_otps`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=323;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `expansion_funds`
--
ALTER TABLE `expansion_funds`
  ADD CONSTRAINT `expansion_funds_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expansion_funds_ibfk_2` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `expansion_fund_documents`
--
ALTER TABLE `expansion_fund_documents`
  ADD CONSTRAINT `expansion_fund_documents_ibfk_1` FOREIGN KEY (`expansion_fund_id`) REFERENCES `expansion_funds` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `expense_documents`
--
ALTER TABLE `expense_documents`
  ADD CONSTRAINT `expense_documents_ibfk_1` FOREIGN KEY (`expense_id`) REFERENCES `expenses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `operational_funds`
--
ALTER TABLE `operational_funds`
  ADD CONSTRAINT `fk_fund_expansion` FOREIGN KEY (`expansion_id`) REFERENCES `expansion_funds` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `operational_funds_ibfk_1` FOREIGN KEY (`from_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `operational_funds_ibfk_2` FOREIGN KEY (`to_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Database: `expense_management_flutter`
--
CREATE DATABASE IF NOT EXISTS `expense_management_flutter` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `expense_management_flutter`;

-- --------------------------------------------------------

--
-- Table structure for table `expansion_funds`
--

CREATE TABLE `expansion_funds` (
  `id` int(11) NOT NULL,
  `manager_id` int(11) NOT NULL,
  `requested_amount` decimal(15,2) NOT NULL,
  `approved_amount` decimal(15,2) DEFAULT NULL,
  `justification` text NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','ALLOCATED') DEFAULT 'PENDING',
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` int(11) DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expansion_funds`
--

INSERT INTO `expansion_funds` (`id`, `manager_id`, `requested_amount`, `approved_amount`, `justification`, `status`, `requested_at`, `reviewed_at`, `reviewed_by`, `rejection_reason`, `created_at`, `updated_at`) VALUES
(22, 20, 800.00, 800.00, 'Expansion fund for approved expense: headohone  (ID: 37)', 'ALLOCATED', '2026-02-05 10:39:44', '2026-02-05 10:53:17', 1, NULL, '2026-02-05 10:39:44', '2026-02-05 10:57:58'),
(23, 20, 6000.00, 6000.00, 'Expansion fund for approved expense: buy a Moniter (ID: 36)', 'ALLOCATED', '2026-02-05 10:44:55', '2026-02-05 10:52:58', 1, NULL, '2026-02-05 10:44:55', '2026-02-05 10:55:05'),
(24, 20, 500.00, 500.00, 'Expansion fund for approved expense: buy water bottle (ID: 40)', 'ALLOCATED', '2026-02-06 11:09:29', '2026-02-06 11:11:17', 1, NULL, '2026-02-06 11:09:29', '2026-02-06 11:12:04'),
(25, 18, 300.00, 300.00, 'Expansion fund for approved expense: buy A4 Size paper (ID: 42)', 'ALLOCATED', '2026-02-09 10:40:51', '2026-02-09 10:43:53', 1, NULL, '2026-02-09 10:40:51', '2026-02-09 10:44:45'),
(38, 18, 1500.00, 1500.00, 'Expansion fund for approved expense: buy HDD (ID: 53)', 'ALLOCATED', '2026-02-10 09:51:10', '2026-02-10 09:53:01', 1, NULL, '2026-02-10 09:51:10', '2026-02-10 10:12:22'),
(41, 20, 500.00, 500.00, 'Expansion fund for approved expense: buy mouse (ID: 55)', 'ALLOCATED', '2026-02-10 11:50:25', '2026-02-10 11:51:01', 1, NULL, '2026-02-10 11:50:25', '2026-02-10 11:52:12'),
(43, 18, 7000.00, 7000.00, 'Expansion fund for approved expense: for wifi bill (ID: 58)', 'ALLOCATED', '2026-02-11 06:56:03', '2026-02-11 06:56:53', 1, NULL, '2026-02-11 06:56:03', '2026-02-11 06:57:13'),
(58, 20, 1500.00, 1500.00, 'Expansion fund for approved expense: for watter bill (ID: 59)', 'ALLOCATED', '2026-02-11 10:43:33', '2026-02-11 12:02:05', 1, NULL, '2026-02-11 10:43:33', '2026-02-11 12:02:19'),
(60, 18, 4000.00, 4000.00, 'Expansion fund for approved expense: website hosting (ID: 62)', 'ALLOCATED', '2026-02-12 06:32:13', '2026-02-12 06:39:16', 1, NULL, '2026-02-12 06:32:13', '2026-02-12 06:40:05');

-- --------------------------------------------------------

--
-- Table structure for table `expansion_fund_documents`
--

CREATE TABLE `expansion_fund_documents` (
  `id` int(11) NOT NULL,
  `expansion_fund_id` int(11) NOT NULL,
  `document_path` varchar(500) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `file_type` varchar(50) NOT NULL,
  `file_size` int(11) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `category` varchar(100) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `expense_date` date NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('PENDING_APPROVAL','APPROVED','REJECTED','RECEIPT_APPROVED','FUND_ALLOCATED','COMPLETED') DEFAULT 'PENDING_APPROVAL',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `fund_provided_at` timestamp NULL DEFAULT NULL,
  `receipt_confirmed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`id`, `user_id`, `title`, `category`, `department`, `amount`, `expense_date`, `description`, `status`, `approved_by`, `approved_at`, `rejection_reason`, `fund_provided_at`, `receipt_confirmed_at`, `created_at`, `updated_at`) VALUES
(36, 19, 'buy a Moniter', 'Equipment', 'IT', 6000.00, '2026-02-04', 'buy a new moniter for new employee', 'COMPLETED', 20, '2026-02-05 10:36:17', NULL, NULL, '2026-02-05 11:03:14', '2026-02-05 10:14:32', '2026-02-05 11:03:14'),
(37, 19, 'headohone ', 'Equipment', 'Sales', 800.00, '2026-02-05', 'buy a new headphone', 'COMPLETED', 20, '2026-02-05 10:36:11', NULL, NULL, '2026-02-05 11:03:19', '2026-02-05 10:34:00', '2026-02-05 11:03:19'),
(38, 20, 'client meeting', 'Travel', 'Sales', 1500.00, '2026-02-05', 'travel for a client meeting in surat', 'COMPLETED', 1, '2026-02-05 11:20:13', NULL, NULL, '2026-02-05 11:22:12', '2026-02-05 11:01:14', '2026-02-05 11:22:12'),
(39, 20, 'dinner', 'Meals & Entertainment', 'Marketing', 2000.00, '2026-02-05', 'marketing team dinner', 'COMPLETED', 1, '2026-02-05 11:20:10', NULL, NULL, '2026-02-05 11:22:24', '2026-02-05 11:02:35', '2026-02-05 11:22:24'),
(40, 19, 'buy water bottle', 'Office Supplies', 'Marketing', 500.00, '2026-02-05', 'buy new water bottle', 'COMPLETED', 20, '2026-02-06 11:09:14', NULL, NULL, '2026-02-06 11:14:00', '2026-02-06 10:29:57', '2026-02-06 11:14:00'),
(42, 21, 'buy A4 Size paper', 'Office Supplies', 'Finance', 300.00, '2026-02-09', 'buy A4 size paper ', 'COMPLETED', 18, '2026-02-09 10:39:07', NULL, NULL, '2026-02-09 10:47:00', '2026-02-09 10:37:03', '2026-02-09 10:47:00'),
(46, 18, 'sports day celebration', 'Meals & Entertainment', 'Marketing', 3000.00, '2026-02-09', 'sports day celebration', 'COMPLETED', 1, '2026-02-10 05:58:25', NULL, NULL, '2026-02-10 06:08:38', '2026-02-10 05:57:04', '2026-02-10 06:08:38'),
(53, 21, 'buy HDD', 'Equipment', 'Marketing', 1500.00, '2026-02-10', 'buy 1TB HDD', 'COMPLETED', 18, '2026-02-10 09:50:35', NULL, NULL, '2026-02-10 11:09:04', '2026-02-10 09:49:11', '2026-02-10 11:09:04'),
(54, 18, 'for client meeting venue', 'Accommodation', 'IT', 1800.00, '2026-02-10', 'for client meeting', 'COMPLETED', 1, '2026-02-10 11:15:55', NULL, NULL, '2026-02-10 11:45:09', '2026-02-10 11:15:12', '2026-02-10 11:45:09'),
(55, 19, 'buy mouse', 'Equipment', 'Operations', 500.00, '2026-02-10', 'buy mouse', 'COMPLETED', 20, '2026-02-10 11:49:33', NULL, NULL, '2026-02-10 11:55:23', '2026-02-10 11:48:52', '2026-02-10 11:55:23'),
(58, 21, 'for wifi bill', 'Office Supplies', 'Operations', 7000.00, '2026-02-11', 'pay yearly wifi bill ', 'COMPLETED', 18, '2026-02-11 06:34:19', NULL, NULL, '2026-02-11 12:42:30', '2026-02-11 06:32:29', '2026-02-11 12:42:30'),
(59, 19, 'for watter bill', 'Office Supplies', 'Operations', 1500.00, '2026-02-11', 'for pay water bill', 'COMPLETED', 20, '2026-02-11 10:41:52', NULL, NULL, '2026-02-11 12:03:40', '2026-02-11 10:41:06', '2026-02-11 12:03:40'),
(60, 20, 'for work anniversary gift ', 'work anniversary', 'HR', 400.00, '2026-02-09', 'for work anniversary gift for employee', 'COMPLETED', 1, '2026-02-11 11:38:34', NULL, NULL, '2026-02-11 11:40:56', '2026-02-11 11:15:05', '2026-02-11 11:40:56'),
(61, 21, 'Domain purchase', 'website expense', 'IT', 400.00, '2026-02-11', 'for website domain purchase ', 'PENDING_APPROVAL', NULL, NULL, NULL, NULL, NULL, '2026-02-12 05:35:12', '2026-02-12 06:45:15'),
(62, 21, 'website hosting', 'website expense', 'IT', 4000.00, '2026-02-12', 'for website hosting', 'COMPLETED', 18, '2026-02-12 05:39:59', NULL, NULL, '2026-02-12 06:44:33', '2026-02-12 05:36:39', '2026-02-12 06:44:33'),
(63, 18, 'buy new laptop', 'Equipment', 'Finance', 40000.00, '2026-02-11', 'for buy new laptop for new finance department', 'COMPLETED', 1, '2026-02-12 06:42:09', NULL, NULL, '2026-02-12 06:43:41', '2026-02-12 05:38:46', '2026-02-12 06:43:41'),
(64, 18, 'battery', 'Equipment', 'Marketing', 1200.00, '2026-02-12', 'buy a laptop battery', 'COMPLETED', 1, '2026-02-12 05:52:22', NULL, NULL, '2026-02-12 06:14:05', '2026-02-12 05:39:34', '2026-02-12 06:14:05');

-- --------------------------------------------------------

--
-- Table structure for table `expense_documents`
--

CREATE TABLE `expense_documents` (
  `id` int(11) NOT NULL,
  `expense_id` int(11) NOT NULL,
  `document_path` varchar(500) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `file_type` varchar(50) NOT NULL,
  `file_size` int(11) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expense_documents`
--

INSERT INTO `expense_documents` (`id`, `expense_id`, `document_path`, `original_filename`, `file_type`, `file_size`, `uploaded_at`) VALUES
(46, 36, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770286472535-925261165.pdf', 'Expansion_Request_REQ-0021 (11).pdf', 'application/pdf', 10397, '2026-02-05 10:14:32'),
(47, 37, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770287640939-243408536.pdf', 'Expansion_Request_REQ-0021 (10).pdf', 'application/pdf', 10397, '2026-02-05 10:34:01'),
(48, 38, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770289274009-200970223.pdf', 'Expansion_Request_REQ-0021 (10).pdf', 'application/pdf', 10397, '2026-02-05 11:01:14'),
(49, 39, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770289355444-648752976.pdf', 'Expansion_Request_REQ-0021 (10).pdf', 'application/pdf', 10397, '2026-02-05 11:02:35'),
(52, 42, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770633423505-45296360.pdf', 'allocation_usage_report (1).pdf', 'application/pdf', 11046, '2026-02-09 10:37:03'),
(56, 46, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770703023959-87092774.pdf', 'all_expenses (6).pdf', 'application/pdf', 22659, '2026-02-10 05:57:04'),
(63, 53, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770716951185-407174291.pdf', 'Expansion_REQ-0025 (1).pdf', 'application/pdf', 9969, '2026-02-10 09:49:11'),
(64, 54, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770722112819-851607158.pdf', 'my_expenses (2).pdf', 'application/pdf', 11265, '2026-02-10 11:15:12'),
(65, 55, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770724132068-126887921.pdf', 'Manager_Report_Neel_Patel (1).pdf', 'application/pdf', 12383, '2026-02-10 11:48:52'),
(68, 58, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770791549519-211227908.pdf', 'Expansion_REQ-0034.pdf', 'application/pdf', 9968, '2026-02-11 06:32:29'),
(69, 59, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770806465694-241810089.pdf', 'fund_allocation_history (2).pdf', 'application/pdf', 26110, '2026-02-11 10:41:06'),
(70, 60, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770808503750-857070217.pdf', 'received_funds (1).pdf', 'application/pdf', 18679, '2026-02-11 11:15:05'),
(71, 61, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770874511454-290877395.png', 'Screenshot-2.png', 'image/png', 113575, '2026-02-12 05:35:12'),
(72, 62, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770874599852-195448792.png', 'introduction-to-cybersecurity.png', 'image/png', 42155, '2026-02-12 05:36:40'),
(74, 64, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770874774204-946852549.pdf', 'fund_allocation_history (1).pdf', 'application/pdf', 44707, '2026-02-12 05:39:34'),
(75, 63, 'C:\\Users\\ADMIN\\OneDrive\\Desktop\\Office_Expenses_Management\\backend\\uploads\\expenses\\expense-1770876912495-252204954.pdf', 'my_expenses (3).pdf', 'application/pdf', 13296, '2026-02-12 06:15:13');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `related_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `type`, `title`, `message`, `is_read`, `related_id`, `created_at`) VALUES
(30, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager1 has requested an expansion fund of Rs. 7000.00.', 1, 7, '2026-01-29 12:42:06'),
(34, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"travel for meeting \" for Rs. 2000.', 1, 21, '2026-01-30 06:03:00'),
(38, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"travel for meeting \" for Rs. 2000.', 1, 22, '2026-01-30 08:40:59'),
(41, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"travel for meeting\" for Rs. 2000.', 1, 23, '2026-01-30 08:55:11'),
(45, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"for Team lunch\" for Rs. 1500.', 1, 24, '2026-01-30 10:02:04'),
(48, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager1 has requested an expansion fund of Rs. 300.00.', 1, 8, '2026-01-30 10:06:57'),
(57, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"client dinner\" for Rs. 1000.', 1, 26, '2026-02-02 05:51:04'),
(60, 1, 'USER_REGISTERED', 'New User Registration', 'raja has registered as a USER and is pending approval.', 1, 11, '2026-02-02 10:33:04'),
(62, 1, 'USER_REGISTERED', 'New User Registration', 'raja has registered as a USER and is pending approval.', 1, 12, '2026-02-02 11:03:47'),
(64, 1, 'USER_REGISTERED', 'New User Registration', 'raja has registered as a USER and is pending approval.', 1, 13, '2026-02-02 11:07:08'),
(66, 1, 'USER_REGISTERED', 'New User Registration', 'raja has registered as a USER and is pending approval.', 1, 14, '2026-02-02 11:39:15'),
(67, 14, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 14, '2026-02-02 11:39:51'),
(68, 1, 'USER_REGISTERED', 'New User Registration', 'user8 has registered as a USER and is pending approval.', 1, 15, '2026-02-02 12:14:45'),
(70, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager1 has submitted an expense \"client dinner\" for Rs. 2000.', 1, 27, '2026-02-03 06:52:41'),
(73, 14, 'ACCOUNT_STATUS', 'Account Deactivated', 'Your account has been deactivated by the CEO.', 1, 14, '2026-02-03 11:44:28'),
(74, 14, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 14, '2026-02-03 11:45:15'),
(75, 14, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: manager3.', 1, 14, '2026-02-03 12:50:32'),
(79, 14, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy new mouse\" for Rs. 300.00 has been approved.', 1, 28, '2026-02-03 12:55:18'),
(80, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 9, '2026-02-03 12:55:34'),
(81, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 10, '2026-02-03 12:55:40'),
(82, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 11, '2026-02-03 12:55:42'),
(83, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 12, '2026-02-03 12:55:43'),
(84, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 13, '2026-02-03 12:55:45'),
(85, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 14, '2026-02-03 12:55:47'),
(86, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 15, '2026-02-03 12:59:27'),
(87, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 16, '2026-02-03 13:00:18'),
(88, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 18, '2026-02-04 04:42:50'),
(92, 14, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy new mouse\" for Rs. 300.00 has been approved.', 1, 30, '2026-02-04 05:02:05'),
(93, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 300.00.', 1, 19, '2026-02-04 05:02:43'),
(96, 14, 'FUND_ALLOCATED', 'New Fund Allocation', 'manager3 has allocated Rs. 300.00 to your account.', 1, 51, '2026-02-04 05:32:19'),
(98, 14, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for REM\" for Rs. 1600.00 has been approved.', 1, 31, '2026-02-04 05:54:28'),
(99, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 1600.00.', 1, 20, '2026-02-04 05:55:00'),
(102, 14, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy a new moniter\" for Rs. 6000.00 has been approved.', 1, 32, '2026-02-04 06:51:36'),
(103, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'manager3 has requested an expansion fund of Rs. 6000.00.', 1, 21, '2026-02-04 06:51:55'),
(104, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager3 has submitted an expense \"team dinner\" for Rs. 2000.', 1, 34, '2026-02-04 06:54:03'),
(105, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'manager3 has submitted an expense \"client meeting \" for Rs. 1500.', 1, 35, '2026-02-04 06:54:58'),
(113, 14, 'FUND_ALLOCATED', 'New Fund Allocation', 'manager3 has allocated Rs. 6000.00 to your account.', 1, 56, '2026-02-04 09:48:52'),
(114, 1, 'USER_REGISTERED', 'New User Registration', 'user1 has registered as a USER and is pending approval.', 1, 16, '2026-02-04 11:52:04'),
(115, 1, 'USER_REGISTERED', 'New User Registration', 'user1 has registered as a USER and is pending approval.', 1, 17, '2026-02-04 12:06:26'),
(116, 1, 'USER_REGISTERED', 'New User Registration', 'kishan sharma has registered as a MANAGER and is pending approval.', 1, 18, '2026-02-04 13:01:02'),
(117, 1, 'USER_REGISTERED', 'New User Registration', 'Deep Dantani has registered as a USER and is pending approval.', 1, 19, '2026-02-05 05:01:59'),
(118, 18, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 18, '2026-02-05 05:23:37'),
(119, 19, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 19, '2026-02-05 05:23:59'),
(120, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:34:00'),
(122, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:34:45'),
(124, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 05:37:40'),
(125, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:37:57'),
(127, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 05:56:45'),
(128, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:56:55'),
(130, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 05:57:01'),
(131, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:58:55'),
(133, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 05:59:04'),
(134, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 05:59:12'),
(136, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 06:03:53'),
(137, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 06:04:56'),
(139, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You are no longer assigned to a manager.', 1, 19, '2026-02-05 06:05:52'),
(140, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 06:06:16'),
(142, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: kishan sharma.', 1, 19, '2026-02-05 08:05:33'),
(143, 14, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: kishan sharma.', 0, 14, '2026-02-05 08:05:35'),
(144, 18, 'USER_ASSIGNED', 'New User Assigned', 'Deep Dantani has been assigned to you.', 1, 19, '2026-02-05 08:05:36'),
(145, 18, 'USER_ASSIGNED', 'New User Assigned', 'raja has been assigned to you.', 1, 14, '2026-02-05 08:05:39'),
(146, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 08:06:26'),
(147, 14, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 0, 14, '2026-02-05 08:06:28'),
(150, 1, 'USER_REGISTERED', 'New User Registration', 'Neel Patel has registered as a MANAGER and is pending approval.', 1, 20, '2026-02-05 09:26:58'),
(151, 20, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 20, '2026-02-05 09:29:25'),
(152, 19, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 1, 19, '2026-02-05 09:29:43'),
(153, 14, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: Neel Patel.', 0, 14, '2026-02-05 09:29:45'),
(154, 20, 'USER_ASSIGNED', 'New User Assigned', 'Deep Dantani has been assigned to you.', 1, 19, '2026-02-05 09:29:46'),
(155, 20, 'USER_ASSIGNED', 'New User Assigned', 'raja has been assigned to you.', 1, 14, '2026-02-05 09:29:48'),
(156, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"buy a Moniter\" for Rs. 6000.', 1, 36, '2026-02-05 10:14:32'),
(157, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"headohone \" for Rs. 800.', 1, 37, '2026-02-05 10:34:01'),
(158, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"headohone \" for Rs. 800.00 has been approved.', 1, 37, '2026-02-05 10:36:11'),
(159, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy a Moniter\" for Rs. 6000.00 has been approved.', 1, 36, '2026-02-05 10:36:17'),
(160, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 800.00.', 1, 22, '2026-02-05 10:39:44'),
(161, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 6000.00.', 1, 23, '2026-02-05 10:44:55'),
(162, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 6000.00 has been approved for Rs. 6000.00.', 1, 23, '2026-02-05 10:52:59'),
(163, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 800.00 has been approved for Rs. 800.00.', 1, 22, '2026-02-05 10:53:17'),
(164, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 6000.00 to your account.', 1, 57, '2026-02-05 10:55:05'),
(165, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 800.00 to your account.', 1, 58, '2026-02-05 10:57:58'),
(166, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 800.00 to your account.', 1, 59, '2026-02-05 10:59:12'),
(167, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 6000.00 to your account.', 1, 60, '2026-02-05 10:59:39'),
(168, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'Neel Patel has submitted an expense \"client meeting\" for Rs. 1500.', 1, 38, '2026-02-05 11:01:14'),
(169, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'Neel Patel has submitted an expense \"dinner\" for Rs. 2000.', 1, 39, '2026-02-05 11:02:35'),
(170, 20, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"dinner\" for Rs. 2000.00 has been approved.', 1, 39, '2026-02-05 11:20:10'),
(171, 20, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"client meeting\" for Rs. 1500.00 has been approved.', 1, 38, '2026-02-05 11:20:13'),
(172, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 2000.00 to your account.', 1, 61, '2026-02-05 11:20:34'),
(173, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 62, '2026-02-05 11:21:19'),
(174, 18, 'ACCOUNT_STATUS', 'Account Deactivated', 'Your account has been deactivated by the CEO.', 1, 18, '2026-02-06 06:32:16'),
(175, 18, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 18, '2026-02-06 06:32:38'),
(176, 1, 'USER_REGISTERED', 'New User Registration', 'Manav kheni has registered as a USER and is pending approval.', 1, 21, '2026-02-06 10:26:03'),
(177, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"buy water bottle\" for Rs. 500.', 1, 40, '2026-02-06 10:29:57'),
(178, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy water bottle\" for Rs. 500.00 has been approved.', 1, 40, '2026-02-06 11:09:14'),
(179, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 500.00.', 1, 24, '2026-02-06 11:09:29'),
(180, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 500.00 has been approved for Rs. 500.00.', 1, 24, '2026-02-06 11:11:17'),
(181, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 500.00 to your account.', 1, 63, '2026-02-06 11:12:04'),
(182, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 500.00 to your account.', 1, 64, '2026-02-06 11:13:09'),
(183, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"dff\" for Rs. 5000.', 1, 41, '2026-02-06 11:14:54'),
(184, 21, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 1, 21, '2026-02-06 11:55:53'),
(185, 21, 'MANAGER_ASSIGNED', 'Manager Assigned', 'You have been assigned to manager: kishan sharma.', 1, 21, '2026-02-06 11:56:14'),
(186, 18, 'USER_ASSIGNED', 'New User Assigned', 'Manav kheni has been assigned to you.', 1, 21, '2026-02-06 11:56:18'),
(187, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy A4 Size paper\" for Rs. 300.', 1, 42, '2026-02-09 10:37:04'),
(188, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy A4 Size paper\" for Rs. 300.00 has been approved.', 1, 42, '2026-02-09 10:39:07'),
(189, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 300.00.', 1, 25, '2026-02-09 10:40:51'),
(190, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 300.00 has been approved for Rs. 300.00.', 1, 25, '2026-02-09 10:43:53'),
(191, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 300.00 to your account.', 1, 65, '2026-02-09 10:44:46'),
(192, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 300.00 to your account.', 1, 66, '2026-02-09 10:45:46'),
(193, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 500.', 1, 26, '2026-02-09 12:52:54'),
(194, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy HDD\" for Rs. 1500.', 1, 43, '2026-02-10 05:50:10'),
(195, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy HDD\" for Rs. 1500.00 has been approved.', 1, 43, '2026-02-10 05:51:13'),
(196, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"sports day celebration\" for Rs. 3000.', 1, 44, '2026-02-10 05:53:00'),
(197, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"sports day celebration\" for Rs. 3000.', 1, 45, '2026-02-10 05:53:12'),
(198, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"sports day celebration\" for Rs. 3000.', 1, 46, '2026-02-10 05:57:04'),
(199, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"sports day celebration\" for Rs. 3000.00 has been approved.', 1, 46, '2026-02-10 05:58:25'),
(200, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 3000.00 to your account.', 1, 67, '2026-02-10 06:03:31'),
(201, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 27, '2026-02-10 06:30:20'),
(202, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy HDD\" for Rs. 1500.', 1, 47, '2026-02-10 06:34:51'),
(203, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy graphic card\" for Rs. 5200.', 1, 48, '2026-02-10 06:36:05'),
(204, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy HDD\" for Rs. 1500.00 has been approved.', 1, 47, '2026-02-10 06:36:53'),
(205, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 28, '2026-02-10 06:45:45'),
(206, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy graphic card\" for Rs. 5200.00 has been approved.', 1, 48, '2026-02-10 06:53:25'),
(207, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 29, '2026-02-10 07:16:32'),
(208, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 30, '2026-02-10 08:48:01'),
(209, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 31, '2026-02-10 08:48:34'),
(210, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 32, '2026-02-10 08:49:35'),
(211, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 33, '2026-02-10 08:49:36'),
(212, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 34, '2026-02-10 09:01:54'),
(213, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 5200.00 has been approved for Rs. 5200.00.', 1, 34, '2026-02-10 09:04:38'),
(214, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 5200.00 to your account.', 1, 68, '2026-02-10 09:16:42'),
(215, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy Graphic card\" for Rs. 5200.', 1, 49, '2026-02-10 09:25:36'),
(216, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy HDD\" for Rs. 1500.', 1, 50, '2026-02-10 09:26:32'),
(217, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy HDD\" for Rs. 1500.00 has been approved.', 1, 50, '2026-02-10 09:27:21'),
(218, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 35, '2026-02-10 09:27:34'),
(219, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy Graphic card\" for Rs. 5200.00 has been approved.', 1, 49, '2026-02-10 09:28:03'),
(220, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 36, '2026-02-10 09:28:17'),
(221, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"team dinner\" for Rs. 2500.', 1, 51, '2026-02-10 09:30:04'),
(222, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 1500.00 has been approved for Rs. 1500.00.', 1, 35, '2026-02-10 09:31:06'),
(223, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 69, '2026-02-10 09:31:35'),
(224, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 5200.00 has been approved for Rs. 5200.00.', 1, 36, '2026-02-10 09:34:40'),
(225, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 5200.00 to your account.', 1, 70, '2026-02-10 09:36:03'),
(226, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"team dinner\" for Rs. 2500.00 has been approved.', 1, 51, '2026-02-10 09:41:23'),
(227, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy Graphic card\" for Rs. 5200.', 1, 52, '2026-02-10 09:48:30'),
(228, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"buy HDD\" for Rs. 1500.', 1, 53, '2026-02-10 09:49:11'),
(229, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy HDD\" for Rs. 1500.00 has been approved.', 1, 53, '2026-02-10 09:50:35'),
(230, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 37, '2026-02-10 09:50:43'),
(231, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 1500.00.', 1, 38, '2026-02-10 09:51:10'),
(232, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy Graphic card\" for Rs. 5200.00 has been approved.', 1, 52, '2026-02-10 09:51:31'),
(233, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 5200.00.', 1, 39, '2026-02-10 09:51:46'),
(234, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 5200.00 has been approved for Rs. 5200.00.', 1, 39, '2026-02-10 09:52:45'),
(235, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 1500.00 has been approved for Rs. 1500.00.', 1, 38, '2026-02-10 09:53:01'),
(236, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 71, '2026-02-10 10:10:42'),
(237, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 72, '2026-02-10 10:12:22'),
(238, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 5200.00 to your account.', 1, 73, '2026-02-10 10:12:54'),
(239, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 2500.00 to your account.', 1, 74, '2026-02-10 10:42:16'),
(240, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 5200.00 to your account.', 1, 75, '2026-02-10 10:46:29'),
(241, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 1500.00 to your account.', 1, 76, '2026-02-10 11:07:04'),
(242, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 1500.00 to your account.', 1, 77, '2026-02-10 11:07:43'),
(243, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"for client meeting venue\" for Rs. 1800.', 1, 54, '2026-02-10 11:15:12'),
(244, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for client meeting venue\" for Rs. 1800.00 has been approved.', 1, 54, '2026-02-10 11:15:55'),
(245, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1800.00 to your account.', 1, 78, '2026-02-10 11:40:27'),
(246, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1800.00 to your account.', 1, 79, '2026-02-10 11:42:23'),
(247, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"buy mouse\" for Rs. 500.', 1, 55, '2026-02-10 11:48:52'),
(248, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy mouse\" for Rs. 500.00 has been approved.', 1, 55, '2026-02-10 11:49:33'),
(249, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 500.00.', 1, 40, '2026-02-10 11:49:57'),
(250, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 500.00.', 1, 41, '2026-02-10 11:50:25'),
(251, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 500.00 has been approved for Rs. 500.00.', 1, 41, '2026-02-10 11:51:01'),
(252, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 500.00 to your account.', 1, 80, '2026-02-10 11:51:12'),
(253, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 500.00 to your account.', 1, 81, '2026-02-10 11:52:12'),
(254, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 500.00 to your account.', 1, 82, '2026-02-10 11:53:22'),
(255, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 500.00 to your account.', 1, 83, '2026-02-10 11:53:52'),
(256, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"abc\" for Rs. 25000.', 1, 56, '2026-02-10 14:22:11'),
(257, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"abc\" for Rs. 25000.00 has been approved.', 1, 56, '2026-02-10 14:23:59'),
(258, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 20000.00.', 1, 42, '2026-02-10 14:24:17'),
(259, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 20000.00 has been approved for Rs. 20000.00.', 1, 42, '2026-02-10 14:25:12'),
(260, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 15000.00 to your account.', 1, 84, '2026-02-10 14:25:24'),
(261, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 15000.00 to your account.', 1, 85, '2026-02-10 14:26:23'),
(262, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"dcd\" for Rs. 500.', 1, 57, '2026-02-11 06:28:43'),
(263, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"for wifi bill\" for Rs. 7000.', 1, 58, '2026-02-11 06:32:29'),
(264, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for wifi bill\" for Rs. 7000.00 has been approved.', 1, 58, '2026-02-11 06:34:19'),
(265, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 7000.00.', 1, 43, '2026-02-11 06:56:03'),
(266, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 7000.00 has been approved for Rs. 7000.00.', 1, 43, '2026-02-11 06:56:53'),
(267, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 7000.00 to your account.', 1, 86, '2026-02-11 06:57:13'),
(268, 1, 'FUND_CANCELLED', 'Test', 'Test Msg', 1, NULL, '2026-02-11 07:47:43'),
(269, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 7000.00 to your account.', 1, 98, '2026-02-11 09:24:03'),
(270, 20, 'EXPENSE_PENDING', 'New Expense for Approval', 'Deep Dantani has submitted an expense \"for watter bill\" for Rs. 1500.', 1, 59, '2026-02-11 10:41:06'),
(271, 19, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for watter bill\" for Rs. 1500.00 has been approved.', 1, 59, '2026-02-11 10:41:52'),
(272, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 1500.00.', 1, 57, '2026-02-11 10:42:01'),
(273, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'Neel Patel has requested an expansion fund of Rs. 1500.00.', 1, 58, '2026-02-11 10:43:33'),
(274, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'Neel Patel has submitted an expense \"for work anniversary gift \" for Rs. 500.', 1, 60, '2026-02-11 11:15:05'),
(275, 20, 'EXPANSION_REJECTED', 'Expansion Request Rejected', 'Your expansion request for Rs. 1500.00 has been rejected. Reason: its not worth it', 1, 58, '2026-02-11 11:18:17'),
(276, 20, 'EXPENSE_REJECTED', 'Expense Rejected', 'Your expense \"for work anniversary gift \" for Rs. 500.00 has been rejected. Reason: its not worth it', 1, 60, '2026-02-11 11:19:14'),
(277, 20, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"for work anniversary gift \" for Rs. 400.00 has been approved.', 1, 60, '2026-02-11 11:38:34'),
(278, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 400.00 to your account.', 1, 99, '2026-02-11 11:40:05'),
(279, 20, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 1500.00 has been approved for Rs. 1500.00.', 1, 58, '2026-02-11 12:02:05'),
(280, 20, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1500.00 to your account.', 1, 100, '2026-02-11 12:02:19'),
(281, 19, 'FUND_ALLOCATED', 'New Fund Allocation', 'Neel Patel has allocated Rs. 1500.00 to your account.', 1, 101, '2026-02-11 12:03:04'),
(282, 1, 'USER_REGISTERED', 'New User Registration', 'Romit Jani has registered as a USER and is pending approval.', 1, 22, '2026-02-11 12:14:40'),
(283, 22, 'ACCOUNT_STATUS', 'Account Approved', 'Your account has been approved by the CEO. You can now access your dashboard.', 0, 22, '2026-02-11 12:21:56'),
(284, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"Domain purchase\" for Rs. 500.', 1, 61, '2026-02-12 05:35:12'),
(285, 18, 'EXPENSE_PENDING', 'New Expense for Approval', 'Manav kheni has submitted an expense \"website hosting\" for Rs. 4000.', 1, 62, '2026-02-12 05:36:40'),
(286, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"buy new laptop\" for Rs. 40000.', 1, 63, '2026-02-12 05:38:46'),
(287, 1, 'EXPENSE_PENDING', 'New Manager Expense', 'kishan sharma has submitted an expense \"battery\" for Rs. 1200.', 1, 64, '2026-02-12 05:39:34'),
(288, 21, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"website hosting\" for Rs. 4000.00 has been approved.', 1, 62, '2026-02-12 05:39:59'),
(289, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 4000.00.', 1, 59, '2026-02-12 05:49:57'),
(290, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"battery\" for Rs. 1200.00 has been approved.', 1, 64, '2026-02-12 05:52:22'),
(291, 18, 'EXPENSE_REJECTED', 'Expense Rejected', 'Your expense \"buy new laptop\" for Rs. 40000.00 has been rejected. Reason: missing bill of purchase ', 1, 63, '2026-02-12 05:53:05'),
(292, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 1200.00 to your account.', 1, 102, '2026-02-12 06:00:33'),
(293, 18, 'EXPANSION_REJECTED', 'Expansion Request Rejected', 'Your expansion request for Rs. 4000.00 has been rejected. Reason: missing purchagee invoice 1 page', 1, 59, '2026-02-12 06:10:01'),
(294, 1, 'EXPANSION_REQUESTED', 'New Expansion Fund Request', 'kishan sharma has requested an expansion fund of Rs. 4000.00.', 1, 60, '2026-02-12 06:32:14'),
(295, 21, 'EXPENSE_REJECTED', 'Expense Rejected', 'Your expense \"Domain purchase\" for Rs. 500.00 has been rejected. Reason: amount is not mached to bill amount ', 1, 61, '2026-02-12 06:36:31'),
(296, 18, 'EXPANSION_APPROVED', 'Expansion Request Approved', 'Your expansion request for Rs. 4000.00 has been approved for Rs. 4000.00.', 1, 60, '2026-02-12 06:39:16'),
(297, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 4000.00 to your account.', 1, 103, '2026-02-12 06:40:05'),
(298, 18, 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense \"buy new laptop\" for Rs. 40000.00 has been approved.', 1, 63, '2026-02-12 06:42:09'),
(299, 18, 'FUND_ALLOCATED', 'New Fund Allocation', 'Milan Patel has allocated Rs. 40000.00 to your account.', 1, 104, '2026-02-12 06:42:46'),
(300, 21, 'FUND_ALLOCATED', 'New Fund Allocation', 'kishan sharma has allocated Rs. 4000.00 to your account.', 1, 105, '2026-02-12 06:44:00');

-- --------------------------------------------------------

--
-- Table structure for table `operational_funds`
--

CREATE TABLE `operational_funds` (
  `id` int(11) NOT NULL,
  `from_user_id` int(11) NOT NULL,
  `to_user_id` int(11) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `description` text DEFAULT NULL,
  `expansion_id` int(11) DEFAULT NULL,
  `payment_mode` enum('CASH','CHEQUE','UPI') DEFAULT NULL,
  `status` enum('PENDING','ALLOCATED','RECEIVED','COMPLETED','REJECTED') DEFAULT 'PENDING',
  `rejection_reason` text DEFAULT NULL,
  `allocated_at` timestamp NULL DEFAULT NULL,
  `received_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `cheque_number` varchar(50) DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `cheque_date` date DEFAULT NULL,
  `account_holder_name` varchar(255) DEFAULT NULL,
  `cheque_image_path` varchar(500) DEFAULT NULL,
  `upi_id` varchar(100) DEFAULT NULL,
  `transaction_id` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `operational_funds`
--

INSERT INTO `operational_funds` (`id`, `from_user_id`, `to_user_id`, `amount`, `description`, `expansion_id`, `payment_mode`, `status`, `rejection_reason`, `allocated_at`, `received_at`, `created_at`, `updated_at`, `cheque_number`, `bank_name`, `cheque_date`, `account_holder_name`, `cheque_image_path`, `upi_id`, `transaction_id`) VALUES
(57, 1, 20, 6000.00, 'Allocation for Expansion Request #23 - Expansion fund for approved expense: buy a Moniter (ID: 36)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-05 10:55:05', '2026-02-05 10:59:00', '2026-02-05 10:55:04', '2026-02-05 10:59:00', '2354862', 'HDFC Bank', '2026-02-05', 'Milan Patel', 'uploads/cheques/cheque-1770288904133-643637712.png', NULL, NULL),
(58, 1, 20, 800.00, 'Allocation for Expansion Request #22 - Expansion fund for approved expense: headohone  (ID: 37)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-05 10:57:58', '2026-02-05 10:58:51', '2026-02-05 10:57:58', '2026-02-05 10:58:51', '2354869', 'HDFC Bank', '2026-02-05', 'Milan Patel', 'uploads/cheques/cheque-1770289077994-989737917.png', NULL, NULL),
(59, 20, 19, 800.00, 'Allocation for Expansion Request #22 - Expansion fund for approved expense: headohone  (ID: 37)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-05 10:59:12', '2026-02-05 11:03:19', '2026-02-05 10:59:12', '2026-02-05 11:03:19', '2354869', 'HDFC Bank', '2026-02-04', 'Milan Patel', 'uploads/cheques/cheque-1770289077994-989737917.png', NULL, NULL),
(60, 20, 19, 6000.00, 'Allocation for Expansion Request #23 - Expansion fund for approved expense: buy a Moniter (ID: 36)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-05 10:59:39', '2026-02-05 11:03:14', '2026-02-05 10:59:39', '2026-02-05 11:03:14', '2354862', 'HDFC Bank', '2026-02-04', 'Milan Patel', 'uploads/cheques/cheque-1770288904133-643637712.png', NULL, NULL),
(61, 1, 20, 2000.00, 'Allocation for Expense #39 - dinner', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-05 11:20:34', '2026-02-05 11:22:24', '2026-02-05 11:20:34', '2026-02-05 11:22:24', NULL, NULL, NULL, NULL, NULL, 'milanpatel27@oksbi', 'PAYTMUPI7834561295'),
(62, 1, 20, 1500.00, 'Allocation for Expense #38 - client meeting', NULL, 'CASH', 'RECEIVED', NULL, '2026-02-05 11:21:19', '2026-02-05 11:22:12', '2026-02-05 11:21:19', '2026-02-05 11:22:12', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(63, 1, 20, 500.00, 'Allocation for Expansion Request #24 - Expansion fund for approved expense: buy water bottle (ID: 40)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-06 11:12:04', '2026-02-06 11:12:59', '2026-02-06 11:12:04', '2026-02-06 11:12:59', '2354869', 'SBI ', '2026-02-06', 'Milan Patel', 'uploads/cheques/cheque-1770376324324-901442479.png', NULL, NULL),
(64, 20, 19, 500.00, 'Allocation for Expansion Request #24 - Expansion fund for approved expense: buy water bottle (ID: 40)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-06 11:13:09', '2026-02-06 11:14:00', '2026-02-06 11:13:09', '2026-02-06 11:14:00', '2354869', 'SBI ', '2026-02-05', 'Milan Patel', 'uploads/cheques/cheque-1770376324324-901442479.png', NULL, NULL),
(65, 1, 18, 300.00, 'Allocation for Expansion Request #25 - Expansion fund for approved expense: buy A4 Size paper (ID: 42)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-09 10:44:45', '2026-02-09 10:45:14', '2026-02-09 10:44:45', '2026-02-09 10:45:14', '2354866', 'SBI ', '2026-02-09', 'Milan Patel', 'uploads/cheques/cheque-1770633885838-877498517.png', NULL, NULL),
(66, 18, 21, 300.00, 'Allocation for Expansion Request #25 - Expansion fund for approved expense: buy A4 Size paper (ID: 42)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-09 10:45:46', '2026-02-09 10:47:00', '2026-02-09 10:45:46', '2026-02-09 10:47:00', '2354866', 'SBI ', '2026-02-08', 'Milan Patel', 'uploads/cheques/cheque-1770633885838-877498517.png', NULL, NULL),
(67, 1, 18, 3000.00, 'Allocation for Expense #46 - sports day celebration', NULL, 'CASH', 'RECEIVED', NULL, '2026-02-10 06:03:31', '2026-02-10 06:08:38', '2026-02-10 06:03:31', '2026-02-10 06:08:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(72, 1, 18, 1500.00, 'Allocation for Expansion Request #38 - Expansion fund for approved expense: buy HDD (ID: 53)', 38, 'CHEQUE', 'RECEIVED', NULL, '2026-02-10 10:12:22', '2026-02-10 10:45:30', '2026-02-10 10:12:22', '2026-02-10 10:45:30', '2354455', 'BOB', '2026-02-10', 'Milan Patel', 'uploads/cheques/cheque-1770718342402-627089795.png', NULL, NULL),
(77, 18, 21, 1500.00, 'Allocation for Expansion Request #38 - Expansion fund for approved expense: buy HDD (ID: 53)', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-10 11:07:43', '2026-02-10 11:09:04', '2026-02-10 11:07:43', '2026-02-10 11:09:04', '2354455', 'BOB', '2026-02-09', 'Milan Patel', 'uploads/cheques/cheque-1770718342402-627089795.png', NULL, NULL),
(79, 1, 18, 1800.00, 'Allocation for Expense #54 - for client meeting venue', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-10 11:42:23', '2026-02-10 11:45:09', '2026-02-10 11:42:23', '2026-02-10 11:45:09', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@oksbi', 'PAYTMUPI7834561222'),
(81, 1, 20, 500.00, 'Allocation for Expansion Request #41 - Expansion fund for approved expense: buy mouse (ID: 55)', 41, 'UPI', 'RECEIVED', NULL, '2026-02-10 11:52:12', '2026-02-10 11:53:14', '2026-02-10 11:52:12', '2026-02-10 11:53:14', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@oksbi', 'PAYTMUPI7834561288'),
(83, 20, 19, 500.00, 'Allocation for Expansion Request #41 - Expansion fund for approved expense: buy mouse (ID: 55)', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-10 11:53:52', '2026-02-10 11:55:23', '2026-02-10 11:53:52', '2026-02-10 11:55:23', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@oksbi', 'PAYTMUPI7834561288'),
(86, 1, 18, 7000.00, 'Allocation for Expansion Request #43 - Expansion fund for approved expense: for wifi bill (ID: 58)', 43, 'CASH', 'RECEIVED', NULL, '2026-02-11 06:57:13', '2026-02-11 07:34:39', '2026-02-11 06:57:13', '2026-02-11 07:34:39', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(98, 18, 21, 7000.00, 'Allocation for Expansion Request #43 - Expansion fund for approved expense: for wifi bill (ID: 58)', NULL, 'CASH', 'RECEIVED', NULL, '2026-02-11 09:24:03', '2026-02-11 12:42:30', '2026-02-11 09:24:03', '2026-02-11 12:42:30', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(99, 1, 20, 400.00, 'Allocation for Expense #60 - for work anniversary gift ', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-11 11:40:04', '2026-02-11 11:40:56', '2026-02-11 11:40:04', '2026-02-11 11:40:56', NULL, NULL, NULL, NULL, NULL, 'milanpatel27@oksbi', 'PAYTMUPI7834561366'),
(100, 1, 20, 1500.00, 'Allocation for Expansion Request #58 - Expansion fund for approved expense: for watter bill (ID: 59)', 58, 'CASH', 'RECEIVED', NULL, '2026-02-11 12:02:19', '2026-02-11 12:02:56', '2026-02-11 12:02:19', '2026-02-11 12:02:56', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(101, 20, 19, 1500.00, 'Allocation for Expansion Request #58 - Expansion fund for approved expense: for watter bill (ID: 59)', NULL, 'CASH', 'RECEIVED', NULL, '2026-02-11 12:03:04', '2026-02-11 12:03:40', '2026-02-11 12:03:04', '2026-02-11 12:03:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(102, 1, 18, 1200.00, 'Allocation for Expense #64 - battery', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-12 06:00:33', '2026-02-12 06:14:05', '2026-02-12 06:00:32', '2026-02-12 06:14:05', '2354455', 'BOI', '2026-02-11', 'Milan Patel', 'uploads/cheques/cheque-1770876032584-797488466.png', NULL, NULL),
(103, 1, 18, 4000.00, 'Allocation for Expansion Request #60 - Expansion fund for approved expense: website hosting (ID: 62)', 60, 'UPI', 'RECEIVED', NULL, '2026-02-12 06:40:05', '2026-02-12 06:43:47', '2026-02-12 06:40:05', '2026-02-12 06:43:47', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@okboi', 'PAYTMUPI7834561320'),
(104, 1, 18, 40000.00, 'Allocation for Expense #63 - buy new laptop', NULL, 'CHEQUE', 'RECEIVED', NULL, '2026-02-12 06:42:46', '2026-02-12 06:43:41', '2026-02-12 06:42:46', '2026-02-12 06:43:41', '2354855', 'HDFC ', '2026-02-12', 'Milan Patel', 'uploads/cheques/cheque-1770878566022-254653550.png', NULL, NULL),
(105, 18, 21, 4000.00, 'Allocation for Expansion Request #60 - Expansion fund for approved expense: website hosting (ID: 62)', NULL, 'UPI', 'RECEIVED', NULL, '2026-02-12 06:44:00', '2026-02-12 06:44:33', '2026-02-12 06:44:00', '2026-02-12 06:44:33', NULL, NULL, NULL, NULL, NULL, 'milanpatel02@okboi', 'PAYTMUPI7834561320');

-- --------------------------------------------------------

--
-- Table structure for table `registration_otps`
--

CREATE TABLE `registration_otps` (
  `id` int(11) NOT NULL,
  `email` varchar(191) NOT NULL,
  `otp_code` varchar(10) DEFAULT NULL,
  `verification_token` varchar(255) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `registration_otps`
--

INSERT INTO `registration_otps` (`id`, `email`, `otp_code`, `verification_token`, `verified`, `expires_at`, `created_at`) VALUES
(2, '200525kishan@gmail.com', '946094', '6e4e88a2121996cac16d745bd9dc47131f2e551b970d77369ab166e22425766e', 1, '2026-02-04 18:39:09', '2026-02-04 12:59:09'),
(3, '200305deep@gmail.com', '616351', 'f3042e37e1008d2f8675df5fa8ea6a2613a7d0696e103f0b0b66c21e050f7b28', 1, '2026-02-05 10:39:43', '2026-02-05 04:59:43'),
(4, 'neel200402neel@gmail.com', '328139', NULL, 0, '2026-02-05 15:00:00', '2026-02-05 09:20:00'),
(5, '200402neel@gmail.com', '873653', '7ee9e2b529d9427c29affcf7edee4fd56bc56c37522a1e700ae4719e8f489f3d', 1, '2026-02-05 15:05:57', '2026-02-05 09:25:57'),
(6, '200203manav@gmail.com', '751801', 'efd46779ca589e88f639877aad5cfce53f0e7c0d72c52a9142b7ca797df4dbf5', 1, '2026-02-06 16:04:44', '2026-02-06 10:24:44'),
(7, 'romitjani03@gmail.com', '559713', 'd081f312570611436b4c10c0d23714bea16398990aa1679a02bfbe9328ae6676', 1, '2026-02-11 17:53:28', '2026-02-11 12:11:45');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `mobile_number` varchar(20) DEFAULT NULL,
  `role` enum('CEO','MANAGER','USER') NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','DEACTIVATED') NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `manager_id` int(11) DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_expires` datetime DEFAULT NULL,
  `otp_code` varchar(6) DEFAULT NULL,
  `otp_expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `full_name`, `mobile_number`, `role`, `status`, `created_at`, `updated_at`, `manager_id`, `profile_image`, `reset_password_token`, `reset_password_expires`, `otp_code`, `otp_expires_at`) VALUES
(1, '02milanp@gmail.com', '$2a$10$EqL3DimH9lqVDqY185T0serUX8AYINz6jdOZ1iPqVkIOfhHxA1pOK', 'Milan Patel', '9723585876', 'CEO', 'APPROVED', '2026-01-16 06:45:58', '2026-02-12 11:30:45', NULL, '/uploads/profiles/profile-1770891365846-664420197.webp', NULL, NULL, NULL, NULL),
(14, 'battingraja436@gmail.com', '$2a$10$3ley1u4fGJmYNIfS47cIFORDD/Wig7UrJcNtAdlvTjqs5HxlIoMOe', 'raja', '6524595872', 'USER', 'APPROVED', '2026-02-02 11:39:15', '2026-02-05 09:29:45', 20, NULL, NULL, NULL, NULL, NULL),
(18, '200525kishan@gmail.com', '$2a$10$lR4EvRKuRLDorgciVMGLxegyzQBKDqjPW5.bBpRAqtFYUq0WD3iHO', 'kishan sharma', '7865214561', 'MANAGER', 'APPROVED', '2026-02-04 13:01:02', '2026-02-12 10:17:06', NULL, NULL, NULL, NULL, NULL, NULL),
(19, '200305deep@gmail.com', '$2a$10$r15B.tTON0PnmhEq0WGCruh4dtbfprIWuAztdr8COcGsig6THP1UW', 'Deep Dantani', '7869214569', 'USER', 'APPROVED', '2026-02-05 05:01:59', '2026-02-12 10:31:13', 20, '/uploads/profiles/profile-1770892273590-926934662.webp', NULL, NULL, NULL, NULL),
(20, '200402neel@gmail.com', '$2a$10$mabjp4iX8NN.BPAHyYKSf.TlGuZ6pBsoVhTOlvI4HMmb1i8Ys91H2', 'Neel Patel', '7865214563', 'MANAGER', 'APPROVED', '2026-02-05 09:26:58', '2026-02-12 10:30:32', NULL, '/uploads/profiles/profile-1770892232270-178136670.webp', NULL, NULL, NULL, NULL),
(21, '200203manav@gmail.com', '$2a$10$Wm9nABFdaYuvdhYlDYKEs.qh69nV2zLklZyBAEMMC2DO.mcuR2N4y', 'Manav kheni', '9743585877', 'USER', 'APPROVED', '2026-02-06 10:26:02', '2026-02-06 11:56:14', 18, NULL, NULL, NULL, NULL, NULL),
(22, 'romitjani03@gmail.com', '$2a$10$btIvtLdVC2tocpd/7.gpoe1KNOt3iClRgcPmzYQ0.t/C3alzP4bhK', 'Romit Jani', '7723585876', 'USER', 'APPROVED', '2026-02-11 12:14:40', '2026-02-11 12:21:56', NULL, NULL, NULL, NULL, NULL, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `expansion_funds`
--
ALTER TABLE `expansion_funds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reviewed_by` (`reviewed_by`),
  ADD KEY `idx_manager` (`manager_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `expansion_fund_documents`
--
ALTER TABLE `expansion_fund_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_expansion_fund` (`expansion_fund_id`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_expense_date` (`expense_date`);

--
-- Indexes for table `expense_documents`
--
ALTER TABLE `expense_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_expense` (`expense_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_notif` (`user_id`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_created` (`created_at`);

--
-- Indexes for table `operational_funds`
--
ALTER TABLE `operational_funds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_from_user` (`from_user_id`),
  ADD KEY `idx_to_user` (`to_user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `fk_fund_expansion` (`expansion_id`);

--
-- Indexes for table `registration_otps`
--
ALTER TABLE `registration_otps`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_manager_id` (`manager_id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_status` (`status`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `expansion_funds`
--
ALTER TABLE `expansion_funds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `expansion_fund_documents`
--
ALTER TABLE `expansion_fund_documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `expense_documents`
--
ALTER TABLE `expense_documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=301;

--
-- AUTO_INCREMENT for table `operational_funds`
--
ALTER TABLE `operational_funds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=106;

--
-- AUTO_INCREMENT for table `registration_otps`
--
ALTER TABLE `registration_otps`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;
--
-- Database: `phpmyadmin`
--
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE `phpmyadmin`;

-- --------------------------------------------------------

--
-- Table structure for table `pma__bookmark`
--

CREATE TABLE `pma__bookmark` (
  `id` int(10) UNSIGNED NOT NULL,
  `dbase` varchar(255) NOT NULL DEFAULT '',
  `user` varchar(255) NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `query` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Bookmarks';

-- --------------------------------------------------------

--
-- Table structure for table `pma__central_columns`
--

CREATE TABLE `pma__central_columns` (
  `db_name` varchar(64) NOT NULL,
  `col_name` varchar(64) NOT NULL,
  `col_type` varchar(64) NOT NULL,
  `col_length` text DEFAULT NULL,
  `col_collation` varchar(64) NOT NULL,
  `col_isNull` tinyint(1) NOT NULL,
  `col_extra` varchar(255) DEFAULT '',
  `col_default` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Central list of columns';

-- --------------------------------------------------------

--
-- Table structure for table `pma__column_info`
--

CREATE TABLE `pma__column_info` (
  `id` int(5) UNSIGNED NOT NULL,
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `column_name` varchar(64) NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) NOT NULL DEFAULT '',
  `transformation_options` varchar(255) NOT NULL DEFAULT '',
  `input_transformation` varchar(255) NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Column information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__designer_settings`
--

CREATE TABLE `pma__designer_settings` (
  `username` varchar(64) NOT NULL,
  `settings_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Settings related to Designer';

-- --------------------------------------------------------

--
-- Table structure for table `pma__export_templates`
--

CREATE TABLE `pma__export_templates` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL,
  `export_type` varchar(10) NOT NULL,
  `template_name` varchar(64) NOT NULL,
  `template_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved export templates';

-- --------------------------------------------------------

--
-- Table structure for table `pma__favorite`
--

CREATE TABLE `pma__favorite` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Favorite tables';

-- --------------------------------------------------------

--
-- Table structure for table `pma__history`
--

CREATE TABLE `pma__history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db` varchar(64) NOT NULL DEFAULT '',
  `table` varchar(64) NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='SQL history for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__navigationhiding`
--

CREATE TABLE `pma__navigationhiding` (
  `username` varchar(64) NOT NULL,
  `item_name` varchar(64) NOT NULL,
  `item_type` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Hidden items of navigation tree';

-- --------------------------------------------------------

--
-- Table structure for table `pma__pdf_pages`
--

CREATE TABLE `pma__pdf_pages` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `page_nr` int(10) UNSIGNED NOT NULL,
  `page_descr` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='PDF relation pages for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__recent`
--

CREATE TABLE `pma__recent` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Recently accessed tables';

--
-- Dumping data for table `pma__recent`
--

INSERT INTO `pma__recent` (`username`, `tables`) VALUES
('root', '[{\"db\":\"expense_management\",\"table\":\"users\"},{\"db\":\"expense_management\",\"table\":\"expansion_funds\"},{\"db\":\"expense_management\",\"table\":\"registration_otps\"},{\"db\":\"expense_management\",\"table\":\"user_sessions\"},{\"db\":\"expense_management\",\"table\":\"operational_funds\"},{\"db\":\"expense_management\",\"table\":\"notifications\"},{\"db\":\"expense_management\",\"table\":\"expenses\"}]');

-- --------------------------------------------------------

--
-- Table structure for table `pma__relation`
--

CREATE TABLE `pma__relation` (
  `master_db` varchar(64) NOT NULL DEFAULT '',
  `master_table` varchar(64) NOT NULL DEFAULT '',
  `master_field` varchar(64) NOT NULL DEFAULT '',
  `foreign_db` varchar(64) NOT NULL DEFAULT '',
  `foreign_table` varchar(64) NOT NULL DEFAULT '',
  `foreign_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Relation table';

-- --------------------------------------------------------

--
-- Table structure for table `pma__savedsearches`
--

CREATE TABLE `pma__savedsearches` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `search_name` varchar(64) NOT NULL DEFAULT '',
  `search_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved searches';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_coords`
--

CREATE TABLE `pma__table_coords` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `pdf_page_number` int(11) NOT NULL DEFAULT 0,
  `x` float UNSIGNED NOT NULL DEFAULT 0,
  `y` float UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table coordinates for phpMyAdmin PDF output';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_info`
--

CREATE TABLE `pma__table_info` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `display_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_uiprefs`
--

CREATE TABLE `pma__table_uiprefs` (
  `username` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `prefs` text NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Tables'' UI preferences';

-- --------------------------------------------------------

--
-- Table structure for table `pma__tracking`
--

CREATE TABLE `pma__tracking` (
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `version` int(10) UNSIGNED NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text NOT NULL,
  `schema_sql` text DEFAULT NULL,
  `data_sql` longtext DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') DEFAULT NULL,
  `tracking_active` int(1) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Database changes tracking for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__userconfig`
--

CREATE TABLE `pma__userconfig` (
  `username` varchar(64) NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User preferences storage for phpMyAdmin';

--
-- Dumping data for table `pma__userconfig`
--

INSERT INTO `pma__userconfig` (`username`, `timevalue`, `config_data`) VALUES
('root', '2026-04-10 07:39:05', '{\"Console\\/Mode\":\"collapse\",\"lang\":\"en_GB\"}');

-- --------------------------------------------------------

--
-- Table structure for table `pma__usergroups`
--

CREATE TABLE `pma__usergroups` (
  `usergroup` varchar(64) NOT NULL,
  `tab` varchar(64) NOT NULL,
  `allowed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User groups with configured menu items';

-- --------------------------------------------------------

--
-- Table structure for table `pma__users`
--

CREATE TABLE `pma__users` (
  `username` varchar(64) NOT NULL,
  `usergroup` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Users and their assignments to user groups';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pma__central_columns`
--
ALTER TABLE `pma__central_columns`
  ADD PRIMARY KEY (`db_name`,`col_name`);

--
-- Indexes for table `pma__column_info`
--
ALTER TABLE `pma__column_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`);

--
-- Indexes for table `pma__designer_settings`
--
ALTER TABLE `pma__designer_settings`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`);

--
-- Indexes for table `pma__favorite`
--
ALTER TABLE `pma__favorite`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__history`
--
ALTER TABLE `pma__history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`,`db`,`table`,`timevalue`);

--
-- Indexes for table `pma__navigationhiding`
--
ALTER TABLE `pma__navigationhiding`
  ADD PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`);

--
-- Indexes for table `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  ADD PRIMARY KEY (`page_nr`),
  ADD KEY `db_name` (`db_name`);

--
-- Indexes for table `pma__recent`
--
ALTER TABLE `pma__recent`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__relation`
--
ALTER TABLE `pma__relation`
  ADD PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  ADD KEY `foreign_field` (`foreign_db`,`foreign_table`);

--
-- Indexes for table `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`);

--
-- Indexes for table `pma__table_coords`
--
ALTER TABLE `pma__table_coords`
  ADD PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`);

--
-- Indexes for table `pma__table_info`
--
ALTER TABLE `pma__table_info`
  ADD PRIMARY KEY (`db_name`,`table_name`);

--
-- Indexes for table `pma__table_uiprefs`
--
ALTER TABLE `pma__table_uiprefs`
  ADD PRIMARY KEY (`username`,`db_name`,`table_name`);

--
-- Indexes for table `pma__tracking`
--
ALTER TABLE `pma__tracking`
  ADD PRIMARY KEY (`db_name`,`table_name`,`version`);

--
-- Indexes for table `pma__userconfig`
--
ALTER TABLE `pma__userconfig`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__usergroups`
--
ALTER TABLE `pma__usergroups`
  ADD PRIMARY KEY (`usergroup`,`tab`,`allowed`);

--
-- Indexes for table `pma__users`
--
ALTER TABLE `pma__users`
  ADD PRIMARY KEY (`username`,`usergroup`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__column_info`
--
ALTER TABLE `pma__column_info`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__history`
--
ALTER TABLE `pma__history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  MODIFY `page_nr` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- Database: `test`
--
CREATE DATABASE IF NOT EXISTS `test` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `test`;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
