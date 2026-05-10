/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.16-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: aiagents
-- ------------------------------------------------------
-- Server version	10.11.16-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agent_contexts`
--

DROP TABLE IF EXISTS `agent_contexts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_contexts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL COMMENT 'One context row per tenant; refreshed each pipeline run',
  `pipeline_id` varchar(255) DEFAULT NULL,
  `signals` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Active signals produced by agents, e.g. ["low_stock_risk"]' CHECK (json_valid(`signals`)),
  `decisions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Decisions made across the pipeline run' CHECK (json_valid(`decisions`)),
  `actions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Actions dispatched during the pipeline run' CHECK (json_valid(`actions`)),
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Arbitrary key-value data shared between agents' CHECK (json_valid(`data`)),
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'Context TTL; stale contexts can be pruned by scheduler',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `agent_contexts_tenant_id_unique` (`tenant_id`),
  KEY `agent_contexts_tenant_id_index` (`tenant_id`),
  KEY `agent_contexts_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_contexts`
--

LOCK TABLES `agent_contexts` WRITE;
/*!40000 ALTER TABLE `agent_contexts` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_contexts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_execution_graph`
--

DROP TABLE IF EXISTS `agent_execution_graph`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_execution_graph` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_agent_code` varchar(255) NOT NULL COMMENT 'code of the upstream agent',
  `child_agent_code` varchar(255) NOT NULL COMMENT 'code of the downstream agent to trigger',
  `condition` varchar(255) DEFAULT NULL COMMENT 'Signal keyword required to trigger child, e.g. low_stock_risk',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `graph_unique_edge` (`parent_agent_code`,`child_agent_code`,`condition`),
  KEY `agent_execution_graph_parent_agent_code_index` (`parent_agent_code`),
  KEY `agent_execution_graph_child_agent_code_index` (`child_agent_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_execution_graph`
--

LOCK TABLES `agent_execution_graph` WRITE;
/*!40000 ALTER TABLE `agent_execution_graph` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_execution_graph` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_logs`
--

DROP TABLE IF EXISTS `agent_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `agent_type` varchar(255) NOT NULL,
  `intent` varchar(255) DEFAULT NULL,
  `customer_phone` varchar(30) DEFAULT NULL,
  `input_message` text DEFAULT NULL,
  `output_message` text DEFAULT NULL,
  `tools_called` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tools_called`)),
  `status` enum('success','failed','blocked') NOT NULL DEFAULT 'success',
  `block_reason` varchar(255) DEFAULT NULL,
  `duration_ms` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `agent_logs_tenant_id_agent_type_index` (`tenant_id`,`agent_type`),
  KEY `agent_logs_tenant_id_status_index` (`tenant_id`,`status`),
  CONSTRAINT `agent_logs_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_logs`
--

LOCK TABLES `agent_logs` WRITE;
/*!40000 ALTER TABLE `agent_logs` DISABLE KEYS */;
INSERT INTO `agent_logs` VALUES
(1,3,'pricing','scheduled_analysis','08056387738','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,4909,'2026-04-10 13:57:54','2026-04-10 13:57:54'),
(2,12,'task','scheduled_analysis','08014230487','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,7748,'2026-04-01 13:57:54','2026-04-01 13:57:54'),
(3,4,'revenue','scheduled_analysis','08052342460','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,1508,'2026-04-04 13:57:54','2026-04-04 13:57:54'),
(4,2,'churn','scheduled_analysis','08090698535','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,13271,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(5,13,'inventory','scheduled_analysis','08084449581','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,10299,'2026-04-05 13:57:54','2026-04-05 13:57:54'),
(6,2,'pricing','scheduled_analysis','08065644800','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,12922,'2026-03-31 13:57:54','2026-03-31 13:57:54'),
(7,4,'inventory','scheduled_analysis','08084784034','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,3766,'2026-04-13 13:57:54','2026-04-13 13:57:54'),
(8,11,'expiry','scheduled_analysis','08071487208','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,4231,'2026-04-08 13:57:54','2026-04-08 13:57:54'),
(9,13,'inventory','scheduled_analysis','08094719530','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,6858,'2026-04-03 13:57:54','2026-04-03 13:57:54'),
(10,13,'revenue','scheduled_analysis','08038854360','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,10858,'2026-03-31 13:57:54','2026-03-31 13:57:54'),
(11,10,'customer','scheduled_analysis','08081234819','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,11000,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(12,8,'customer','scheduled_analysis','08059246216','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,13969,'2026-04-12 13:57:54','2026-04-12 13:57:54'),
(13,3,'customer','scheduled_analysis','08082395717','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,3325,'2026-04-07 13:57:54','2026-04-07 13:57:54'),
(14,4,'inventory','scheduled_analysis','08059132097','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,1782,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(15,2,'task','scheduled_analysis','08091123111','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,6267,'2026-04-07 13:57:54','2026-04-07 13:57:54'),
(16,4,'revenue','scheduled_analysis','08067961571','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,4953,'2026-04-05 13:57:54','2026-04-05 13:57:54'),
(17,8,'revenue','scheduled_analysis','08028581890','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,2728,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(18,8,'expiry','scheduled_analysis','08047844775','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,12237,'2026-04-13 13:57:54','2026-04-13 13:57:54'),
(19,8,'inventory','scheduled_analysis','08075733735','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,14194,'2026-04-05 13:57:54','2026-04-05 13:57:54'),
(20,3,'customer','scheduled_analysis','08030495531','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,8789,'2026-04-05 13:57:54','2026-04-05 13:57:54'),
(21,3,'reorder','scheduled_analysis','08029716201','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,12551,'2026-04-04 13:57:54','2026-04-04 13:57:54'),
(22,10,'inventory','scheduled_analysis','08071679354','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,5943,'2026-04-12 13:57:54','2026-04-12 13:57:54'),
(23,5,'pricing','scheduled_analysis','08052567379','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,8743,'2026-04-03 13:57:54','2026-04-03 13:57:54'),
(24,9,'task','scheduled_analysis','08033412667','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,2784,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(25,8,'reorder','scheduled_analysis','08068977278','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,11429,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(26,12,'pricing','scheduled_analysis','08060915616','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,11704,'2026-04-12 13:57:54','2026-04-12 13:57:54'),
(27,12,'customer','scheduled_analysis','08019477164','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,14534,'2026-04-06 13:57:54','2026-04-06 13:57:54'),
(28,13,'churn','scheduled_analysis','08083092505','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,12752,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(29,10,'inventory','scheduled_analysis','08058912299','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,14508,'2026-04-02 13:57:54','2026-04-02 13:57:54'),
(30,5,'churn','scheduled_analysis','08016570600','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,7874,'2026-04-01 13:57:54','2026-04-01 13:57:54'),
(31,8,'expiry','scheduled_analysis','08023046339','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,13288,'2026-04-12 13:57:54','2026-04-12 13:57:54'),
(32,9,'pricing','scheduled_analysis','08069033592','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,6549,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(33,10,'customer','scheduled_analysis','08066167194','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,9983,'2026-04-03 13:57:54','2026-04-03 13:57:54'),
(34,12,'revenue','scheduled_analysis','08060787809','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,2008,'2026-04-10 13:57:54','2026-04-10 13:57:54'),
(35,13,'churn','scheduled_analysis','08018709823','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,1997,'2026-04-01 13:57:54','2026-04-01 13:57:54'),
(36,12,'revenue','scheduled_analysis','08042369457','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,7197,'2026-04-03 13:57:54','2026-04-03 13:57:54'),
(37,12,'expiry','scheduled_analysis','08013602780','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,2220,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(38,4,'task','scheduled_analysis','08045371014','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,5319,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(39,12,'task','scheduled_analysis','08039346395','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,9742,'2026-04-01 13:57:54','2026-04-01 13:57:54'),
(40,2,'churn','scheduled_analysis','08014576466','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,10511,'2026-04-03 13:57:54','2026-04-03 13:57:54'),
(41,2,'revenue','scheduled_analysis','08095088187','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,3898,'2026-04-08 13:57:54','2026-04-08 13:57:54'),
(42,6,'task','scheduled_analysis','08093275137','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,14687,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(43,11,'pricing','scheduled_analysis','08048932817','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,14742,'2026-04-02 13:57:54','2026-04-02 13:57:54'),
(44,8,'inventory','scheduled_analysis','08047198488','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,2644,'2026-04-10 13:57:54','2026-04-10 13:57:54'),
(45,13,'reorder','scheduled_analysis','08026181719','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,3765,'2026-04-06 13:57:54','2026-04-06 13:57:54'),
(46,7,'pricing','scheduled_analysis','08026789807','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,12777,'2026-04-04 13:57:54','2026-04-04 13:57:54'),
(47,11,'expiry','scheduled_analysis','08019373318','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,6382,'2026-04-13 13:57:54','2026-04-13 13:57:54'),
(48,11,'pricing','scheduled_analysis','08072369266','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,9374,'2026-04-05 13:57:54','2026-04-05 13:57:54'),
(49,10,'churn','scheduled_analysis','08044905059','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,10203,'2026-04-07 13:57:54','2026-04-07 13:57:54'),
(50,10,'revenue','scheduled_analysis','08084282078','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,708,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(51,9,'reorder','scheduled_analysis','08057949610','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,2214,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(52,9,'customer','scheduled_analysis','08034258578','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,10494,'2026-04-01 13:57:54','2026-04-01 13:57:54'),
(53,9,'customer','scheduled_analysis','08014618558','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,3142,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(54,12,'pricing','scheduled_analysis','08043453779','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,4696,'2026-03-31 13:57:54','2026-03-31 13:57:54'),
(55,5,'customer','scheduled_analysis','08059666940','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,955,'2026-04-10 13:57:54','2026-04-10 13:57:54'),
(56,10,'customer','scheduled_analysis','08012579078','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,6134,'2026-04-13 13:57:54','2026-04-13 13:57:54'),
(57,5,'reorder','scheduled_analysis','08025161040','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,5073,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(58,13,'task','scheduled_analysis','08032456678','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,1203,'2026-04-05 13:57:54','2026-04-05 13:57:54'),
(59,12,'revenue','scheduled_analysis','08084532991','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,13277,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(60,2,'pricing','scheduled_analysis','08044387103','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,1494,'2026-04-05 13:57:54','2026-04-05 13:57:54'),
(61,13,'pricing','scheduled_analysis','08036208008','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,749,'2026-04-04 13:57:54','2026-04-04 13:57:54'),
(62,12,'inventory','scheduled_analysis','08027690010','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,9569,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(63,5,'churn','scheduled_analysis','08065639769','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,12797,'2026-03-31 13:57:54','2026-03-31 13:57:54'),
(64,2,'revenue','scheduled_analysis','08053392743','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,9157,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(65,4,'customer','scheduled_analysis','08096666781','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,11575,'2026-04-07 13:57:54','2026-04-07 13:57:54'),
(66,10,'revenue','scheduled_analysis','08051528260','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,12110,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(67,13,'task','scheduled_analysis','08038332698','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,8794,'2026-04-01 13:57:54','2026-04-01 13:57:54'),
(68,12,'expiry','scheduled_analysis','08057517402','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,10267,'2026-04-07 13:57:54','2026-04-07 13:57:54'),
(69,4,'task','scheduled_analysis','08020441452','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,2598,'2026-04-01 13:57:54','2026-04-01 13:57:54'),
(70,13,'expiry','scheduled_analysis','08094815571','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,1948,'2026-04-10 13:57:54','2026-04-10 13:57:54'),
(71,12,'task','scheduled_analysis','08088027699','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,9245,'2026-04-03 13:57:54','2026-04-03 13:57:54'),
(72,10,'revenue','scheduled_analysis','08060050229','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,6056,'2026-04-08 13:57:54','2026-04-08 13:57:54'),
(73,5,'expiry','scheduled_analysis','08021098467','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,10080,'2026-04-01 13:57:54','2026-04-01 13:57:54'),
(74,7,'pricing','scheduled_analysis','08025246392','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,11876,'2026-04-06 13:57:54','2026-04-06 13:57:54'),
(75,2,'reorder','scheduled_analysis','08057899336','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,4664,'2026-04-10 13:57:54','2026-04-10 13:57:54'),
(76,6,'churn','scheduled_analysis','08058820260','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,7430,'2026-03-31 13:57:54','2026-03-31 13:57:54'),
(77,10,'churn','scheduled_analysis','08016007433','Run scheduled analysis','Agent timeout error','[\"get_inventory\",\"analyze_trends\"]','failed',NULL,9065,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(78,11,'task','scheduled_analysis','08051899757','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,4481,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(79,10,'churn','scheduled_analysis','08074502269','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,14727,'2026-04-08 13:57:54','2026-04-08 13:57:54'),
(80,13,'reorder','scheduled_analysis','08028692810','Run scheduled analysis','Analysis completed with 3 insights','[\"get_inventory\",\"analyze_trends\"]','success',NULL,3563,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(81,2,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":1,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":14580.66,\"sales_30_days\":14580.66},\"risks\":[\"Sales are down 100.0% versus the previous 7-day period.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"revenue\",\"action\":\"Sales are down 100.0% versus the previous 7-day period.\",\"target_agent\":\"inventory_agent\"},{\"priority\":\"medium\",\"impact\":\"revenue\",\"action\":\"Review price sensitivity on top sellers and test a focused promotion on slow-moving items.\",\"target_agent\":\"pricing_agent\"}],\"health_score\":{\"sales_health\":\"low\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"medium\",\"overall_score\":60}}','[\"inventory_agent\",\"pricing_agent\"]','success',NULL,NULL,'2026-04-27 16:48:01','2026-04-27 16:48:01'),
(82,2,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":1,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":14580.66,\"sales_30_days\":14580.66},\"risks\":[\"Sales are down 100.0% versus the previous 7-day period.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"revenue\",\"action\":\"Sales are down 100.0% versus the previous 7-day period.\",\"target_agent\":\"inventory_agent\"},{\"priority\":\"medium\",\"impact\":\"revenue\",\"action\":\"Review price sensitivity on top sellers and test a focused promotion on slow-moving items.\",\"target_agent\":\"pricing_agent\"}],\"health_score\":{\"sales_health\":\"low\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"medium\",\"overall_score\":60}}','[\"inventory_agent\",\"pricing_agent\"]','success',NULL,NULL,'2026-04-27 17:00:06','2026-04-27 17:00:06'),
(83,3,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":0,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":7,\"sales_30_days\":30},\"risks\":[],\"opportunities\":[],\"recommendations\":[],\"health_score\":{\"sales_health\":\"medium\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"low\",\"overall_score\":66}}','[]','success',NULL,NULL,'2026-04-27 17:00:07','2026-04-27 17:00:07'),
(84,4,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":2,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":5131.03,\"sales_30_days\":5131.03},\"risks\":[\"Sales are down 100.0% versus the previous 7-day period.\",\"Customer repeat rate fell by 50.0 percentage points over the last 30 days.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"customer\",\"action\":\"Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\",\"target_agent\":\"customer_agent\"},{\"priority\":\"medium\",\"impact\":\"revenue\",\"action\":\"Review price sensitivity on top sellers and test a focused promotion on slow-moving items.\",\"target_agent\":\"pricing_agent\"}],\"health_score\":{\"sales_health\":\"low\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"low\",\"overall_score\":44}}','[\"customer_agent\",\"pricing_agent\"]','success',NULL,NULL,'2026-04-27 17:00:09','2026-04-27 17:00:09'),
(85,5,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":1,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":7,\"sales_30_days\":30},\"risks\":[\"Customer repeat rate fell by 40.0 percentage points over the last 30 days.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"customer\",\"action\":\"Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\",\"target_agent\":\"customer_agent\"}],\"health_score\":{\"sales_health\":\"medium\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"low\",\"overall_score\":66}}','[\"customer_agent\"]','success',NULL,NULL,'2026-04-27 17:00:09','2026-04-27 17:00:09'),
(86,6,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":1,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":7,\"sales_30_days\":30},\"risks\":[\"Customer repeat rate fell by 75.0 percentage points over the last 30 days.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"customer\",\"action\":\"Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\",\"target_agent\":\"customer_agent\"}],\"health_score\":{\"sales_health\":\"medium\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"low\",\"overall_score\":66}}','[\"customer_agent\"]','success',NULL,NULL,'2026-04-27 17:00:10','2026-04-27 17:00:10'),
(87,7,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":1,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":7,\"sales_30_days\":30},\"risks\":[\"Customer repeat rate fell by 14.3 percentage points over the last 30 days.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"customer\",\"action\":\"Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\",\"target_agent\":\"customer_agent\"}],\"health_score\":{\"sales_health\":\"medium\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"low\",\"overall_score\":66}}','[\"customer_agent\"]','success',NULL,NULL,'2026-04-27 17:00:10','2026-04-27 17:00:10'),
(88,8,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":0,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":7,\"sales_30_days\":30},\"risks\":[],\"opportunities\":[],\"recommendations\":[],\"health_score\":{\"sales_health\":\"medium\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"low\",\"overall_score\":62}}','[]','success',NULL,NULL,'2026-04-27 17:00:10','2026-04-27 17:00:10'),
(89,10,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":1,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":7,\"sales_30_days\":30},\"risks\":[\"Customer repeat rate fell by 25.0 percentage points over the last 30 days.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"customer\",\"action\":\"Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\",\"target_agent\":\"customer_agent\"}],\"health_score\":{\"sales_health\":\"medium\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"low\",\"overall_score\":66}}','[\"customer_agent\"]','success',NULL,NULL,'2026-04-27 17:00:11','2026-04-27 17:00:11'),
(90,11,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":1,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":7,\"sales_30_days\":30},\"risks\":[\"Customer repeat rate fell by 20.0 percentage points over the last 30 days.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"customer\",\"action\":\"Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\",\"target_agent\":\"customer_agent\"}],\"health_score\":{\"sales_health\":\"medium\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"low\",\"overall_score\":66}}','[\"customer_agent\"]','success',NULL,NULL,'2026-04-27 17:00:11','2026-04-27 17:00:11'),
(91,12,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":1,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":31295.31,\"sales_30_days\":31295.31},\"risks\":[\"Sales are down 100.0% versus the previous 7-day period.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"revenue\",\"action\":\"Sales are down 100.0% versus the previous 7-day period.\",\"target_agent\":\"inventory_agent\"},{\"priority\":\"medium\",\"impact\":\"revenue\",\"action\":\"Review price sensitivity on top sellers and test a focused promotion on slow-moving items.\",\"target_agent\":\"pricing_agent\"}],\"health_score\":{\"sales_health\":\"low\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"high\",\"overall_score\":66}}','[\"inventory_agent\",\"pricing_agent\"]','success',NULL,NULL,'2026-04-27 17:00:12','2026-04-27 17:00:12'),
(92,13,'business_intelligence_agent','forecast_and_recommend',NULL,'{\"sales_trend_points\":2,\"risk_count\":1,\"opportunity_count\":0}','{\"forecast\":{\"sales_7_days\":7,\"sales_30_days\":30},\"risks\":[\"Customer repeat rate fell by 25.0 percentage points over the last 30 days.\"],\"opportunities\":[],\"recommendations\":[{\"priority\":\"high\",\"impact\":\"customer\",\"action\":\"Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\",\"target_agent\":\"customer_agent\"}],\"health_score\":{\"sales_health\":\"medium\",\"inventory_efficiency\":\"high\",\"customer_engagement\":\"low\",\"overall_score\":66}}','[\"customer_agent\"]','success',NULL,NULL,'2026-04-27 17:00:12','2026-04-27 17:00:12');
/*!40000 ALTER TABLE `agent_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agents`
--

DROP TABLE IF EXISTS `agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `service_class` varchar(255) DEFAULT NULL,
  `config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`config`)),
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `auto_execute` tinyint(1) NOT NULL DEFAULT 0,
  `trigger_event` varchar(255) DEFAULT NULL,
  `execution_interval` int(11) DEFAULT NULL,
  `last_executed_at` timestamp NULL DEFAULT NULL,
  `next_scheduled_at` timestamp NULL DEFAULT NULL,
  `success_count` int(11) NOT NULL DEFAULT 0,
  `error_count` int(11) NOT NULL DEFAULT 0,
  `last_error` text DEFAULT NULL,
  `trigger_type` enum('cron','event') NOT NULL,
  `schedule` varchar(255) DEFAULT NULL,
  `data_source` text DEFAULT NULL,
  `prompt_template` text DEFAULT NULL,
  `output_handler` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `agents_slug_unique` (`slug`),
  KEY `agents_tenant_id_foreign` (`tenant_id`),
  KEY `agents_type_index` (`type`),
  KEY `agents_enabled_index` (`enabled`),
  KEY `agents_last_executed_at_index` (`last_executed_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents`
--

LOCK TABLES `agents` WRITE;
/*!40000 ALTER TABLE `agents` DISABLE KEYS */;
INSERT INTO `agents` VALUES
(1,NULL,'Inventory Optimization','inventory-optimization','inventory','Monitors stock levels and triggers reorders','App\\AI\\Services\\InventoryOptimizationService','{\"threshold\":10,\"reorder_quantity\":50,\"safety_stock\":20}',1,1,'product.inventory.low',60,NULL,NULL,0,0,NULL,'cron',NULL,NULL,NULL,NULL,'2026-04-27 16:42:44','2026-04-27 16:42:44'),
(2,NULL,'Dead Stock','dead-stock','inventory','Identifies products with no sales in 90+ days','App\\AI\\Services\\DeadStockService','{\"inactive_days\":90,\"low_sales_threshold\":5}',1,1,'product.inventory.check',1440,NULL,NULL,0,0,NULL,'cron',NULL,NULL,NULL,NULL,'2026-04-27 16:42:44','2026-04-27 16:42:44'),
(3,NULL,'Dynamic Pricing','dynamic-pricing','pricing','Optimizes prices based on demand and competition','App\\AI\\Services\\DynamicPricingService','{\"min_margin\":0.15,\"max_margin\":0.5,\"competitor_impact\":0.5,\"demand_multiplier\":1.2}',1,1,'product.price.check',120,NULL,NULL,0,0,NULL,'cron',NULL,NULL,NULL,NULL,'2026-04-27 16:42:44','2026-04-27 16:42:44'),
(4,NULL,'WhatsApp Support','whatsapp-support','support','Handles customer inquiries via WhatsApp','App\\AI\\Services\\WhatsAppService','{\"api_key\":null,\"phone_id\":null}',1,0,'message.whatsapp.incoming',NULL,NULL,NULL,0,0,NULL,'cron',NULL,NULL,NULL,NULL,'2026-04-27 16:42:44','2026-04-27 16:42:44'),
(5,NULL,'Business Intelligence & Forecasting','business-intelligence-forecasting','analytics','Aggregates cross-agent metrics, generates forecasts, scores business health, and dispatches high-priority actions.','App\\Services\\BusinessIntelligenceService','{\"full_run_time\":\"06:30\",\"light_scan_interval_minutes\":60,\"channels\":[\"dashboard\",\"whatsapp\"]}',1,1,'schedule.business_intelligence.daily',60,NULL,NULL,0,0,NULL,'cron',NULL,NULL,NULL,NULL,'2026-04-27 16:42:45','2026-04-27 16:42:45');
/*!40000 ALTER TABLE `agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_agent_runs`
--

DROP TABLE IF EXISTS `ai_agent_runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_agent_runs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `agent_code` varchar(255) NOT NULL,
  `pipeline_id` varchar(255) DEFAULT NULL COMMENT 'Groups all agent runs belonging to a single orchestrator invocation',
  `status` enum('pending','running','completed','failed','skipped') NOT NULL DEFAULT 'pending',
  `trigger_event` varchar(255) DEFAULT NULL COMMENT 'The event that initiated this run, e.g. sale.created',
  `input_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`input_payload`)),
  `output_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`output_payload`)),
  `signals` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Extracted signals from agent output' CHECK (json_valid(`signals`)),
  `priority` tinyint(3) unsigned NOT NULL DEFAULT 50,
  `execution_time_ms` int(10) unsigned DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `executed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ai_agent_runs_tenant_id_agent_code_index` (`tenant_id`,`agent_code`),
  KEY `ai_agent_runs_tenant_id_pipeline_id_index` (`tenant_id`,`pipeline_id`),
  KEY `ai_agent_runs_status_index` (`status`),
  KEY `ai_agent_runs_created_at_index` (`created_at`),
  KEY `ai_agent_runs_tenant_id_index` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_agent_runs`
--

LOCK TABLES `ai_agent_runs` WRITE;
/*!40000 ALTER TABLE `ai_agent_runs` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_agent_runs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_agents`
--

DROP TABLE IF EXISTS `ai_agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_agents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT 'Unique machine key used in execution graph, e.g. inventory_agent',
  `priority` tinyint(3) unsigned NOT NULL DEFAULT 50 COMMENT 'Execution priority 1–100; lower runs first within graph tier',
  `execution_mode` enum('event','scheduled','manual','ai_triggered') NOT NULL DEFAULT 'manual',
  `is_critical` tinyint(1) NOT NULL DEFAULT 0,
  `type` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `service_class` varchar(255) NOT NULL,
  `config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`config`)),
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `auto_execute` tinyint(1) NOT NULL DEFAULT 0,
  `trigger_event` varchar(255) DEFAULT NULL,
  `execution_interval` int(11) DEFAULT NULL,
  `last_executed_at` timestamp NULL DEFAULT NULL,
  `next_scheduled_at` timestamp NULL DEFAULT NULL,
  `success_count` int(11) NOT NULL DEFAULT 0,
  `error_count` int(11) NOT NULL DEFAULT 0,
  `last_error` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ai_agents_name_unique` (`name`),
  UNIQUE KEY `ai_agents_slug_unique` (`slug`),
  UNIQUE KEY `ai_agents_code_unique` (`code`),
  KEY `ai_agents_type_index` (`type`),
  KEY `ai_agents_enabled_index` (`enabled`),
  KEY `ai_agents_last_executed_at_index` (`last_executed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_agents`
--

LOCK TABLES `ai_agents` WRITE;
/*!40000 ALTER TABLE `ai_agents` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_logs`
--

DROP TABLE IF EXISTS `ai_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned DEFAULT NULL,
  `endpoint` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `prompt_tokens` int(11) NOT NULL DEFAULT 0,
  `completion_tokens` int(11) NOT NULL DEFAULT 0,
  `total_tokens` int(11) NOT NULL DEFAULT 0,
  `latency_ms` int(11) NOT NULL DEFAULT 0,
  `status` enum('success','error','timeout') NOT NULL DEFAULT 'success',
  `error_message` text DEFAULT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ai_logs_tenant_id_created_at_index` (`tenant_id`,`created_at`),
  CONSTRAINT `ai_logs_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_logs`
--

LOCK TABLES `ai_logs` WRITE;
/*!40000 ALTER TABLE `ai_logs` DISABLE KEYS */;
INSERT INTO `ai_logs` VALUES
(1,7,'/api/generate','deepseek-r1',132,944,495,4972,'success',NULL,NULL,'2026-03-21 13:57:53','2026-03-21 13:57:53'),
(2,2,'/api/chat','mistral',79,707,417,4895,'success',NULL,NULL,'2026-04-05 13:57:53','2026-04-05 13:57:53'),
(3,7,'/api/chat','llama3.2',262,464,1781,4010,'success',NULL,NULL,'2026-04-10 13:57:53','2026-04-10 13:57:53'),
(4,8,'/api/analyze','llama3.2',137,540,1948,4197,'success',NULL,NULL,'2026-03-24 13:57:53','2026-03-24 13:57:53'),
(5,12,'/api/chat','llama3.2',212,1235,1647,1124,'success',NULL,NULL,'2026-03-29 13:57:53','2026-03-29 13:57:53'),
(6,5,'/api/generate','deepseek-r1',324,1239,1202,4968,'success',NULL,NULL,'2026-03-26 13:57:53','2026-03-26 13:57:53'),
(7,10,'/api/chat','llama3.2',304,1308,1034,4230,'success',NULL,NULL,'2026-04-05 13:57:53','2026-04-05 13:57:53'),
(8,8,'/api/generate','deepseek-r1',53,249,593,4303,'error','Model timeout',NULL,'2026-03-20 13:57:53','2026-03-20 13:57:53'),
(9,4,'/api/analyze','mistral',150,1349,1582,1579,'success',NULL,NULL,'2026-03-21 13:57:53','2026-03-21 13:57:53'),
(10,3,'/api/chat','deepseek-r1',445,1001,278,931,'success',NULL,NULL,'2026-03-27 13:57:53','2026-03-27 13:57:53'),
(11,2,'/api/chat','mistral',499,197,1505,428,'success',NULL,NULL,'2026-04-08 13:57:53','2026-04-08 13:57:53'),
(12,2,'/api/generate','deepseek-r1',157,475,1730,3398,'success',NULL,NULL,'2026-04-02 13:57:53','2026-04-02 13:57:53'),
(13,6,'/api/generate','llama3.2',300,766,760,3030,'success',NULL,NULL,'2026-04-11 13:57:53','2026-04-11 13:57:53'),
(14,2,'/api/analyze','llama3.2',261,349,1598,3388,'success',NULL,NULL,'2026-04-11 13:57:53','2026-04-11 13:57:53'),
(15,8,'/api/analyze','llama3.2',136,989,1362,534,'success',NULL,NULL,'2026-04-07 13:57:53','2026-04-07 13:57:53'),
(16,12,'/api/chat','deepseek-r1',54,468,1689,1560,'success',NULL,NULL,'2026-03-19 13:57:53','2026-03-19 13:57:53'),
(17,12,'/api/generate','llama3.2',330,1293,752,4155,'success',NULL,NULL,'2026-03-24 13:57:53','2026-03-24 13:57:53'),
(18,12,'/api/analyze','llama3.2',177,175,1781,1373,'success',NULL,NULL,'2026-04-09 13:57:53','2026-04-09 13:57:53'),
(19,4,'/api/generate','llama3.2',362,276,1603,1117,'success',NULL,NULL,'2026-04-14 13:57:53','2026-04-14 13:57:53'),
(20,9,'/api/generate','llama3.2',103,181,1544,2381,'success',NULL,NULL,'2026-03-22 13:57:53','2026-03-22 13:57:53'),
(21,4,'/api/chat','llama3.2',379,588,1187,1990,'success',NULL,NULL,'2026-03-24 13:57:53','2026-03-24 13:57:53'),
(22,3,'/api/generate','llama3.2',325,109,1803,3345,'error','Model timeout',NULL,'2026-03-16 13:57:53','2026-03-16 13:57:53'),
(23,8,'/api/generate','deepseek-r1',124,822,1395,2204,'success',NULL,NULL,'2026-03-25 13:57:53','2026-03-25 13:57:53'),
(24,3,'/api/generate','deepseek-r1',209,491,1991,453,'success',NULL,NULL,'2026-03-22 13:57:53','2026-03-22 13:57:53'),
(25,7,'/api/analyze','llama3.2',205,1145,512,4051,'error','Model timeout',NULL,'2026-04-12 13:57:53','2026-04-12 13:57:53'),
(26,9,'/api/generate','mistral',72,951,1016,4146,'success',NULL,NULL,'2026-03-30 13:57:53','2026-03-30 13:57:53'),
(27,12,'/api/analyze','deepseek-r1',74,799,1607,2868,'success',NULL,NULL,'2026-03-25 13:57:53','2026-03-25 13:57:53'),
(28,11,'/api/generate','deepseek-r1',214,600,1815,3311,'error','Model timeout',NULL,'2026-03-27 13:57:53','2026-03-27 13:57:53'),
(29,11,'/api/chat','llama3.2',311,1134,591,1793,'success',NULL,NULL,'2026-03-31 13:57:53','2026-03-31 13:57:53'),
(30,11,'/api/chat','mistral',204,104,1394,2529,'success',NULL,NULL,'2026-03-25 13:57:53','2026-03-25 13:57:53'),
(31,10,'/api/generate','mistral',130,360,501,1878,'success',NULL,NULL,'2026-03-22 13:57:53','2026-03-22 13:57:53'),
(32,2,'/api/generate','deepseek-r1',368,1188,377,2663,'success',NULL,NULL,'2026-03-20 13:57:53','2026-03-20 13:57:53'),
(33,6,'/api/generate','llama3.2',87,1123,1822,213,'success',NULL,NULL,'2026-04-06 13:57:53','2026-04-06 13:57:53'),
(34,11,'/api/generate','llama3.2',168,767,566,1201,'success',NULL,NULL,'2026-03-31 13:57:53','2026-03-31 13:57:53'),
(35,2,'/api/generate','deepseek-r1',154,1362,1059,2736,'success',NULL,NULL,'2026-03-25 13:57:53','2026-03-25 13:57:53'),
(36,8,'/api/chat','llama3.2',495,584,827,4666,'success',NULL,NULL,'2026-04-13 13:57:53','2026-04-13 13:57:53'),
(37,13,'/api/chat','llama3.2',62,605,796,4054,'success',NULL,NULL,'2026-03-31 13:57:53','2026-03-31 13:57:53'),
(38,8,'/api/chat','deepseek-r1',207,686,1703,715,'success',NULL,NULL,'2026-03-28 13:57:53','2026-03-28 13:57:53'),
(39,2,'/api/chat','deepseek-r1',192,176,488,4481,'success',NULL,NULL,'2026-03-23 13:57:53','2026-03-23 13:57:53'),
(40,7,'/api/generate','deepseek-r1',127,1433,1951,1578,'success',NULL,NULL,'2026-04-10 13:57:53','2026-04-10 13:57:53'),
(41,6,'/api/analyze','deepseek-r1',485,698,1978,3942,'success',NULL,NULL,'2026-03-21 13:57:53','2026-03-21 13:57:53'),
(42,6,'/api/analyze','mistral',355,977,1734,4150,'success',NULL,NULL,'2026-04-09 13:57:53','2026-04-09 13:57:53'),
(43,13,'/api/generate','deepseek-r1',246,1033,753,2701,'success',NULL,NULL,'2026-03-25 13:57:53','2026-03-25 13:57:53'),
(44,13,'/api/generate','deepseek-r1',382,427,1037,1631,'success',NULL,NULL,'2026-03-19 13:57:53','2026-03-19 13:57:53'),
(45,5,'/api/generate','mistral',181,1195,334,3574,'success',NULL,NULL,'2026-04-13 13:57:53','2026-04-13 13:57:53'),
(46,8,'/api/generate','llama3.2',258,301,674,2528,'success',NULL,NULL,'2026-04-11 13:57:53','2026-04-11 13:57:53'),
(47,11,'/api/generate','mistral',322,1254,1245,4263,'success',NULL,NULL,'2026-04-13 13:57:53','2026-04-13 13:57:53'),
(48,3,'/api/chat','deepseek-r1',302,270,1578,4968,'error','Model timeout',NULL,'2026-03-27 13:57:53','2026-03-27 13:57:53'),
(49,5,'/api/generate','deepseek-r1',299,1020,1841,4292,'success',NULL,NULL,'2026-03-23 13:57:53','2026-03-23 13:57:53'),
(50,6,'/api/chat','deepseek-r1',467,411,1324,225,'success',NULL,NULL,'2026-03-17 13:57:53','2026-03-17 13:57:53'),
(51,4,'/api/chat','deepseek-r1',238,885,1563,4829,'error','Model timeout',NULL,'2026-04-02 13:57:53','2026-04-02 13:57:53'),
(52,12,'/api/chat','mistral',399,872,446,4875,'success',NULL,NULL,'2026-04-06 13:57:53','2026-04-06 13:57:53'),
(53,2,'/api/generate','llama3.2',173,419,1495,2188,'success',NULL,NULL,'2026-03-19 13:57:53','2026-03-19 13:57:53'),
(54,8,'/api/generate','llama3.2',430,120,1935,2049,'success',NULL,NULL,'2026-03-26 13:57:53','2026-03-26 13:57:53'),
(55,3,'/api/chat','llama3.2',65,597,1305,3639,'success',NULL,NULL,'2026-04-06 13:57:53','2026-04-06 13:57:53'),
(56,10,'/api/analyze','mistral',458,1266,354,1462,'success',NULL,NULL,'2026-04-12 13:57:53','2026-04-12 13:57:53'),
(57,3,'/api/chat','mistral',82,187,1861,3304,'success',NULL,NULL,'2026-04-13 13:57:53','2026-04-13 13:57:53'),
(58,11,'/api/chat','mistral',72,849,1801,3833,'success',NULL,NULL,'2026-03-17 13:57:53','2026-03-17 13:57:53'),
(59,7,'/api/analyze','mistral',441,235,382,4774,'error','Model timeout',NULL,'2026-03-26 13:57:53','2026-03-26 13:57:53'),
(60,4,'/api/chat','llama3.2',283,1186,1080,3895,'error','Model timeout',NULL,'2026-03-27 13:57:53','2026-03-27 13:57:53'),
(61,7,'/api/analyze','llama3.2',203,180,1310,4431,'success',NULL,NULL,'2026-04-14 13:57:53','2026-04-14 13:57:53'),
(62,2,'/api/chat','llama3.2',445,224,643,3431,'success',NULL,NULL,'2026-04-06 13:57:53','2026-04-06 13:57:53'),
(63,11,'/api/generate','llama3.2',143,231,1647,559,'success',NULL,NULL,'2026-03-23 13:57:53','2026-03-23 13:57:53'),
(64,4,'/api/generate','mistral',287,1002,1669,3501,'success',NULL,NULL,'2026-03-19 13:57:53','2026-03-19 13:57:53'),
(65,2,'/api/generate','mistral',199,1099,1340,1962,'success',NULL,NULL,'2026-03-25 13:57:53','2026-03-25 13:57:53'),
(66,4,'/api/analyze','llama3.2',243,1252,875,3400,'success',NULL,NULL,'2026-03-22 13:57:53','2026-03-22 13:57:53'),
(67,6,'/api/chat','llama3.2',261,508,1119,1498,'success',NULL,NULL,'2026-03-26 13:57:53','2026-03-26 13:57:53'),
(68,3,'/api/generate','mistral',350,667,424,882,'success',NULL,NULL,'2026-04-12 13:57:53','2026-04-12 13:57:53'),
(69,12,'/api/chat','deepseek-r1',384,140,1537,2281,'success',NULL,NULL,'2026-04-01 13:57:53','2026-04-01 13:57:53'),
(70,3,'/api/analyze','llama3.2',445,252,1598,2783,'success',NULL,NULL,'2026-03-23 13:57:53','2026-03-23 13:57:53'),
(71,10,'/api/analyze','deepseek-r1',234,692,1545,3476,'success',NULL,NULL,'2026-04-07 13:57:53','2026-04-07 13:57:53'),
(72,12,'/api/analyze','llama3.2',210,536,918,1309,'error','Model timeout',NULL,'2026-03-22 13:57:53','2026-03-22 13:57:53'),
(73,9,'/api/analyze','llama3.2',183,1319,398,4050,'error','Model timeout',NULL,'2026-03-21 13:57:53','2026-03-21 13:57:53'),
(74,4,'/api/analyze','mistral',269,1274,1949,1222,'success',NULL,NULL,'2026-03-19 13:57:53','2026-03-19 13:57:53'),
(75,9,'/api/chat','deepseek-r1',398,729,1026,921,'success',NULL,NULL,'2026-03-26 13:57:53','2026-03-26 13:57:53'),
(76,9,'/api/generate','deepseek-r1',274,498,303,454,'success',NULL,NULL,'2026-04-10 13:57:53','2026-04-10 13:57:53'),
(77,13,'/api/chat','llama3.2',110,417,620,2012,'success',NULL,NULL,'2026-03-17 13:57:53','2026-03-17 13:57:53'),
(78,2,'/api/generate','llama3.2',101,943,412,3439,'success',NULL,NULL,'2026-04-02 13:57:53','2026-04-02 13:57:53'),
(79,3,'/api/analyze','deepseek-r1',156,1009,532,2288,'success',NULL,NULL,'2026-04-03 13:57:53','2026-04-03 13:57:53'),
(80,10,'/api/chat','llama3.2',383,874,1479,3417,'error','Model timeout',NULL,'2026-03-23 13:57:53','2026-03-23 13:57:53'),
(81,5,'/api/chat','deepseek-r1',338,589,1254,2842,'success',NULL,NULL,'2026-04-10 13:57:53','2026-04-10 13:57:53'),
(82,7,'/api/generate','deepseek-r1',157,771,376,315,'success',NULL,NULL,'2026-03-29 13:57:53','2026-03-29 13:57:53'),
(83,11,'/api/generate','mistral',288,339,1200,4554,'success',NULL,NULL,'2026-04-04 13:57:53','2026-04-04 13:57:53'),
(84,2,'/api/chat','mistral',88,999,494,3391,'success',NULL,NULL,'2026-04-02 13:57:53','2026-04-02 13:57:53'),
(85,7,'/api/chat','mistral',113,1088,1044,477,'success',NULL,NULL,'2026-03-19 13:57:53','2026-03-19 13:57:53'),
(86,11,'/api/analyze','mistral',96,1038,497,4474,'error','Model timeout',NULL,'2026-04-05 13:57:53','2026-04-05 13:57:53'),
(87,7,'/api/analyze','llama3.2',424,1425,344,4497,'error','Model timeout',NULL,'2026-03-24 13:57:53','2026-03-24 13:57:53'),
(88,7,'/api/generate','llama3.2',187,210,1060,4303,'success',NULL,NULL,'2026-03-18 13:57:53','2026-03-18 13:57:53'),
(89,13,'/api/generate','llama3.2',492,608,1897,1423,'success',NULL,NULL,'2026-04-12 13:57:53','2026-04-12 13:57:53'),
(90,7,'/api/analyze','deepseek-r1',143,316,563,2250,'success',NULL,NULL,'2026-03-22 13:57:53','2026-03-22 13:57:53'),
(91,11,'/api/chat','mistral',268,1392,604,901,'success',NULL,NULL,'2026-04-13 13:57:53','2026-04-13 13:57:53'),
(92,3,'/api/generate','mistral',265,267,1555,4501,'success',NULL,NULL,'2026-03-28 13:57:53','2026-03-28 13:57:53'),
(93,5,'/api/generate','mistral',368,1092,317,2034,'success',NULL,NULL,'2026-03-17 13:57:53','2026-03-17 13:57:53'),
(94,4,'/api/chat','llama3.2',315,211,810,4451,'success',NULL,NULL,'2026-04-08 13:57:53','2026-04-08 13:57:53'),
(95,13,'/api/generate','llama3.2',81,828,748,458,'success',NULL,NULL,'2026-03-28 13:57:53','2026-03-28 13:57:53'),
(96,12,'/api/chat','mistral',292,526,1105,2984,'success',NULL,NULL,'2026-04-13 13:57:53','2026-04-13 13:57:53'),
(97,11,'/api/analyze','llama3.2',319,993,307,3583,'success',NULL,NULL,'2026-04-02 13:57:53','2026-04-02 13:57:53'),
(98,6,'/api/analyze','mistral',279,263,247,1554,'success',NULL,NULL,'2026-03-17 13:57:54','2026-03-17 13:57:54'),
(99,6,'/api/chat','mistral',341,491,1287,765,'success',NULL,NULL,'2026-04-06 13:57:54','2026-04-06 13:57:54'),
(100,12,'/api/analyze','deepseek-r1',133,554,296,3031,'success',NULL,NULL,'2026-03-23 13:57:54','2026-03-23 13:57:54'),
(101,2,'/api/analyze','deepseek-r1',304,1193,1822,2524,'success',NULL,NULL,'2026-03-26 13:57:54','2026-03-26 13:57:54'),
(102,12,'/api/chat','deepseek-r1',259,515,1954,297,'error','Model timeout',NULL,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(103,11,'/api/analyze','deepseek-r1',458,190,1770,2580,'success',NULL,NULL,'2026-04-06 13:57:54','2026-04-06 13:57:54'),
(104,4,'/api/chat','deepseek-r1',106,738,1305,4141,'success',NULL,NULL,'2026-03-23 13:57:54','2026-03-23 13:57:54'),
(105,9,'/api/chat','deepseek-r1',85,1387,338,4062,'success',NULL,NULL,'2026-03-15 13:57:54','2026-03-15 13:57:54'),
(106,10,'/api/analyze','llama3.2',488,451,1188,1566,'success',NULL,NULL,'2026-03-21 13:57:54','2026-03-21 13:57:54'),
(107,4,'/api/analyze','deepseek-r1',436,502,1532,2693,'success',NULL,NULL,'2026-03-24 13:57:54','2026-03-24 13:57:54'),
(108,8,'/api/analyze','llama3.2',243,157,417,2123,'success',NULL,NULL,'2026-04-04 13:57:54','2026-04-04 13:57:54'),
(109,10,'/api/generate','llama3.2',56,984,788,314,'success',NULL,NULL,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(110,7,'/api/generate','mistral',499,410,926,2399,'success',NULL,NULL,'2026-04-02 13:57:54','2026-04-02 13:57:54'),
(111,12,'/api/analyze','mistral',101,348,205,474,'success',NULL,NULL,'2026-04-07 13:57:54','2026-04-07 13:57:54'),
(112,13,'/api/analyze','deepseek-r1',143,926,1729,4945,'success',NULL,NULL,'2026-04-08 13:57:54','2026-04-08 13:57:54'),
(113,4,'/api/chat','deepseek-r1',377,287,1761,2775,'success',NULL,NULL,'2026-04-04 13:57:54','2026-04-04 13:57:54'),
(114,8,'/api/generate','llama3.2',381,1020,686,3490,'success',NULL,NULL,'2026-03-27 13:57:54','2026-03-27 13:57:54'),
(115,13,'/api/chat','llama3.2',106,1261,1889,3457,'success',NULL,NULL,'2026-03-20 13:57:54','2026-03-20 13:57:54'),
(116,10,'/api/generate','llama3.2',444,672,513,1990,'success',NULL,NULL,'2026-04-12 13:57:54','2026-04-12 13:57:54'),
(117,5,'/api/generate','deepseek-r1',417,158,1169,1559,'success',NULL,NULL,'2026-03-24 13:57:54','2026-03-24 13:57:54'),
(118,6,'/api/analyze','mistral',92,121,452,1909,'error','Model timeout',NULL,'2026-04-02 13:57:54','2026-04-02 13:57:54'),
(119,5,'/api/generate','deepseek-r1',388,989,735,1618,'success',NULL,NULL,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(120,10,'/api/generate','deepseek-r1',330,1497,1825,3012,'success',NULL,NULL,'2026-04-05 13:57:54','2026-04-05 13:57:54'),
(121,13,'/api/generate','mistral',241,837,956,3311,'error','Model timeout',NULL,'2026-03-16 13:57:54','2026-03-16 13:57:54'),
(122,4,'/api/chat','mistral',347,1226,1888,3793,'error','Model timeout',NULL,'2026-04-13 13:57:54','2026-04-13 13:57:54'),
(123,8,'/api/analyze','mistral',439,1057,1619,385,'success',NULL,NULL,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(124,2,'/api/analyze','mistral',190,106,1721,357,'success',NULL,NULL,'2026-04-04 13:57:54','2026-04-04 13:57:54'),
(125,7,'/api/analyze','mistral',446,396,834,4219,'error','Model timeout',NULL,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(126,10,'/api/analyze','llama3.2',341,1252,314,2951,'success',NULL,NULL,'2026-03-20 13:57:54','2026-03-20 13:57:54'),
(127,8,'/api/analyze','llama3.2',172,438,921,1619,'success',NULL,NULL,'2026-04-12 13:57:54','2026-04-12 13:57:54'),
(128,7,'/api/analyze','deepseek-r1',444,1363,1466,918,'success',NULL,NULL,'2026-04-14 13:57:54','2026-04-14 13:57:54'),
(129,11,'/api/chat','llama3.2',297,253,380,2092,'error','Model timeout',NULL,'2026-04-07 13:57:54','2026-04-07 13:57:54'),
(130,8,'/api/generate','mistral',173,899,399,3390,'success',NULL,NULL,'2026-03-30 13:57:54','2026-03-30 13:57:54'),
(131,2,'/api/analyze','llama3.2',50,1406,380,2971,'success',NULL,NULL,'2026-03-22 13:57:54','2026-03-22 13:57:54'),
(132,12,'/api/chat','llama3.2',459,409,1112,949,'success',NULL,NULL,'2026-03-31 13:57:54','2026-03-31 13:57:54'),
(133,4,'/api/chat','deepseek-r1',272,896,640,4464,'success',NULL,NULL,'2026-03-17 13:57:54','2026-03-17 13:57:54'),
(134,5,'/api/generate','llama3.2',404,1421,1684,4160,'error','Model timeout',NULL,'2026-03-15 13:57:54','2026-03-15 13:57:54'),
(135,10,'/api/chat','llama3.2',299,219,1172,2214,'success',NULL,NULL,'2026-03-30 13:57:54','2026-03-30 13:57:54'),
(136,2,'/api/chat','llama3.2',494,1336,1808,4403,'success',NULL,NULL,'2026-04-13 13:57:54','2026-04-13 13:57:54'),
(137,8,'/api/chat','deepseek-r1',337,692,1590,576,'success',NULL,NULL,'2026-03-19 13:57:54','2026-03-19 13:57:54'),
(138,4,'/api/generate','llama3.2',283,908,808,1151,'success',NULL,NULL,'2026-03-28 13:57:54','2026-03-28 13:57:54'),
(139,8,'/api/generate','llama3.2',110,438,1912,3722,'success',NULL,NULL,'2026-04-09 13:57:54','2026-04-09 13:57:54'),
(140,4,'/api/analyze','deepseek-r1',476,1444,1575,285,'error','Model timeout',NULL,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(141,13,'/api/chat','llama3.2',462,1175,567,2535,'error','Model timeout',NULL,'2026-03-21 13:57:54','2026-03-21 13:57:54'),
(142,6,'/api/analyze','mistral',480,346,1994,353,'success',NULL,NULL,'2026-03-28 13:57:54','2026-03-28 13:57:54'),
(143,13,'/api/generate','deepseek-r1',457,582,1332,4423,'success',NULL,NULL,'2026-03-20 13:57:54','2026-03-20 13:57:54'),
(144,12,'/api/chat','llama3.2',196,1131,1715,4612,'success',NULL,NULL,'2026-04-06 13:57:54','2026-04-06 13:57:54'),
(145,2,'/api/generate','deepseek-r1',414,1277,942,3266,'success',NULL,NULL,'2026-03-26 13:57:54','2026-03-26 13:57:54'),
(146,9,'/api/analyze','llama3.2',196,407,330,1265,'success',NULL,NULL,'2026-03-27 13:57:54','2026-03-27 13:57:54'),
(147,7,'/api/generate','deepseek-r1',82,1406,1360,1399,'success',NULL,NULL,'2026-03-26 13:57:54','2026-03-26 13:57:54'),
(148,9,'/api/analyze','llama3.2',259,1238,1721,843,'success',NULL,NULL,'2026-03-18 13:57:54','2026-03-18 13:57:54'),
(149,2,'/api/generate','mistral',287,196,1827,444,'success',NULL,NULL,'2026-04-11 13:57:54','2026-04-11 13:57:54'),
(150,7,'/api/generate','llama3.2',316,1192,772,1868,'error','Model timeout',NULL,'2026-03-15 13:57:54','2026-03-15 13:57:54');
/*!40000 ALTER TABLE `ai_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_settings`
--

DROP TABLE IF EXISTS `ai_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `provider` varchar(255) NOT NULL DEFAULT 'vllm',
  `model` varchar(255) DEFAULT NULL,
  `base_url` varchar(255) DEFAULT NULL,
  `api_key` text DEFAULT NULL,
  `temperature` decimal(3,2) NOT NULL DEFAULT 0.30,
  `max_tokens` int(10) unsigned NOT NULL DEFAULT 512,
  `is_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `upsell_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `tone` enum('formal','casual','friendly') NOT NULL DEFAULT 'casual',
  `custom_prompt` text DEFAULT NULL,
  `language` varchar(255) NOT NULL DEFAULT 'en',
  `auto_reply_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `response_delay_seconds` int(11) NOT NULL DEFAULT 0,
  `blocked_keywords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`blocked_keywords`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ai_settings_tenant_id_unique` (`tenant_id`),
  CONSTRAINT `ai_settings_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_settings`
--

LOCK TABLES `ai_settings` WRITE;
/*!40000 ALTER TABLE `ai_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_rules`
--

DROP TABLE IF EXISTS `automation_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `automation_rules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` enum('reorder_reminder','inactivity_trigger','welcome','follow_up','upsell') NOT NULL DEFAULT 'inactivity_trigger',
  `is_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `conditions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`conditions`)),
  `actions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`actions`)),
  `trigger_after_days` int(11) NOT NULL DEFAULT 7,
  `last_run_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `automation_rules_tenant_id_is_enabled_index` (`tenant_id`,`is_enabled`),
  CONSTRAINT `automation_rules_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_rules`
--

LOCK TABLES `automation_rules` WRITE;
/*!40000 ALTER TABLE `automation_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `business_health_scores`
--

DROP TABLE IF EXISTS `business_health_scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `business_health_scores` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `sales_health` varchar(255) NOT NULL,
  `inventory_efficiency` varchar(255) NOT NULL,
  `customer_engagement` varchar(255) NOT NULL,
  `overall_score` smallint(5) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `business_health_scores_tenant_id_created_at_index` (`tenant_id`,`created_at`),
  CONSTRAINT `business_health_scores_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `business_health_scores`
--

LOCK TABLES `business_health_scores` WRITE;
/*!40000 ALTER TABLE `business_health_scores` DISABLE KEYS */;
INSERT INTO `business_health_scores` VALUES
(1,2,'low','high','medium',60,'2026-04-27 16:47:59','2026-04-27 16:47:59'),
(2,2,'low','high','medium',60,'2026-04-27 17:00:06','2026-04-27 17:00:06'),
(3,3,'medium','high','low',66,'2026-04-27 17:00:07','2026-04-27 17:00:07'),
(4,4,'low','high','low',44,'2026-04-27 17:00:08','2026-04-27 17:00:08'),
(5,5,'medium','high','low',66,'2026-04-27 17:00:09','2026-04-27 17:00:09'),
(6,6,'medium','high','low',66,'2026-04-27 17:00:10','2026-04-27 17:00:10'),
(7,7,'medium','high','low',66,'2026-04-27 17:00:10','2026-04-27 17:00:10'),
(8,8,'medium','high','low',62,'2026-04-27 17:00:10','2026-04-27 17:00:10'),
(9,10,'medium','high','low',66,'2026-04-27 17:00:11','2026-04-27 17:00:11'),
(10,11,'medium','high','low',66,'2026-04-27 17:00:11','2026-04-27 17:00:11'),
(11,12,'low','high','high',66,'2026-04-27 17:00:12','2026-04-27 17:00:12'),
(12,13,'medium','high','low',66,'2026-04-27 17:00:12','2026-04-27 17:00:12');
/*!40000 ALTER TABLE `business_health_scores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `business_insights`
--

DROP TABLE IF EXISTS `business_insights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `business_insights` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `insight_type` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `priority` varchar(255) NOT NULL DEFAULT 'medium',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `business_insights_tenant_id_insight_type_index` (`tenant_id`,`insight_type`),
  KEY `business_insights_tenant_id_priority_index` (`tenant_id`,`priority`),
  CONSTRAINT `business_insights_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `business_insights`
--

LOCK TABLES `business_insights` WRITE;
/*!40000 ALTER TABLE `business_insights` DISABLE KEYS */;
INSERT INTO `business_insights` VALUES
(1,2,'risk','Sales are down 100.0% versus the previous 7-day period.','high','2026-04-27 16:48:01','2026-04-27 16:48:01'),
(2,2,'recommendation','Sales are down 100.0% versus the previous 7-day period.','high','2026-04-27 16:48:01','2026-04-27 16:48:01'),
(3,2,'recommendation','Review price sensitivity on top sellers and test a focused promotion on slow-moving items.','medium','2026-04-27 16:48:01','2026-04-27 16:48:01'),
(4,2,'summary','📊 Business Insight (Today)\\nSales are down 100.0% versus the previous 7-day period.\n\nSales are down 100.0% versus the prior 7 days.\nTop risk: Sales are down 100.0% versus the previous 7-day period.\n\nRecommended:\n1. Sales are down 100.0% versus the previous 7-day period.\n2. Review price sensitivity on top sellers and test a focused promotion on slow-moving items.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 16:48:01','2026-04-27 16:48:01'),
(5,2,'risk','Sales are down 100.0% versus the previous 7-day period.','high','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(6,2,'recommendation','Sales are down 100.0% versus the previous 7-day period.','high','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(7,2,'recommendation','Review price sensitivity on top sellers and test a focused promotion on slow-moving items.','medium','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(8,2,'summary','📊 Business Insight (Today)\\nSales are down 100.0% versus the previous 7-day period.\n\nSales are down 100.0% versus the prior 7 days.\nTop risk: Sales are down 100.0% versus the previous 7-day period.\n\nRecommended:\n1. Sales are down 100.0% versus the previous 7-day period.\n2. Review price sensitivity on top sellers and test a focused promotion on slow-moving items.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(9,3,'summary','📊 Business Insight (Today)\\nStable trading signals detected.\n\nSales are up 0.0% versus the prior 7 days.\nTop risk: No critical risk detected.\n\nRecommended:\n1. Review dashboard details\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(10,4,'risk','Sales are down 100.0% versus the previous 7-day period.','high','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(11,4,'risk','Customer repeat rate fell by 50.0 percentage points over the last 30 days.','medium','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(12,4,'recommendation','Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.','high','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(13,4,'recommendation','Review price sensitivity on top sellers and test a focused promotion on slow-moving items.','medium','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(14,4,'summary','📊 Business Insight (Today)\\nSales are down 100.0% versus the previous 7-day period.\n\nSales are down 100.0% versus the prior 7 days.\nTop risk: Sales are down 100.0% versus the previous 7-day period.\n\nRecommended:\n1. Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\n2. Review price sensitivity on top sellers and test a focused promotion on slow-moving items.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(15,5,'risk','Customer repeat rate fell by 40.0 percentage points over the last 30 days.','medium','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(16,5,'recommendation','Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.','high','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(17,5,'summary','📊 Business Insight (Today)\\nCustomer repeat rate fell by 40.0 percentage points over the last 30 days.\n\nSales are up 0.0% versus the prior 7 days.\nTop risk: Customer repeat rate fell by 40.0 percentage points over the last 30 days.\n\nRecommended:\n1. Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(18,6,'risk','Customer repeat rate fell by 75.0 percentage points over the last 30 days.','medium','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(19,6,'recommendation','Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.','high','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(20,6,'summary','📊 Business Insight (Today)\\nCustomer repeat rate fell by 75.0 percentage points over the last 30 days.\n\nSales are up 0.0% versus the prior 7 days.\nTop risk: Customer repeat rate fell by 75.0 percentage points over the last 30 days.\n\nRecommended:\n1. Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(21,7,'risk','Customer repeat rate fell by 14.3 percentage points over the last 30 days.','medium','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(22,7,'recommendation','Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.','high','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(23,7,'summary','📊 Business Insight (Today)\\nCustomer repeat rate fell by 14.3 percentage points over the last 30 days.\n\nSales are up 0.0% versus the prior 7 days.\nTop risk: Customer repeat rate fell by 14.3 percentage points over the last 30 days.\n\nRecommended:\n1. Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(24,8,'summary','📊 Business Insight (Today)\\nStable trading signals detected.\n\nSales are up 0.0% versus the prior 7 days.\nTop risk: No critical risk detected.\n\nRecommended:\n1. Review dashboard details\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(25,10,'risk','Customer repeat rate fell by 25.0 percentage points over the last 30 days.','medium','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(26,10,'recommendation','Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.','high','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(27,10,'summary','📊 Business Insight (Today)\\nCustomer repeat rate fell by 25.0 percentage points over the last 30 days.\n\nSales are up 0.0% versus the prior 7 days.\nTop risk: Customer repeat rate fell by 25.0 percentage points over the last 30 days.\n\nRecommended:\n1. Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(28,11,'risk','Customer repeat rate fell by 20.0 percentage points over the last 30 days.','medium','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(29,11,'recommendation','Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.','high','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(30,11,'summary','📊 Business Insight (Today)\\nCustomer repeat rate fell by 20.0 percentage points over the last 30 days.\n\nSales are up 0.0% versus the prior 7 days.\nTop risk: Customer repeat rate fell by 20.0 percentage points over the last 30 days.\n\nRecommended:\n1. Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(31,12,'risk','Sales are down 100.0% versus the previous 7-day period.','high','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(32,12,'recommendation','Sales are down 100.0% versus the previous 7-day period.','high','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(33,12,'recommendation','Review price sensitivity on top sellers and test a focused promotion on slow-moving items.','medium','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(34,12,'summary','📊 Business Insight (Today)\\nSales are down 100.0% versus the previous 7-day period.\n\nSales are down 100.0% versus the prior 7 days.\nTop risk: Sales are down 100.0% versus the previous 7-day period.\n\nRecommended:\n1. Sales are down 100.0% versus the previous 7-day period.\n2. Review price sensitivity on top sellers and test a focused promotion on slow-moving items.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(35,13,'risk','Customer repeat rate fell by 25.0 percentage points over the last 30 days.','medium','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(36,13,'recommendation','Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.','high','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(37,13,'summary','📊 Business Insight (Today)\\nCustomer repeat rate fell by 25.0 percentage points over the last 30 days.\n\nSales are up 0.0% versus the prior 7 days.\nTop risk: Customer repeat rate fell by 25.0 percentage points over the last 30 days.\n\nRecommended:\n1. Launch a re-engagement campaign for recent one-time buyers and dormant repeat customers.\n\nReply:\n1 = Execute actions\n2 = Show details','medium','2026-04-27 17:00:12','2026-04-27 17:00:12');
/*!40000 ALTER TABLE `business_insights` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `customer_id` bigint(20) unsigned DEFAULT NULL,
  `whatsapp_account_id` bigint(20) unsigned DEFAULT NULL,
  `status` enum('open','closed','pending') NOT NULL DEFAULT 'open',
  `messages_count` int(11) NOT NULL DEFAULT 0,
  `last_message_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `conversations_customer_id_foreign` (`customer_id`),
  KEY `conversations_whatsapp_account_id_foreign` (`whatsapp_account_id`),
  KEY `conversations_tenant_id_status_index` (`tenant_id`,`status`),
  CONSTRAINT `conversations_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `conversations_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `conversations_whatsapp_account_id_foreign` FOREIGN KEY (`whatsapp_account_id`) REFERENCES `whatsapp_accounts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversations`
--

LOCK TABLES `conversations` WRITE;
/*!40000 ALTER TABLE `conversations` DISABLE KEYS */;
/*!40000 ALTER TABLE `conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `countries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `iso` char(2) NOT NULL,
  `name` varchar(80) NOT NULL,
  `nicename` varchar(80) NOT NULL,
  `iso3` char(3) DEFAULT NULL,
  `numcode` smallint(6) DEFAULT NULL,
  `phonecode` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `countries`
--

LOCK TABLES `countries` WRITE;
/*!40000 ALTER TABLE `countries` DISABLE KEYS */;
/*!40000 ALTER TABLE `countries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `currencies` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int(10) unsigned DEFAULT NULL,
  `currency_name` varchar(191) NOT NULL,
  `currency_symbol` varchar(191) DEFAULT NULL,
  `currency_code` varchar(191) NOT NULL,
  `exchange_rate` double DEFAULT NULL,
  `is_cryptocurrency` enum('yes','no') NOT NULL DEFAULT 'no',
  `usd_price` double DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currencies`
--

LOCK TABLES `currencies` WRITE;
/*!40000 ALTER TABLE `currencies` DISABLE KEYS */;
/*!40000 ALTER TABLE `currencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `whatsapp_id` varchar(255) DEFAULT NULL,
  `total_spent` decimal(12,2) NOT NULL DEFAULT 0.00,
  `orders_count` int(11) NOT NULL DEFAULT 0,
  `last_purchase_at` timestamp NULL DEFAULT NULL,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customers_tenant_id_index` (`tenant_id`),
  CONSTRAINT `customers_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES
(1,2,'Dr. Anais Green','08025746562','skye33@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-04-07 13:55:48','2026-04-14 13:55:48'),
(2,2,'Don Kemmer','08016124241','nmckenzie@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-01-19 13:55:48','2026-04-14 13:55:48'),
(3,2,'Amya Becker','08084684019','stefan12@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-01-30 13:55:48','2026-04-14 13:55:48'),
(4,2,'Sheila Bechtelar','08028722481','michele.wunsch@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-09 13:55:48','2026-04-14 13:55:48'),
(5,2,'Royal Champlin III','08087864858','zetta53@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-03-07 13:55:48','2026-04-14 13:55:48'),
(6,2,'Ms. Melisa Swaniawski I','08074887567','isabella.kuphal@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-28 13:55:48','2026-04-14 13:55:48'),
(7,2,'Darrel Pouros','08078951576','sabshire@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-28 13:55:48','2026-04-14 13:55:48'),
(8,2,'Judah Stroman PhD','08012106724','bailee60@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-26 13:55:48','2026-04-14 13:55:48'),
(9,2,'Miss Stacey Zulauf PhD','08057017810','kutch.mekhi@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-10 13:57:47','2026-04-14 13:57:47'),
(10,2,'Mrs. Selena Lesch Jr.','08097429886','lucinda60@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-01-20 13:57:47','2026-04-14 13:57:47'),
(11,2,'Kaitlyn Ratke','08054557133','fahey.dolores@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-08 13:57:47','2026-04-14 13:57:47'),
(12,2,'Dr. Judy Windler III','08031923674','fabiola.balistreri@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-28 13:57:47','2026-04-14 13:57:47'),
(13,2,'Astrid Rodriguez','08020992211','benton43@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-01-20 13:57:47','2026-04-14 13:57:47'),
(14,2,'Mrs. Lonie Mitchell III','08069889004','ayana08@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-01-15 13:57:47','2026-04-14 13:57:47'),
(15,3,'Dr. Xander Cummerata','08022184166','fnikolaus@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-01-31 13:57:48','2026-04-14 13:57:48'),
(16,3,'Mr. Darrel Herzog','08090829563','gwhite@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-04-03 13:57:48','2026-04-14 13:57:48'),
(17,3,'Hillard Altenwerth','08076503878','dhilpert@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-03 13:57:48','2026-04-14 13:57:48'),
(18,3,'Imani Zieme','08073483852','elda19@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-20 13:57:48','2026-04-14 13:57:48'),
(19,3,'Eino Rau','08044631172','harrison67@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-01-25 13:57:48','2026-04-14 13:57:48'),
(20,3,'Dr. Wiley Gulgowski','08030052552','nikita.howe@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-03-22 13:57:48','2026-04-14 13:57:48'),
(21,4,'Dr. Adonis Conn PhD','08060608210','leola.berge@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-19 13:57:48','2026-04-14 13:57:48'),
(22,4,'Nicolas Trantow','08061927008','smraz@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-06 13:57:48','2026-04-14 13:57:48'),
(23,4,'Ressie Littel','08011143166','bianka60@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-02-22 13:57:48','2026-04-14 13:57:48'),
(24,4,'Garret Murray','08099898099','abbie.paucek@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-02-25 13:57:48','2026-04-14 13:57:48'),
(25,4,'Mr. Kurtis Watsica IV','08011681074','dmckenzie@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-15 13:57:48','2026-04-14 13:57:48'),
(26,4,'Saul Mills','08064783162','upton.joesph@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-11 13:57:48','2026-04-14 13:57:48'),
(27,4,'Warren Swaniawski Jr.','08015844758','rdenesik@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-04-06 13:57:48','2026-04-14 13:57:48'),
(28,4,'Geo Harris MD','08019193466','eugene.brakus@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-02-22 13:57:48','2026-04-14 13:57:48'),
(29,4,'Viva Lakin','08032010589','jada63@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-28 13:57:48','2026-04-14 13:57:48'),
(30,4,'Miss Myrtie Hettinger DVM','08056268692','jewell89@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-04-08 13:57:48','2026-04-14 13:57:48'),
(31,5,'Marquis Emmerich','08035775093','viviane.mcclure@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-04-05 13:57:48','2026-04-14 13:57:48'),
(32,5,'Prof. Asha Stehr IV','08055701473','monte11@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-26 13:57:48','2026-04-14 13:57:48'),
(33,5,'Mr. Roger Sawayn','08015878347','joesph97@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-01-21 13:57:48','2026-04-14 13:57:48'),
(34,5,'Rahul Romaguera','08025258271','armstrong.raleigh@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-28 13:57:48','2026-04-14 13:57:48'),
(35,5,'Ludwig Gutmann','08065809626','robbie52@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-01-24 13:57:48','2026-04-14 13:57:48'),
(36,5,'Arely Ritchie','08059486293','felton.mclaughlin@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-02-16 13:57:48','2026-04-14 13:57:48'),
(37,6,'Miss Velda Ziemann','08041246060','eliane.wiegand@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-13 13:57:49','2026-04-14 13:57:49'),
(38,6,'Amya Beer MD','08034630219','jdibbert@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-20 13:57:49','2026-04-14 13:57:49'),
(39,6,'Adele Wiza','08062389363','jaufderhar@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-21 13:57:49','2026-04-14 13:57:49'),
(40,6,'Soledad Koepp','08083295628','kassulke.viola@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-17 13:57:49','2026-04-14 13:57:49'),
(41,6,'Felicita Kuvalis','08030374183','murazik.mozell@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-01-26 13:57:49','2026-04-14 13:57:49'),
(42,6,'Reed Kunde','08038569700','vita22@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-02-06 13:57:49','2026-04-14 13:57:49'),
(43,6,'Alvera Adams','08052767504','gerry.turcotte@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-04-08 13:57:49','2026-04-14 13:57:49'),
(44,6,'Scotty Hackett II','08024180599','mwuckert@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-04 13:57:49','2026-04-14 13:57:49'),
(45,6,'Micah Hane','08075256578','yesenia.adams@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-04-01 13:57:49','2026-04-14 13:57:49'),
(46,7,'Horacio Brakus','08024823933','abbie93@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-03 13:57:49','2026-04-14 13:57:49'),
(47,7,'Jacques Nienow MD','08070880766','jerde.kiley@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-23 13:57:49','2026-04-14 13:57:49'),
(48,7,'Felicita Bartoletti','08085607881','hbecker@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-22 13:57:49','2026-04-14 13:57:49'),
(49,7,'Prof. Idell Grimes','08053361385','may63@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-25 13:57:49','2026-04-14 13:57:49'),
(50,7,'Prof. Elroy Cole Jr.','08075714856','roberta05@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-01-30 13:57:49','2026-04-14 13:57:49'),
(51,7,'Mrs. Jannie Pouros','08092818932','maximilian.sanford@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-04 13:57:49','2026-04-14 13:57:49'),
(52,7,'Miss Nikki Kris','08031634029','nikolas32@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-05 13:57:49','2026-04-14 13:57:49'),
(53,7,'Clint Emard','08023561028','wkulas@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-01-27 13:57:49','2026-04-14 13:57:49'),
(54,7,'Mr. Fred Gutmann DDS','08046784669','king.maude@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-01-16 13:57:49','2026-04-14 13:57:49'),
(55,7,'Tiffany Lind','08025523258','aufderhar.rosetta@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-12 13:57:49','2026-04-14 13:57:49'),
(56,8,'Leatha Buckridge','08019202544','nora82@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-04 13:57:50','2026-04-14 13:57:50'),
(57,8,'Ava Hills','08061545517','ashton93@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-03-30 13:57:50','2026-04-14 13:57:50'),
(58,8,'Miller Leannon','08079512542','harber.raquel@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-01-16 13:57:50','2026-04-14 13:57:50'),
(59,8,'Prof. Jett Nikolaus','08080572533','rjohns@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-30 13:57:50','2026-04-14 13:57:50'),
(60,8,'Precious Toy DDS','08011980581','egibson@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-04-04 13:57:50','2026-04-14 13:57:50'),
(61,8,'Prof. Ricky Leffler','08022703936','aliya29@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-09 13:57:50','2026-04-14 13:57:50'),
(62,9,'Dr. Granville Veum','08071452626','zelda18@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-03-11 13:57:50','2026-04-14 13:57:50'),
(63,9,'Rose McCullough','08095030763','aleen83@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-20 13:57:50','2026-04-14 13:57:50'),
(64,9,'Prof. Joseph Reynolds','08035056401','wokon@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-24 13:57:51','2026-04-14 13:57:51'),
(65,9,'Katrina Ullrich','08053541862','bessie.murray@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-25 13:57:51','2026-04-14 13:57:51'),
(66,9,'Carolyn Casper','08037949826','reyna53@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-04 13:57:51','2026-04-14 13:57:51'),
(67,9,'Brad O\'Keefe','08051758489','aliza.harris@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-19 13:57:51','2026-04-14 13:57:51'),
(68,9,'Rachael Gottlieb MD','08043591197','cole.everardo@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-03-27 13:57:51','2026-04-14 13:57:51'),
(69,10,'Karl Mann','08082913446','donna.shanahan@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-12 13:57:51','2026-04-14 13:57:51'),
(70,10,'Mr. Amari Pacocha','08031895224','lwilderman@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-02-11 13:57:51','2026-04-14 13:57:51'),
(71,10,'Sadye Batz','08011913414','ilene57@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-02-14 13:57:51','2026-04-14 13:57:51'),
(72,10,'Layla Murray','08052696254','bruen.chauncey@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-01-21 13:57:51','2026-04-14 13:57:51'),
(73,10,'Natalie Towne','08067245200','ajacobs@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-03 13:57:51','2026-04-14 13:57:51'),
(74,10,'Hilma Davis IV','08068039032','kub.donavon@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-09 13:57:51','2026-04-14 13:57:51'),
(75,10,'Mrs. Selina Brakus III','08047627028','howell.aniyah@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-02-11 13:57:51','2026-04-14 13:57:51'),
(76,11,'Garth Mann','08044505854','adrain78@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-04-03 13:57:52','2026-04-14 13:57:52'),
(77,11,'Reece Herzog','08050389391','annamarie.kerluke@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-23 13:57:52','2026-04-14 13:57:52'),
(78,11,'Prof. Norwood Haley','08066121623','maida48@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-26 13:57:52','2026-04-14 13:57:52'),
(79,11,'Prof. Everett Senger IV','08068547423','felicita57@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-18 13:57:52','2026-04-14 13:57:52'),
(80,11,'Oleta Kunze Sr.','08021922716','tlockman@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-23 13:57:52','2026-04-14 13:57:52'),
(81,11,'Martin Rau','08066886848','ssawayn@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-03-16 13:57:52','2026-04-14 13:57:52'),
(82,11,'Jennifer Beahan','08084754062','turner.hansen@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-02-01 13:57:52','2026-04-14 13:57:52'),
(83,12,'Randi Franecki','08030164736','bsimonis@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-02-09 13:57:52','2026-04-14 13:57:52'),
(84,12,'Dr. Emile Jacobson MD','08055541864','reilly.ava@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-04-01 13:57:52','2026-04-14 13:57:52'),
(85,12,'Eldora Brakus','08061692901','andreane64@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-01-30 13:57:52','2026-04-14 13:57:52'),
(86,12,'Dr. Verlie Blick','08094386638','wuckert.alek@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-04-11 13:57:52','2026-04-14 13:57:52'),
(87,12,'Cassie Greenholt','08063156959','jgerlach@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-25 13:57:52','2026-04-14 13:57:52'),
(88,12,'Hipolito Purdy','08041507202','darien.nitzsche@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-04-12 13:57:52','2026-04-14 13:57:52'),
(89,12,'Lorenza Kreiger','08095922988','trever.abernathy@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-23 13:57:52','2026-04-14 13:57:52'),
(90,12,'Rosalinda Brown','08035178365','trevor68@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-01-26 13:57:52','2026-04-14 13:57:52'),
(91,13,'Myriam Nader','08072633961','katrina32@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-17 13:57:53','2026-04-14 13:57:53'),
(92,13,'Anibal Walter','08027582454','garfield43@example.com',NULL,0.00,0,NULL,NULL,NULL,'2026-03-29 13:57:53','2026-04-14 13:57:53'),
(93,13,'Miss Arlie Schumm','08071888123','lynch.sasha@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-01-21 13:57:53','2026-04-14 13:57:53'),
(94,13,'Eloisa Frami Jr.','08028381536','winifred15@example.org',NULL,0.00,0,NULL,NULL,NULL,'2026-03-05 13:57:53','2026-04-14 13:57:53'),
(95,13,'Favian Prosacco','08032704967','zmertz@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-03-07 13:57:53','2026-04-14 13:57:53'),
(96,13,'Prof. Edward Walker MD','08043306068','flatley.bernadette@example.net',NULL,0.00,0,NULL,NULL,NULL,'2026-02-25 13:57:53','2026-04-14 13:57:53');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forecasts`
--

DROP TABLE IF EXISTS `forecasts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `forecasts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `metric` varchar(255) NOT NULL,
  `value` decimal(14,2) NOT NULL,
  `forecast_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `forecasts_tenant_id_metric_index` (`tenant_id`,`metric`),
  KEY `forecasts_tenant_id_forecast_date_index` (`tenant_id`,`forecast_date`),
  CONSTRAINT `forecasts_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=721 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forecasts`
--

LOCK TABLES `forecasts` WRITE;
/*!40000 ALTER TABLE `forecasts` DISABLE KEYS */;
INSERT INTO `forecasts` VALUES
(61,2,'sales',13917.90,'2026-04-28','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(62,2,'revenue',13917.90,'2026-04-28','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(63,2,'sales',662.76,'2026-04-29','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(64,2,'revenue',662.76,'2026-04-29','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(65,2,'sales',0.00,'2026-04-30','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(66,2,'revenue',0.00,'2026-04-30','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(67,2,'sales',0.00,'2026-05-01','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(68,2,'revenue',0.00,'2026-05-01','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(69,2,'sales',0.00,'2026-05-02','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(70,2,'revenue',0.00,'2026-05-02','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(71,2,'sales',0.00,'2026-05-03','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(72,2,'revenue',0.00,'2026-05-03','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(73,2,'sales',0.00,'2026-05-04','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(74,2,'revenue',0.00,'2026-05-04','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(75,2,'sales',0.00,'2026-05-05','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(76,2,'revenue',0.00,'2026-05-05','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(77,2,'sales',0.00,'2026-05-06','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(78,2,'revenue',0.00,'2026-05-06','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(79,2,'sales',0.00,'2026-05-07','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(80,2,'revenue',0.00,'2026-05-07','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(81,2,'sales',0.00,'2026-05-08','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(82,2,'revenue',0.00,'2026-05-08','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(83,2,'sales',0.00,'2026-05-09','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(84,2,'revenue',0.00,'2026-05-09','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(85,2,'sales',0.00,'2026-05-10','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(86,2,'revenue',0.00,'2026-05-10','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(87,2,'sales',0.00,'2026-05-11','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(88,2,'revenue',0.00,'2026-05-11','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(89,2,'sales',0.00,'2026-05-12','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(90,2,'revenue',0.00,'2026-05-12','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(91,2,'sales',0.00,'2026-05-13','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(92,2,'revenue',0.00,'2026-05-13','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(93,2,'sales',0.00,'2026-05-14','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(94,2,'revenue',0.00,'2026-05-14','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(95,2,'sales',0.00,'2026-05-15','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(96,2,'revenue',0.00,'2026-05-15','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(97,2,'sales',0.00,'2026-05-16','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(98,2,'revenue',0.00,'2026-05-16','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(99,2,'sales',0.00,'2026-05-17','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(100,2,'revenue',0.00,'2026-05-17','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(101,2,'sales',0.00,'2026-05-18','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(102,2,'revenue',0.00,'2026-05-18','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(103,2,'sales',0.00,'2026-05-19','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(104,2,'revenue',0.00,'2026-05-19','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(105,2,'sales',0.00,'2026-05-20','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(106,2,'revenue',0.00,'2026-05-20','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(107,2,'sales',0.00,'2026-05-21','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(108,2,'revenue',0.00,'2026-05-21','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(109,2,'sales',0.00,'2026-05-22','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(110,2,'revenue',0.00,'2026-05-22','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(111,2,'sales',0.00,'2026-05-23','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(112,2,'revenue',0.00,'2026-05-23','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(113,2,'sales',0.00,'2026-05-24','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(114,2,'revenue',0.00,'2026-05-24','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(115,2,'sales',0.00,'2026-05-25','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(116,2,'revenue',0.00,'2026-05-25','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(117,2,'sales',0.00,'2026-05-26','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(118,2,'revenue',0.00,'2026-05-26','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(119,2,'sales',0.00,'2026-05-27','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(120,2,'revenue',0.00,'2026-05-27','2026-04-27 17:00:06','2026-04-27 17:00:06'),
(121,3,'sales',1.00,'2026-04-28','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(122,3,'revenue',1.00,'2026-04-28','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(123,3,'sales',1.00,'2026-04-29','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(124,3,'revenue',1.00,'2026-04-29','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(125,3,'sales',1.00,'2026-04-30','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(126,3,'revenue',1.00,'2026-04-30','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(127,3,'sales',1.00,'2026-05-01','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(128,3,'revenue',1.00,'2026-05-01','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(129,3,'sales',1.00,'2026-05-02','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(130,3,'revenue',1.00,'2026-05-02','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(131,3,'sales',1.00,'2026-05-03','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(132,3,'revenue',1.00,'2026-05-03','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(133,3,'sales',1.00,'2026-05-04','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(134,3,'revenue',1.00,'2026-05-04','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(135,3,'sales',1.00,'2026-05-05','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(136,3,'revenue',1.00,'2026-05-05','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(137,3,'sales',1.00,'2026-05-06','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(138,3,'revenue',1.00,'2026-05-06','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(139,3,'sales',1.00,'2026-05-07','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(140,3,'revenue',1.00,'2026-05-07','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(141,3,'sales',1.00,'2026-05-08','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(142,3,'revenue',1.00,'2026-05-08','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(143,3,'sales',1.00,'2026-05-09','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(144,3,'revenue',1.00,'2026-05-09','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(145,3,'sales',1.00,'2026-05-10','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(146,3,'revenue',1.00,'2026-05-10','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(147,3,'sales',1.00,'2026-05-11','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(148,3,'revenue',1.00,'2026-05-11','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(149,3,'sales',1.00,'2026-05-12','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(150,3,'revenue',1.00,'2026-05-12','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(151,3,'sales',1.00,'2026-05-13','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(152,3,'revenue',1.00,'2026-05-13','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(153,3,'sales',1.00,'2026-05-14','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(154,3,'revenue',1.00,'2026-05-14','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(155,3,'sales',1.00,'2026-05-15','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(156,3,'revenue',1.00,'2026-05-15','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(157,3,'sales',1.00,'2026-05-16','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(158,3,'revenue',1.00,'2026-05-16','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(159,3,'sales',1.00,'2026-05-17','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(160,3,'revenue',1.00,'2026-05-17','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(161,3,'sales',1.00,'2026-05-18','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(162,3,'revenue',1.00,'2026-05-18','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(163,3,'sales',1.00,'2026-05-19','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(164,3,'revenue',1.00,'2026-05-19','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(165,3,'sales',1.00,'2026-05-20','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(166,3,'revenue',1.00,'2026-05-20','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(167,3,'sales',1.00,'2026-05-21','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(168,3,'revenue',1.00,'2026-05-21','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(169,3,'sales',1.00,'2026-05-22','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(170,3,'revenue',1.00,'2026-05-22','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(171,3,'sales',1.00,'2026-05-23','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(172,3,'revenue',1.00,'2026-05-23','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(173,3,'sales',1.00,'2026-05-24','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(174,3,'revenue',1.00,'2026-05-24','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(175,3,'sales',1.00,'2026-05-25','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(176,3,'revenue',1.00,'2026-05-25','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(177,3,'sales',1.00,'2026-05-26','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(178,3,'revenue',1.00,'2026-05-26','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(179,3,'sales',1.00,'2026-05-27','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(180,3,'revenue',1.00,'2026-05-27','2026-04-27 17:00:07','2026-04-27 17:00:07'),
(181,4,'sales',4897.80,'2026-04-28','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(182,4,'revenue',4897.80,'2026-04-28','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(183,4,'sales',233.23,'2026-04-29','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(184,4,'revenue',233.23,'2026-04-29','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(185,4,'sales',0.00,'2026-04-30','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(186,4,'revenue',0.00,'2026-04-30','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(187,4,'sales',0.00,'2026-05-01','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(188,4,'revenue',0.00,'2026-05-01','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(189,4,'sales',0.00,'2026-05-02','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(190,4,'revenue',0.00,'2026-05-02','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(191,4,'sales',0.00,'2026-05-03','2026-04-27 17:00:08','2026-04-27 17:00:08'),
(192,4,'revenue',0.00,'2026-05-03','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(193,4,'sales',0.00,'2026-05-04','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(194,4,'revenue',0.00,'2026-05-04','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(195,4,'sales',0.00,'2026-05-05','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(196,4,'revenue',0.00,'2026-05-05','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(197,4,'sales',0.00,'2026-05-06','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(198,4,'revenue',0.00,'2026-05-06','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(199,4,'sales',0.00,'2026-05-07','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(200,4,'revenue',0.00,'2026-05-07','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(201,4,'sales',0.00,'2026-05-08','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(202,4,'revenue',0.00,'2026-05-08','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(203,4,'sales',0.00,'2026-05-09','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(204,4,'revenue',0.00,'2026-05-09','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(205,4,'sales',0.00,'2026-05-10','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(206,4,'revenue',0.00,'2026-05-10','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(207,4,'sales',0.00,'2026-05-11','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(208,4,'revenue',0.00,'2026-05-11','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(209,4,'sales',0.00,'2026-05-12','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(210,4,'revenue',0.00,'2026-05-12','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(211,4,'sales',0.00,'2026-05-13','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(212,4,'revenue',0.00,'2026-05-13','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(213,4,'sales',0.00,'2026-05-14','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(214,4,'revenue',0.00,'2026-05-14','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(215,4,'sales',0.00,'2026-05-15','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(216,4,'revenue',0.00,'2026-05-15','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(217,4,'sales',0.00,'2026-05-16','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(218,4,'revenue',0.00,'2026-05-16','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(219,4,'sales',0.00,'2026-05-17','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(220,4,'revenue',0.00,'2026-05-17','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(221,4,'sales',0.00,'2026-05-18','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(222,4,'revenue',0.00,'2026-05-18','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(223,4,'sales',0.00,'2026-05-19','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(224,4,'revenue',0.00,'2026-05-19','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(225,4,'sales',0.00,'2026-05-20','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(226,4,'revenue',0.00,'2026-05-20','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(227,4,'sales',0.00,'2026-05-21','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(228,4,'revenue',0.00,'2026-05-21','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(229,4,'sales',0.00,'2026-05-22','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(230,4,'revenue',0.00,'2026-05-22','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(231,4,'sales',0.00,'2026-05-23','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(232,4,'revenue',0.00,'2026-05-23','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(233,4,'sales',0.00,'2026-05-24','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(234,4,'revenue',0.00,'2026-05-24','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(235,4,'sales',0.00,'2026-05-25','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(236,4,'revenue',0.00,'2026-05-25','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(237,4,'sales',0.00,'2026-05-26','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(238,4,'revenue',0.00,'2026-05-26','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(239,4,'sales',0.00,'2026-05-27','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(240,4,'revenue',0.00,'2026-05-27','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(241,5,'sales',1.00,'2026-04-28','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(242,5,'revenue',1.00,'2026-04-28','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(243,5,'sales',1.00,'2026-04-29','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(244,5,'revenue',1.00,'2026-04-29','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(245,5,'sales',1.00,'2026-04-30','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(246,5,'revenue',1.00,'2026-04-30','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(247,5,'sales',1.00,'2026-05-01','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(248,5,'revenue',1.00,'2026-05-01','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(249,5,'sales',1.00,'2026-05-02','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(250,5,'revenue',1.00,'2026-05-02','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(251,5,'sales',1.00,'2026-05-03','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(252,5,'revenue',1.00,'2026-05-03','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(253,5,'sales',1.00,'2026-05-04','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(254,5,'revenue',1.00,'2026-05-04','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(255,5,'sales',1.00,'2026-05-05','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(256,5,'revenue',1.00,'2026-05-05','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(257,5,'sales',1.00,'2026-05-06','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(258,5,'revenue',1.00,'2026-05-06','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(259,5,'sales',1.00,'2026-05-07','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(260,5,'revenue',1.00,'2026-05-07','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(261,5,'sales',1.00,'2026-05-08','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(262,5,'revenue',1.00,'2026-05-08','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(263,5,'sales',1.00,'2026-05-09','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(264,5,'revenue',1.00,'2026-05-09','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(265,5,'sales',1.00,'2026-05-10','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(266,5,'revenue',1.00,'2026-05-10','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(267,5,'sales',1.00,'2026-05-11','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(268,5,'revenue',1.00,'2026-05-11','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(269,5,'sales',1.00,'2026-05-12','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(270,5,'revenue',1.00,'2026-05-12','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(271,5,'sales',1.00,'2026-05-13','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(272,5,'revenue',1.00,'2026-05-13','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(273,5,'sales',1.00,'2026-05-14','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(274,5,'revenue',1.00,'2026-05-14','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(275,5,'sales',1.00,'2026-05-15','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(276,5,'revenue',1.00,'2026-05-15','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(277,5,'sales',1.00,'2026-05-16','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(278,5,'revenue',1.00,'2026-05-16','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(279,5,'sales',1.00,'2026-05-17','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(280,5,'revenue',1.00,'2026-05-17','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(281,5,'sales',1.00,'2026-05-18','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(282,5,'revenue',1.00,'2026-05-18','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(283,5,'sales',1.00,'2026-05-19','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(284,5,'revenue',1.00,'2026-05-19','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(285,5,'sales',1.00,'2026-05-20','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(286,5,'revenue',1.00,'2026-05-20','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(287,5,'sales',1.00,'2026-05-21','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(288,5,'revenue',1.00,'2026-05-21','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(289,5,'sales',1.00,'2026-05-22','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(290,5,'revenue',1.00,'2026-05-22','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(291,5,'sales',1.00,'2026-05-23','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(292,5,'revenue',1.00,'2026-05-23','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(293,5,'sales',1.00,'2026-05-24','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(294,5,'revenue',1.00,'2026-05-24','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(295,5,'sales',1.00,'2026-05-25','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(296,5,'revenue',1.00,'2026-05-25','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(297,5,'sales',1.00,'2026-05-26','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(298,5,'revenue',1.00,'2026-05-26','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(299,5,'sales',1.00,'2026-05-27','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(300,5,'revenue',1.00,'2026-05-27','2026-04-27 17:00:09','2026-04-27 17:00:09'),
(301,6,'sales',1.00,'2026-04-28','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(302,6,'revenue',1.00,'2026-04-28','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(303,6,'sales',1.00,'2026-04-29','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(304,6,'revenue',1.00,'2026-04-29','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(305,6,'sales',1.00,'2026-04-30','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(306,6,'revenue',1.00,'2026-04-30','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(307,6,'sales',1.00,'2026-05-01','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(308,6,'revenue',1.00,'2026-05-01','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(309,6,'sales',1.00,'2026-05-02','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(310,6,'revenue',1.00,'2026-05-02','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(311,6,'sales',1.00,'2026-05-03','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(312,6,'revenue',1.00,'2026-05-03','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(313,6,'sales',1.00,'2026-05-04','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(314,6,'revenue',1.00,'2026-05-04','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(315,6,'sales',1.00,'2026-05-05','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(316,6,'revenue',1.00,'2026-05-05','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(317,6,'sales',1.00,'2026-05-06','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(318,6,'revenue',1.00,'2026-05-06','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(319,6,'sales',1.00,'2026-05-07','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(320,6,'revenue',1.00,'2026-05-07','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(321,6,'sales',1.00,'2026-05-08','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(322,6,'revenue',1.00,'2026-05-08','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(323,6,'sales',1.00,'2026-05-09','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(324,6,'revenue',1.00,'2026-05-09','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(325,6,'sales',1.00,'2026-05-10','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(326,6,'revenue',1.00,'2026-05-10','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(327,6,'sales',1.00,'2026-05-11','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(328,6,'revenue',1.00,'2026-05-11','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(329,6,'sales',1.00,'2026-05-12','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(330,6,'revenue',1.00,'2026-05-12','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(331,6,'sales',1.00,'2026-05-13','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(332,6,'revenue',1.00,'2026-05-13','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(333,6,'sales',1.00,'2026-05-14','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(334,6,'revenue',1.00,'2026-05-14','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(335,6,'sales',1.00,'2026-05-15','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(336,6,'revenue',1.00,'2026-05-15','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(337,6,'sales',1.00,'2026-05-16','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(338,6,'revenue',1.00,'2026-05-16','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(339,6,'sales',1.00,'2026-05-17','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(340,6,'revenue',1.00,'2026-05-17','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(341,6,'sales',1.00,'2026-05-18','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(342,6,'revenue',1.00,'2026-05-18','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(343,6,'sales',1.00,'2026-05-19','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(344,6,'revenue',1.00,'2026-05-19','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(345,6,'sales',1.00,'2026-05-20','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(346,6,'revenue',1.00,'2026-05-20','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(347,6,'sales',1.00,'2026-05-21','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(348,6,'revenue',1.00,'2026-05-21','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(349,6,'sales',1.00,'2026-05-22','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(350,6,'revenue',1.00,'2026-05-22','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(351,6,'sales',1.00,'2026-05-23','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(352,6,'revenue',1.00,'2026-05-23','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(353,6,'sales',1.00,'2026-05-24','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(354,6,'revenue',1.00,'2026-05-24','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(355,6,'sales',1.00,'2026-05-25','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(356,6,'revenue',1.00,'2026-05-25','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(357,6,'sales',1.00,'2026-05-26','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(358,6,'revenue',1.00,'2026-05-26','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(359,6,'sales',1.00,'2026-05-27','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(360,6,'revenue',1.00,'2026-05-27','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(361,7,'sales',1.00,'2026-04-28','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(362,7,'revenue',1.00,'2026-04-28','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(363,7,'sales',1.00,'2026-04-29','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(364,7,'revenue',1.00,'2026-04-29','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(365,7,'sales',1.00,'2026-04-30','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(366,7,'revenue',1.00,'2026-04-30','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(367,7,'sales',1.00,'2026-05-01','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(368,7,'revenue',1.00,'2026-05-01','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(369,7,'sales',1.00,'2026-05-02','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(370,7,'revenue',1.00,'2026-05-02','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(371,7,'sales',1.00,'2026-05-03','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(372,7,'revenue',1.00,'2026-05-03','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(373,7,'sales',1.00,'2026-05-04','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(374,7,'revenue',1.00,'2026-05-04','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(375,7,'sales',1.00,'2026-05-05','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(376,7,'revenue',1.00,'2026-05-05','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(377,7,'sales',1.00,'2026-05-06','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(378,7,'revenue',1.00,'2026-05-06','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(379,7,'sales',1.00,'2026-05-07','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(380,7,'revenue',1.00,'2026-05-07','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(381,7,'sales',1.00,'2026-05-08','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(382,7,'revenue',1.00,'2026-05-08','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(383,7,'sales',1.00,'2026-05-09','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(384,7,'revenue',1.00,'2026-05-09','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(385,7,'sales',1.00,'2026-05-10','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(386,7,'revenue',1.00,'2026-05-10','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(387,7,'sales',1.00,'2026-05-11','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(388,7,'revenue',1.00,'2026-05-11','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(389,7,'sales',1.00,'2026-05-12','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(390,7,'revenue',1.00,'2026-05-12','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(391,7,'sales',1.00,'2026-05-13','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(392,7,'revenue',1.00,'2026-05-13','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(393,7,'sales',1.00,'2026-05-14','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(394,7,'revenue',1.00,'2026-05-14','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(395,7,'sales',1.00,'2026-05-15','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(396,7,'revenue',1.00,'2026-05-15','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(397,7,'sales',1.00,'2026-05-16','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(398,7,'revenue',1.00,'2026-05-16','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(399,7,'sales',1.00,'2026-05-17','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(400,7,'revenue',1.00,'2026-05-17','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(401,7,'sales',1.00,'2026-05-18','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(402,7,'revenue',1.00,'2026-05-18','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(403,7,'sales',1.00,'2026-05-19','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(404,7,'revenue',1.00,'2026-05-19','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(405,7,'sales',1.00,'2026-05-20','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(406,7,'revenue',1.00,'2026-05-20','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(407,7,'sales',1.00,'2026-05-21','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(408,7,'revenue',1.00,'2026-05-21','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(409,7,'sales',1.00,'2026-05-22','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(410,7,'revenue',1.00,'2026-05-22','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(411,7,'sales',1.00,'2026-05-23','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(412,7,'revenue',1.00,'2026-05-23','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(413,7,'sales',1.00,'2026-05-24','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(414,7,'revenue',1.00,'2026-05-24','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(415,7,'sales',1.00,'2026-05-25','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(416,7,'revenue',1.00,'2026-05-25','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(417,7,'sales',1.00,'2026-05-26','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(418,7,'revenue',1.00,'2026-05-26','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(419,7,'sales',1.00,'2026-05-27','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(420,7,'revenue',1.00,'2026-05-27','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(421,8,'sales',1.00,'2026-04-28','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(422,8,'revenue',1.00,'2026-04-28','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(423,8,'sales',1.00,'2026-04-29','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(424,8,'revenue',1.00,'2026-04-29','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(425,8,'sales',1.00,'2026-04-30','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(426,8,'revenue',1.00,'2026-04-30','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(427,8,'sales',1.00,'2026-05-01','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(428,8,'revenue',1.00,'2026-05-01','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(429,8,'sales',1.00,'2026-05-02','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(430,8,'revenue',1.00,'2026-05-02','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(431,8,'sales',1.00,'2026-05-03','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(432,8,'revenue',1.00,'2026-05-03','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(433,8,'sales',1.00,'2026-05-04','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(434,8,'revenue',1.00,'2026-05-04','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(435,8,'sales',1.00,'2026-05-05','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(436,8,'revenue',1.00,'2026-05-05','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(437,8,'sales',1.00,'2026-05-06','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(438,8,'revenue',1.00,'2026-05-06','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(439,8,'sales',1.00,'2026-05-07','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(440,8,'revenue',1.00,'2026-05-07','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(441,8,'sales',1.00,'2026-05-08','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(442,8,'revenue',1.00,'2026-05-08','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(443,8,'sales',1.00,'2026-05-09','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(444,8,'revenue',1.00,'2026-05-09','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(445,8,'sales',1.00,'2026-05-10','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(446,8,'revenue',1.00,'2026-05-10','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(447,8,'sales',1.00,'2026-05-11','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(448,8,'revenue',1.00,'2026-05-11','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(449,8,'sales',1.00,'2026-05-12','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(450,8,'revenue',1.00,'2026-05-12','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(451,8,'sales',1.00,'2026-05-13','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(452,8,'revenue',1.00,'2026-05-13','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(453,8,'sales',1.00,'2026-05-14','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(454,8,'revenue',1.00,'2026-05-14','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(455,8,'sales',1.00,'2026-05-15','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(456,8,'revenue',1.00,'2026-05-15','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(457,8,'sales',1.00,'2026-05-16','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(458,8,'revenue',1.00,'2026-05-16','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(459,8,'sales',1.00,'2026-05-17','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(460,8,'revenue',1.00,'2026-05-17','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(461,8,'sales',1.00,'2026-05-18','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(462,8,'revenue',1.00,'2026-05-18','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(463,8,'sales',1.00,'2026-05-19','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(464,8,'revenue',1.00,'2026-05-19','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(465,8,'sales',1.00,'2026-05-20','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(466,8,'revenue',1.00,'2026-05-20','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(467,8,'sales',1.00,'2026-05-21','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(468,8,'revenue',1.00,'2026-05-21','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(469,8,'sales',1.00,'2026-05-22','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(470,8,'revenue',1.00,'2026-05-22','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(471,8,'sales',1.00,'2026-05-23','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(472,8,'revenue',1.00,'2026-05-23','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(473,8,'sales',1.00,'2026-05-24','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(474,8,'revenue',1.00,'2026-05-24','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(475,8,'sales',1.00,'2026-05-25','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(476,8,'revenue',1.00,'2026-05-25','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(477,8,'sales',1.00,'2026-05-26','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(478,8,'revenue',1.00,'2026-05-26','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(479,8,'sales',1.00,'2026-05-27','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(480,8,'revenue',1.00,'2026-05-27','2026-04-27 17:00:10','2026-04-27 17:00:10'),
(481,10,'sales',1.00,'2026-04-28','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(482,10,'revenue',1.00,'2026-04-28','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(483,10,'sales',1.00,'2026-04-29','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(484,10,'revenue',1.00,'2026-04-29','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(485,10,'sales',1.00,'2026-04-30','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(486,10,'revenue',1.00,'2026-04-30','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(487,10,'sales',1.00,'2026-05-01','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(488,10,'revenue',1.00,'2026-05-01','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(489,10,'sales',1.00,'2026-05-02','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(490,10,'revenue',1.00,'2026-05-02','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(491,10,'sales',1.00,'2026-05-03','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(492,10,'revenue',1.00,'2026-05-03','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(493,10,'sales',1.00,'2026-05-04','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(494,10,'revenue',1.00,'2026-05-04','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(495,10,'sales',1.00,'2026-05-05','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(496,10,'revenue',1.00,'2026-05-05','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(497,10,'sales',1.00,'2026-05-06','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(498,10,'revenue',1.00,'2026-05-06','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(499,10,'sales',1.00,'2026-05-07','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(500,10,'revenue',1.00,'2026-05-07','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(501,10,'sales',1.00,'2026-05-08','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(502,10,'revenue',1.00,'2026-05-08','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(503,10,'sales',1.00,'2026-05-09','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(504,10,'revenue',1.00,'2026-05-09','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(505,10,'sales',1.00,'2026-05-10','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(506,10,'revenue',1.00,'2026-05-10','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(507,10,'sales',1.00,'2026-05-11','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(508,10,'revenue',1.00,'2026-05-11','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(509,10,'sales',1.00,'2026-05-12','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(510,10,'revenue',1.00,'2026-05-12','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(511,10,'sales',1.00,'2026-05-13','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(512,10,'revenue',1.00,'2026-05-13','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(513,10,'sales',1.00,'2026-05-14','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(514,10,'revenue',1.00,'2026-05-14','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(515,10,'sales',1.00,'2026-05-15','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(516,10,'revenue',1.00,'2026-05-15','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(517,10,'sales',1.00,'2026-05-16','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(518,10,'revenue',1.00,'2026-05-16','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(519,10,'sales',1.00,'2026-05-17','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(520,10,'revenue',1.00,'2026-05-17','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(521,10,'sales',1.00,'2026-05-18','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(522,10,'revenue',1.00,'2026-05-18','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(523,10,'sales',1.00,'2026-05-19','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(524,10,'revenue',1.00,'2026-05-19','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(525,10,'sales',1.00,'2026-05-20','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(526,10,'revenue',1.00,'2026-05-20','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(527,10,'sales',1.00,'2026-05-21','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(528,10,'revenue',1.00,'2026-05-21','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(529,10,'sales',1.00,'2026-05-22','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(530,10,'revenue',1.00,'2026-05-22','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(531,10,'sales',1.00,'2026-05-23','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(532,10,'revenue',1.00,'2026-05-23','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(533,10,'sales',1.00,'2026-05-24','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(534,10,'revenue',1.00,'2026-05-24','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(535,10,'sales',1.00,'2026-05-25','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(536,10,'revenue',1.00,'2026-05-25','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(537,10,'sales',1.00,'2026-05-26','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(538,10,'revenue',1.00,'2026-05-26','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(539,10,'sales',1.00,'2026-05-27','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(540,10,'revenue',1.00,'2026-05-27','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(541,11,'sales',1.00,'2026-04-28','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(542,11,'revenue',1.00,'2026-04-28','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(543,11,'sales',1.00,'2026-04-29','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(544,11,'revenue',1.00,'2026-04-29','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(545,11,'sales',1.00,'2026-04-30','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(546,11,'revenue',1.00,'2026-04-30','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(547,11,'sales',1.00,'2026-05-01','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(548,11,'revenue',1.00,'2026-05-01','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(549,11,'sales',1.00,'2026-05-02','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(550,11,'revenue',1.00,'2026-05-02','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(551,11,'sales',1.00,'2026-05-03','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(552,11,'revenue',1.00,'2026-05-03','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(553,11,'sales',1.00,'2026-05-04','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(554,11,'revenue',1.00,'2026-05-04','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(555,11,'sales',1.00,'2026-05-05','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(556,11,'revenue',1.00,'2026-05-05','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(557,11,'sales',1.00,'2026-05-06','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(558,11,'revenue',1.00,'2026-05-06','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(559,11,'sales',1.00,'2026-05-07','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(560,11,'revenue',1.00,'2026-05-07','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(561,11,'sales',1.00,'2026-05-08','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(562,11,'revenue',1.00,'2026-05-08','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(563,11,'sales',1.00,'2026-05-09','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(564,11,'revenue',1.00,'2026-05-09','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(565,11,'sales',1.00,'2026-05-10','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(566,11,'revenue',1.00,'2026-05-10','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(567,11,'sales',1.00,'2026-05-11','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(568,11,'revenue',1.00,'2026-05-11','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(569,11,'sales',1.00,'2026-05-12','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(570,11,'revenue',1.00,'2026-05-12','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(571,11,'sales',1.00,'2026-05-13','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(572,11,'revenue',1.00,'2026-05-13','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(573,11,'sales',1.00,'2026-05-14','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(574,11,'revenue',1.00,'2026-05-14','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(575,11,'sales',1.00,'2026-05-15','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(576,11,'revenue',1.00,'2026-05-15','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(577,11,'sales',1.00,'2026-05-16','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(578,11,'revenue',1.00,'2026-05-16','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(579,11,'sales',1.00,'2026-05-17','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(580,11,'revenue',1.00,'2026-05-17','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(581,11,'sales',1.00,'2026-05-18','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(582,11,'revenue',1.00,'2026-05-18','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(583,11,'sales',1.00,'2026-05-19','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(584,11,'revenue',1.00,'2026-05-19','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(585,11,'sales',1.00,'2026-05-20','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(586,11,'revenue',1.00,'2026-05-20','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(587,11,'sales',1.00,'2026-05-21','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(588,11,'revenue',1.00,'2026-05-21','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(589,11,'sales',1.00,'2026-05-22','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(590,11,'revenue',1.00,'2026-05-22','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(591,11,'sales',1.00,'2026-05-23','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(592,11,'revenue',1.00,'2026-05-23','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(593,11,'sales',1.00,'2026-05-24','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(594,11,'revenue',1.00,'2026-05-24','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(595,11,'sales',1.00,'2026-05-25','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(596,11,'revenue',1.00,'2026-05-25','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(597,11,'sales',1.00,'2026-05-26','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(598,11,'revenue',1.00,'2026-05-26','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(599,11,'sales',1.00,'2026-05-27','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(600,11,'revenue',1.00,'2026-05-27','2026-04-27 17:00:11','2026-04-27 17:00:11'),
(601,12,'sales',29872.80,'2026-04-28','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(602,12,'revenue',29872.80,'2026-04-28','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(603,12,'sales',1422.51,'2026-04-29','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(604,12,'revenue',1422.51,'2026-04-29','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(605,12,'sales',0.00,'2026-04-30','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(606,12,'revenue',0.00,'2026-04-30','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(607,12,'sales',0.00,'2026-05-01','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(608,12,'revenue',0.00,'2026-05-01','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(609,12,'sales',0.00,'2026-05-02','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(610,12,'revenue',0.00,'2026-05-02','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(611,12,'sales',0.00,'2026-05-03','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(612,12,'revenue',0.00,'2026-05-03','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(613,12,'sales',0.00,'2026-05-04','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(614,12,'revenue',0.00,'2026-05-04','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(615,12,'sales',0.00,'2026-05-05','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(616,12,'revenue',0.00,'2026-05-05','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(617,12,'sales',0.00,'2026-05-06','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(618,12,'revenue',0.00,'2026-05-06','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(619,12,'sales',0.00,'2026-05-07','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(620,12,'revenue',0.00,'2026-05-07','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(621,12,'sales',0.00,'2026-05-08','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(622,12,'revenue',0.00,'2026-05-08','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(623,12,'sales',0.00,'2026-05-09','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(624,12,'revenue',0.00,'2026-05-09','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(625,12,'sales',0.00,'2026-05-10','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(626,12,'revenue',0.00,'2026-05-10','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(627,12,'sales',0.00,'2026-05-11','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(628,12,'revenue',0.00,'2026-05-11','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(629,12,'sales',0.00,'2026-05-12','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(630,12,'revenue',0.00,'2026-05-12','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(631,12,'sales',0.00,'2026-05-13','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(632,12,'revenue',0.00,'2026-05-13','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(633,12,'sales',0.00,'2026-05-14','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(634,12,'revenue',0.00,'2026-05-14','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(635,12,'sales',0.00,'2026-05-15','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(636,12,'revenue',0.00,'2026-05-15','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(637,12,'sales',0.00,'2026-05-16','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(638,12,'revenue',0.00,'2026-05-16','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(639,12,'sales',0.00,'2026-05-17','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(640,12,'revenue',0.00,'2026-05-17','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(641,12,'sales',0.00,'2026-05-18','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(642,12,'revenue',0.00,'2026-05-18','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(643,12,'sales',0.00,'2026-05-19','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(644,12,'revenue',0.00,'2026-05-19','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(645,12,'sales',0.00,'2026-05-20','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(646,12,'revenue',0.00,'2026-05-20','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(647,12,'sales',0.00,'2026-05-21','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(648,12,'revenue',0.00,'2026-05-21','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(649,12,'sales',0.00,'2026-05-22','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(650,12,'revenue',0.00,'2026-05-22','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(651,12,'sales',0.00,'2026-05-23','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(652,12,'revenue',0.00,'2026-05-23','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(653,12,'sales',0.00,'2026-05-24','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(654,12,'revenue',0.00,'2026-05-24','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(655,12,'sales',0.00,'2026-05-25','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(656,12,'revenue',0.00,'2026-05-25','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(657,12,'sales',0.00,'2026-05-26','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(658,12,'revenue',0.00,'2026-05-26','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(659,12,'sales',0.00,'2026-05-27','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(660,12,'revenue',0.00,'2026-05-27','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(661,13,'sales',1.00,'2026-04-28','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(662,13,'revenue',1.00,'2026-04-28','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(663,13,'sales',1.00,'2026-04-29','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(664,13,'revenue',1.00,'2026-04-29','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(665,13,'sales',1.00,'2026-04-30','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(666,13,'revenue',1.00,'2026-04-30','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(667,13,'sales',1.00,'2026-05-01','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(668,13,'revenue',1.00,'2026-05-01','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(669,13,'sales',1.00,'2026-05-02','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(670,13,'revenue',1.00,'2026-05-02','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(671,13,'sales',1.00,'2026-05-03','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(672,13,'revenue',1.00,'2026-05-03','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(673,13,'sales',1.00,'2026-05-04','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(674,13,'revenue',1.00,'2026-05-04','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(675,13,'sales',1.00,'2026-05-05','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(676,13,'revenue',1.00,'2026-05-05','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(677,13,'sales',1.00,'2026-05-06','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(678,13,'revenue',1.00,'2026-05-06','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(679,13,'sales',1.00,'2026-05-07','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(680,13,'revenue',1.00,'2026-05-07','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(681,13,'sales',1.00,'2026-05-08','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(682,13,'revenue',1.00,'2026-05-08','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(683,13,'sales',1.00,'2026-05-09','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(684,13,'revenue',1.00,'2026-05-09','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(685,13,'sales',1.00,'2026-05-10','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(686,13,'revenue',1.00,'2026-05-10','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(687,13,'sales',1.00,'2026-05-11','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(688,13,'revenue',1.00,'2026-05-11','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(689,13,'sales',1.00,'2026-05-12','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(690,13,'revenue',1.00,'2026-05-12','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(691,13,'sales',1.00,'2026-05-13','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(692,13,'revenue',1.00,'2026-05-13','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(693,13,'sales',1.00,'2026-05-14','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(694,13,'revenue',1.00,'2026-05-14','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(695,13,'sales',1.00,'2026-05-15','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(696,13,'revenue',1.00,'2026-05-15','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(697,13,'sales',1.00,'2026-05-16','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(698,13,'revenue',1.00,'2026-05-16','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(699,13,'sales',1.00,'2026-05-17','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(700,13,'revenue',1.00,'2026-05-17','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(701,13,'sales',1.00,'2026-05-18','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(702,13,'revenue',1.00,'2026-05-18','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(703,13,'sales',1.00,'2026-05-19','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(704,13,'revenue',1.00,'2026-05-19','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(705,13,'sales',1.00,'2026-05-20','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(706,13,'revenue',1.00,'2026-05-20','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(707,13,'sales',1.00,'2026-05-21','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(708,13,'revenue',1.00,'2026-05-21','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(709,13,'sales',1.00,'2026-05-22','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(710,13,'revenue',1.00,'2026-05-22','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(711,13,'sales',1.00,'2026-05-23','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(712,13,'revenue',1.00,'2026-05-23','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(713,13,'sales',1.00,'2026-05-24','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(714,13,'revenue',1.00,'2026-05-24','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(715,13,'sales',1.00,'2026-05-25','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(716,13,'revenue',1.00,'2026-05-25','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(717,13,'sales',1.00,'2026-05-26','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(718,13,'revenue',1.00,'2026-05-26','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(719,13,'sales',1.00,'2026-05-27','2026-04-27 17:00:12','2026-04-27 17:00:12'),
(720,13,'revenue',1.00,'2026-05-27','2026-04-27 17:00:12','2026-04-27 17:00:12');
/*!40000 ALTER TABLE `forecasts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hostnames`
--

DROP TABLE IF EXISTS `hostnames`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hostnames` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `fqdn` varchar(255) NOT NULL,
  `redirect_to` varchar(255) DEFAULT NULL,
  `force_https` tinyint(1) NOT NULL DEFAULT 0,
  `under_maintenance_since` timestamp NULL DEFAULT NULL,
  `website_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostnames_fqdn_unique` (`fqdn`),
  KEY `hostnames_website_id_foreign` (`website_id`),
  CONSTRAINT `hostnames_website_id_foreign` FOREIGN KEY (`website_id`) REFERENCES `websites` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hostnames`
--

LOCK TABLES `hostnames` WRITE;
/*!40000 ALTER TABLE `hostnames` DISABLE KEYS */;
/*!40000 ALTER TABLE `hostnames` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint(20) unsigned NOT NULL,
  `direction` enum('inbound','outbound') NOT NULL DEFAULT 'inbound',
  `type` enum('text','image','voice','document') NOT NULL DEFAULT 'text',
  `content` text DEFAULT NULL,
  `media_url` varchar(255) DEFAULT NULL,
  `is_ai_generated` tinyint(1) NOT NULL DEFAULT 0,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `messages_conversation_id_foreign` (`conversation_id`),
  CONSTRAINT `messages_conversation_id_foreign` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES
(1,'0001_01_01_000000_create_users_table',1),
(2,'0001_01_01_000001_create_cache_table',1),
(3,'0001_01_01_000002_create_jobs_table',1),
(4,'2017_01_01_000003_tenancy_websites',1),
(5,'2017_01_01_000005_tenancy_hostnames',1),
(6,'2018_04_06_000001_tenancy_websites_needs_db_host',1),
(7,'2024_01_01_000010_create_tenants_table',2),
(8,'2024_01_01_000011_create_whatsapp_accounts_table',2),
(9,'2024_01_01_000012_create_products_table',2),
(10,'2024_01_01_000013_create_customers_table',2),
(11,'2024_01_01_000014_create_orders_table',2),
(12,'2024_01_01_000015_create_conversations_table',2),
(13,'2024_01_01_000016_create_ai_logs_table',2),
(14,'2024_01_01_000017_create_ai_settings_table',2),
(15,'2024_01_01_000018_add_tenant_id_to_users_table',2),
(16,'2026_04_04_154427_create_permission_tables',2),
(17,'2024_01_01_000020_add_subscription_to_tenants_table',3),
(18,'2024_01_01_000021_create_whatsapp_messages_table',3),
(19,'2024_01_01_000022_create_agent_logs_table',3),
(20,'2024_01_01_000030_create_prompts_table',4),
(21,'2024_01_01_000018_create_agents_table',5),
(22,'2024_01_01_000019_create_inventory_agents',6),
(23,'2024_01_01_000023_create_ai_agents_table',7),
(25,'2024_01_01_000024_add_agent_engine_columns_to_agents_table',8),
(26,'2024_01_01_000025_make_agent_fields_nullable',9),
(27,'2017_01_01_000000_create_worksuite_table_collation_fix',10),
(28,'2024_01_01_000026_reset_agents_table',11),
(29,'2026_04_22_000001_add_runtime_fields_to_ai_settings_table',11),
(30,'2026_04_22_000002_add_meta_to_sync_logs_table',11),
(31,'2026_04_27_000001_create_business_intelligence_tables',11),
(32,'2026_04_27_000002_register_business_intelligence_agent',11),
(33,'2026_04_30_000001_create_agent_orchestrator_tables',12),
(34,'2026_05_05_000001_add_owner_email_to_tenants_table',13);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_has_permissions`
--

DROP TABLE IF EXISTS `model_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_has_permissions` (
  `permission_id` bigint(20) unsigned NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_permissions`
--

LOCK TABLES `model_has_permissions` WRITE;
/*!40000 ALTER TABLE `model_has_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `model_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_has_roles`
--

DROP TABLE IF EXISTS `model_has_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_has_roles` (
  `role_id` bigint(20) unsigned NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_roles`
--

LOCK TABLES `model_has_roles` WRITE;
/*!40000 ALTER TABLE `model_has_roles` DISABLE KEYS */;
INSERT INTO `model_has_roles` VALUES
(1,'App\\Models\\User',1),
(2,'App\\Models\\User',2);
/*!40000 ALTER TABLE `model_has_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned NOT NULL,
  `product_id` bigint(20) unsigned DEFAULT NULL,
  `product_name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `unit_price` decimal(12,2) NOT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_foreign` (`order_id`),
  KEY `order_items_product_id_foreign` (`product_id`),
  CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `customer_id` bigint(20) unsigned DEFAULT NULL,
  `order_number` varchar(255) NOT NULL,
  `source` enum('ai','manual','whatsapp') NOT NULL DEFAULT 'manual',
  `status` enum('pending','confirmed','processing','completed','cancelled') NOT NULL DEFAULT 'pending',
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `notes` text DEFAULT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orders_order_number_unique` (`order_number`),
  KEY `orders_customer_id_foreign` (`customer_id`),
  KEY `orders_tenant_id_status_index` (`tenant_id`,`status`),
  KEY `orders_tenant_id_source_index` (`tenant_id`,`source`),
  CONSTRAINT `orders_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=188 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES
(1,2,3,'ORD-RFBV0KDC','ai','completed',74882.00,1557.00,73325.00,NULL,NULL,'2026-03-13 13:57:47','2026-03-13 13:57:47'),
(2,2,1,'ORD-6PNWYYQ5','ai','completed',141207.00,327.00,140880.00,NULL,NULL,'2026-02-23 13:57:47','2026-02-23 13:57:47'),
(3,2,14,'ORD-SAQ3D5KH','ai','completed',119651.00,4717.00,114934.00,NULL,NULL,'2026-02-17 13:57:47','2026-02-17 13:57:47'),
(4,2,5,'ORD-VNZSIASJ','whatsapp','processing',61504.00,4096.00,57408.00,NULL,NULL,'2026-04-02 13:57:47','2026-04-02 13:57:47'),
(5,2,13,'ORD-IJB8TJKI','whatsapp','completed',37513.00,0.00,37513.00,NULL,NULL,'2026-04-12 13:57:47','2026-04-12 13:57:47'),
(6,2,10,'ORD-TDWUFBDX','manual','completed',114619.00,0.00,114619.00,NULL,NULL,'2026-04-01 13:57:47','2026-04-01 13:57:47'),
(7,2,12,'ORD-GOCUCEYD','whatsapp','completed',33890.00,620.00,33270.00,NULL,NULL,'2026-03-22 13:57:47','2026-03-22 13:57:47'),
(8,2,13,'ORD-TYENYLTM','ai','completed',12280.00,2326.00,9954.00,NULL,NULL,'2026-03-17 13:57:47','2026-03-17 13:57:47'),
(9,2,9,'ORD-PR4YW0OE','whatsapp','cancelled',31676.00,0.00,31676.00,NULL,NULL,'2026-03-12 13:57:47','2026-03-12 13:57:47'),
(10,2,13,'ORD-LXOZZSSG','manual','completed',103791.00,0.00,103791.00,NULL,NULL,'2026-04-06 13:57:48','2026-04-06 13:57:48'),
(11,2,2,'ORD-UZEGAAXK','ai','completed',146810.00,0.00,146810.00,NULL,NULL,'2026-03-01 13:57:48','2026-03-01 13:57:48'),
(12,2,4,'ORD-S2GVD4OL','ai','pending',28575.00,0.00,28575.00,NULL,NULL,'2026-04-05 13:57:48','2026-04-05 13:57:48'),
(13,2,12,'ORD-SWQWDG6A','ai','completed',137120.00,0.00,137120.00,NULL,NULL,'2026-03-27 13:57:48','2026-03-27 13:57:48'),
(14,2,14,'ORD-KSUAVDJF','manual','completed',70879.00,4137.00,66742.00,NULL,NULL,'2026-04-13 13:57:48','2026-04-13 13:57:48'),
(15,2,11,'ORD-AFC0MRRX','whatsapp','cancelled',9630.00,2416.00,7214.00,NULL,NULL,'2026-03-31 13:57:48','2026-03-31 13:57:48'),
(16,2,4,'ORD-HLVBHSZB','manual','completed',113230.00,0.00,113230.00,NULL,NULL,'2026-02-23 13:57:48','2026-02-23 13:57:48'),
(17,2,1,'ORD-L9XFGKFD','ai','completed',81126.00,3683.00,77443.00,NULL,NULL,'2026-03-26 13:57:48','2026-03-26 13:57:48'),
(18,2,4,'ORD-TKQSPZVD','whatsapp','completed',46510.00,117.00,46393.00,NULL,NULL,'2026-04-14 13:57:48','2026-04-14 13:57:48'),
(19,2,5,'ORD-2CLVPKU3','ai','completed',31231.00,0.00,31231.00,NULL,NULL,'2026-03-24 13:57:48','2026-03-24 13:57:48'),
(20,3,16,'ORD-XT7T0B6V','whatsapp','completed',86450.00,3260.00,83190.00,NULL,NULL,'2026-03-12 13:57:48','2026-03-12 13:57:48'),
(21,3,19,'ORD-IRIDCV3D','ai','pending',127814.00,0.00,127814.00,NULL,NULL,'2026-02-23 13:57:48','2026-02-23 13:57:48'),
(22,3,19,'ORD-UUZIS0XE','ai','completed',137399.00,0.00,137399.00,NULL,NULL,'2026-03-30 13:57:48','2026-03-30 13:57:48'),
(23,3,16,'ORD-36IMV691','whatsapp','completed',33197.00,0.00,33197.00,NULL,NULL,'2026-02-26 13:57:48','2026-02-26 13:57:48'),
(24,3,20,'ORD-VGGJ68HG','manual','processing',106045.00,0.00,106045.00,NULL,NULL,'2026-03-18 13:57:48','2026-03-18 13:57:48'),
(25,3,17,'ORD-IMQFEEUL','manual','completed',22986.00,0.00,22986.00,NULL,NULL,'2026-03-09 13:57:48','2026-03-09 13:57:48'),
(26,3,20,'ORD-DEVG5KF3','manual','pending',23487.00,0.00,23487.00,NULL,NULL,'2026-02-23 13:57:48','2026-02-23 13:57:48'),
(27,3,17,'ORD-1FFMUYXB','ai','cancelled',95013.00,0.00,95013.00,NULL,NULL,'2026-04-01 13:57:48','2026-04-01 13:57:48'),
(28,3,19,'ORD-FLQP0RZO','manual','pending',31274.00,3181.00,28093.00,NULL,NULL,'2026-04-07 13:57:48','2026-04-07 13:57:48'),
(29,3,19,'ORD-9T0BO36F','manual','cancelled',144132.00,0.00,144132.00,NULL,NULL,'2026-04-05 13:57:48','2026-04-05 13:57:48'),
(30,3,17,'ORD-TRENFL7C','ai','completed',146103.00,2437.00,143666.00,NULL,NULL,'2026-03-29 13:57:48','2026-03-29 13:57:48'),
(31,3,15,'ORD-RSSSNLEC','whatsapp','cancelled',121396.00,2777.00,118619.00,NULL,NULL,'2026-03-13 13:57:48','2026-03-13 13:57:48'),
(32,3,20,'ORD-YM4WWQUJ','manual','pending',95648.00,4183.00,91465.00,NULL,NULL,'2026-03-11 13:57:48','2026-03-11 13:57:48'),
(33,4,30,'ORD-AUOYAYOD','manual','completed',54368.00,0.00,54368.00,NULL,NULL,'2026-02-14 13:57:48','2026-02-14 13:57:48'),
(34,4,24,'ORD-TNC0TD34','whatsapp','processing',16326.00,0.00,16326.00,NULL,NULL,'2026-04-14 13:57:48','2026-04-14 13:57:48'),
(35,4,29,'ORD-PKVDRQAZ','ai','processing',98260.00,1123.00,97137.00,NULL,NULL,'2026-04-02 13:57:48','2026-04-02 13:57:48'),
(36,4,30,'ORD-A8FUW6VG','ai','completed',149480.00,0.00,149480.00,NULL,NULL,'2026-02-28 13:57:48','2026-02-28 13:57:48'),
(37,4,26,'ORD-GXITEEOT','whatsapp','completed',125806.00,0.00,125806.00,NULL,NULL,'2026-03-25 13:57:48','2026-03-25 13:57:48'),
(38,4,23,'ORD-30FEUN92','ai','completed',124362.00,3678.00,120684.00,NULL,NULL,'2026-04-12 13:57:48','2026-04-12 13:57:48'),
(39,4,26,'ORD-SAHIOMCC','ai','completed',111207.00,0.00,111207.00,NULL,NULL,'2026-03-16 13:57:48','2026-03-16 13:57:48'),
(40,4,27,'ORD-HQGELLDN','manual','completed',144834.00,501.00,144333.00,NULL,NULL,'2026-03-13 13:57:48','2026-03-13 13:57:48'),
(41,4,24,'ORD-O4BFUF0K','ai','pending',122068.00,3257.00,118811.00,NULL,NULL,'2026-04-14 13:57:48','2026-04-14 13:57:48'),
(42,4,22,'ORD-Q57TPANT','manual','processing',71380.00,3938.00,67442.00,NULL,NULL,'2026-03-01 13:57:48','2026-03-01 13:57:48'),
(43,4,22,'ORD-5HTKWQ4E','whatsapp','processing',97858.00,3318.00,94540.00,NULL,NULL,'2026-03-27 13:57:48','2026-03-27 13:57:48'),
(44,4,27,'ORD-0ZDRXFCU','manual','cancelled',118468.00,3978.00,114490.00,NULL,NULL,'2026-03-10 13:57:48','2026-03-10 13:57:48'),
(45,5,35,'ORD-P6AXLGQX','ai','completed',10688.00,3522.00,7166.00,NULL,NULL,'2026-04-13 13:57:48','2026-04-13 13:57:48'),
(46,5,36,'ORD-IPQNSGIO','whatsapp','completed',16813.00,588.00,16225.00,NULL,NULL,'2026-04-12 13:57:48','2026-04-12 13:57:48'),
(47,5,33,'ORD-R2KNED8V','manual','completed',41781.00,0.00,41781.00,NULL,NULL,'2026-03-16 13:57:48','2026-03-16 13:57:48'),
(48,5,31,'ORD-LWQBBEWL','manual','completed',124582.00,1116.00,123466.00,NULL,NULL,'2026-04-10 13:57:48','2026-04-10 13:57:48'),
(49,5,32,'ORD-TPFY74VF','manual','completed',111938.00,0.00,111938.00,NULL,NULL,'2026-03-05 13:57:48','2026-03-05 13:57:48'),
(50,5,33,'ORD-HNWH9ANS','manual','completed',149821.00,0.00,149821.00,NULL,NULL,'2026-02-20 13:57:49','2026-02-20 13:57:49'),
(51,5,32,'ORD-BNKZDEME','manual','processing',19543.00,2829.00,16714.00,NULL,NULL,'2026-02-27 13:57:49','2026-02-27 13:57:49'),
(52,5,34,'ORD-ILYFF5SL','ai','cancelled',26923.00,0.00,26923.00,NULL,NULL,'2026-02-27 13:57:49','2026-02-27 13:57:49'),
(53,5,35,'ORD-HG3AVIGG','manual','completed',61546.00,0.00,61546.00,NULL,NULL,'2026-03-26 13:57:49','2026-03-26 13:57:49'),
(54,5,31,'ORD-TBWCKG1D','whatsapp','processing',124586.00,3196.00,121390.00,NULL,NULL,'2026-02-27 13:57:49','2026-02-27 13:57:49'),
(55,5,33,'ORD-IFBBOLSI','whatsapp','completed',84820.00,1569.00,83251.00,NULL,NULL,'2026-04-05 13:57:49','2026-04-05 13:57:49'),
(56,5,33,'ORD-VYB1YFOC','whatsapp','completed',118128.00,0.00,118128.00,NULL,NULL,'2026-02-28 13:57:49','2026-02-28 13:57:49'),
(57,5,34,'ORD-CHKYBFPH','whatsapp','completed',81274.00,2977.00,78297.00,NULL,NULL,'2026-03-04 13:57:49','2026-03-04 13:57:49'),
(58,5,35,'ORD-ZSPYKQDG','whatsapp','cancelled',24716.00,4252.00,20464.00,NULL,NULL,'2026-03-27 13:57:49','2026-03-27 13:57:49'),
(59,5,35,'ORD-U9BZKD6H','ai','pending',10578.00,0.00,10578.00,NULL,NULL,'2026-03-09 13:57:49','2026-03-09 13:57:49'),
(60,5,33,'ORD-5BWMCP6J','manual','completed',43189.00,4087.00,39102.00,NULL,NULL,'2026-03-03 13:57:49','2026-03-03 13:57:49'),
(61,5,31,'ORD-DSAGGFOV','manual','cancelled',146880.00,0.00,146880.00,NULL,NULL,'2026-03-20 13:57:49','2026-03-20 13:57:49'),
(62,5,33,'ORD-AOBNXEAN','manual','completed',95980.00,1697.00,94283.00,NULL,NULL,'2026-03-04 13:57:49','2026-03-04 13:57:49'),
(63,6,41,'ORD-TG3YFFXM','ai','pending',107187.00,3189.00,103998.00,NULL,NULL,'2026-04-12 13:57:49','2026-04-12 13:57:49'),
(64,6,45,'ORD-UCWIBO6I','ai','processing',80687.00,0.00,80687.00,NULL,NULL,'2026-03-14 13:57:49','2026-03-14 13:57:49'),
(65,6,39,'ORD-EDMUAXB9','ai','processing',109318.00,0.00,109318.00,NULL,NULL,'2026-02-21 13:57:49','2026-02-21 13:57:49'),
(66,6,37,'ORD-XGEO6X91','manual','pending',124203.00,2171.00,122032.00,NULL,NULL,'2026-03-24 13:57:49','2026-03-24 13:57:49'),
(67,6,38,'ORD-EHO5JXZ2','manual','pending',19719.00,3680.00,16039.00,NULL,NULL,'2026-03-12 13:57:49','2026-03-12 13:57:49'),
(68,6,44,'ORD-MJRMHVRL','manual','cancelled',104328.00,0.00,104328.00,NULL,NULL,'2026-03-22 13:57:49','2026-03-22 13:57:49'),
(69,6,45,'ORD-8CTDTCZ5','ai','completed',7751.00,0.00,7751.00,NULL,NULL,'2026-02-16 13:57:49','2026-02-16 13:57:49'),
(70,6,38,'ORD-DPQ8RQNC','whatsapp','completed',61805.00,1633.00,60172.00,NULL,NULL,'2026-03-18 13:57:49','2026-03-18 13:57:49'),
(71,6,41,'ORD-650SQZZN','ai','cancelled',53645.00,0.00,53645.00,NULL,NULL,'2026-02-23 13:57:49','2026-02-23 13:57:49'),
(72,6,45,'ORD-VR6EZ3JC','ai','completed',65085.00,0.00,65085.00,NULL,NULL,'2026-03-12 13:57:49','2026-03-12 13:57:49'),
(73,6,41,'ORD-JFRFKGXC','whatsapp','pending',149358.00,2830.00,146528.00,NULL,NULL,'2026-04-11 13:57:49','2026-04-11 13:57:49'),
(74,6,43,'ORD-7AKKXSV8','manual','pending',57313.00,1435.00,55878.00,NULL,NULL,'2026-03-29 13:57:49','2026-03-29 13:57:49'),
(75,6,42,'ORD-0VM5LJGS','manual','cancelled',145417.00,0.00,145417.00,NULL,NULL,'2026-03-31 13:57:49','2026-03-31 13:57:49'),
(76,6,40,'ORD-W5GL6G38','manual','completed',2397.00,0.00,2397.00,NULL,NULL,'2026-04-10 13:57:49','2026-04-10 13:57:49'),
(77,6,44,'ORD-NCOIMAMY','whatsapp','processing',80057.00,0.00,80057.00,NULL,NULL,'2026-03-05 13:57:49','2026-03-05 13:57:49'),
(78,6,44,'ORD-YLADEHQT','ai','processing',55411.00,1903.00,53508.00,NULL,NULL,'2026-03-13 13:57:49','2026-03-13 13:57:49'),
(79,6,43,'ORD-FT3GKLMA','manual','completed',54726.00,0.00,54726.00,NULL,NULL,'2026-03-23 13:57:49','2026-03-23 13:57:49'),
(80,6,38,'ORD-BFS24J8I','manual','processing',130333.00,0.00,130333.00,NULL,NULL,'2026-03-02 13:57:49','2026-03-02 13:57:49'),
(81,6,40,'ORD-WWN6DQYH','whatsapp','pending',70555.00,0.00,70555.00,NULL,NULL,'2026-03-07 13:57:49','2026-03-07 13:57:49'),
(82,7,53,'ORD-4VY6QQQE','whatsapp','completed',38113.00,4790.00,33323.00,NULL,NULL,'2026-03-21 13:57:49','2026-03-21 13:57:49'),
(83,7,48,'ORD-C7RDNYKL','whatsapp','completed',81463.00,0.00,81463.00,NULL,NULL,'2026-03-24 13:57:49','2026-03-24 13:57:49'),
(84,7,49,'ORD-KLM2111K','manual','completed',139355.00,4020.00,135335.00,NULL,NULL,'2026-03-31 13:57:49','2026-03-31 13:57:49'),
(85,7,50,'ORD-RINTC3IY','manual','pending',9544.00,0.00,9544.00,NULL,NULL,'2026-04-13 13:57:49','2026-04-13 13:57:49'),
(86,7,47,'ORD-Y1E1JDL8','ai','pending',104125.00,3223.00,100902.00,NULL,NULL,'2026-03-11 13:57:49','2026-03-11 13:57:49'),
(87,7,52,'ORD-OFNYPCJ9','ai','completed',78781.00,0.00,78781.00,NULL,NULL,'2026-03-17 13:57:49','2026-03-17 13:57:49'),
(88,7,46,'ORD-OADD3ANQ','manual','processing',123510.00,0.00,123510.00,NULL,NULL,'2026-02-25 13:57:49','2026-02-25 13:57:49'),
(89,7,49,'ORD-RQ2407BA','ai','completed',139885.00,3610.00,136275.00,NULL,NULL,'2026-03-03 13:57:49','2026-03-03 13:57:49'),
(90,7,46,'ORD-NLXVT466','manual','cancelled',68817.00,318.00,68499.00,NULL,NULL,'2026-03-28 13:57:49','2026-03-28 13:57:49'),
(91,7,48,'ORD-L4GAVDLQ','whatsapp','completed',97288.00,0.00,97288.00,NULL,NULL,'2026-04-05 13:57:50','2026-04-05 13:57:50'),
(92,7,52,'ORD-YYXAVTTQ','manual','cancelled',92829.00,1071.00,91758.00,NULL,NULL,'2026-02-25 13:57:50','2026-02-25 13:57:50'),
(93,7,53,'ORD-TRBWW9WY','manual','processing',107005.00,0.00,107005.00,NULL,NULL,'2026-02-25 13:57:50','2026-02-25 13:57:50'),
(94,7,48,'ORD-B613PCKR','manual','cancelled',18706.00,285.00,18421.00,NULL,NULL,'2026-02-25 13:57:50','2026-02-25 13:57:50'),
(95,7,55,'ORD-WKS8W6M1','whatsapp','cancelled',41812.00,2808.00,39004.00,NULL,NULL,'2026-04-12 13:57:50','2026-04-12 13:57:50'),
(96,7,54,'ORD-WKVBYBSV','ai','completed',98186.00,0.00,98186.00,NULL,NULL,'2026-03-04 13:57:50','2026-03-04 13:57:50'),
(97,7,53,'ORD-RSDFTBBL','whatsapp','cancelled',128631.00,0.00,128631.00,NULL,NULL,'2026-02-20 13:57:50','2026-02-20 13:57:50'),
(98,7,46,'ORD-QUP7SPEG','whatsapp','processing',35023.00,0.00,35023.00,NULL,NULL,'2026-03-26 13:57:50','2026-03-26 13:57:50'),
(99,7,55,'ORD-BP9BXOVE','whatsapp','processing',25846.00,4114.00,21732.00,NULL,NULL,'2026-03-24 13:57:50','2026-03-24 13:57:50'),
(100,7,53,'ORD-SHOTZOKB','manual','cancelled',144543.00,4961.00,139582.00,NULL,NULL,'2026-02-22 13:57:50','2026-02-22 13:57:50'),
(101,7,48,'ORD-WN4UXMW2','ai','completed',27285.00,0.00,27285.00,NULL,NULL,'2026-03-27 13:57:50','2026-03-27 13:57:50'),
(102,7,46,'ORD-FJ2XDZEE','ai','cancelled',73535.00,0.00,73535.00,NULL,NULL,'2026-02-19 13:57:50','2026-02-19 13:57:50'),
(103,7,49,'ORD-7GDIPTJF','whatsapp','cancelled',114613.00,1512.00,113101.00,NULL,NULL,'2026-04-12 13:57:50','2026-04-12 13:57:50'),
(104,7,50,'ORD-CO0JYH4A','whatsapp','cancelled',17587.00,0.00,17587.00,NULL,NULL,'2026-03-03 13:57:50','2026-03-03 13:57:50'),
(105,7,47,'ORD-DJ32OBI6','whatsapp','completed',85360.00,1783.00,83577.00,NULL,NULL,'2026-02-15 13:57:50','2026-02-15 13:57:50'),
(106,7,54,'ORD-NCN4UIET','ai','pending',145810.00,0.00,145810.00,NULL,NULL,'2026-03-21 13:57:50','2026-03-21 13:57:50'),
(107,8,61,'ORD-3ASUNVSZ','ai','completed',103918.00,0.00,103918.00,NULL,NULL,'2026-03-08 13:57:50','2026-03-08 13:57:50'),
(108,8,58,'ORD-I3J3MVTT','whatsapp','cancelled',70433.00,0.00,70433.00,NULL,NULL,'2026-03-11 13:57:50','2026-03-11 13:57:50'),
(109,8,57,'ORD-UMXJ4WLZ','ai','cancelled',88513.00,1445.00,87068.00,NULL,NULL,'2026-03-03 13:57:50','2026-03-03 13:57:50'),
(110,8,61,'ORD-D4JUATE1','ai','cancelled',109554.00,0.00,109554.00,NULL,NULL,'2026-02-28 13:57:50','2026-02-28 13:57:50'),
(111,8,61,'ORD-03LZ57BX','whatsapp','pending',30369.00,1969.00,28400.00,NULL,NULL,'2026-02-15 13:57:50','2026-02-15 13:57:50'),
(112,8,57,'ORD-OY84HVVG','manual','processing',129267.00,0.00,129267.00,NULL,NULL,'2026-03-16 13:57:50','2026-03-16 13:57:50'),
(113,8,60,'ORD-9X3IWAKX','manual','completed',61420.00,1179.00,60241.00,NULL,NULL,'2026-02-24 13:57:50','2026-02-24 13:57:50'),
(114,8,61,'ORD-LTNGI7IE','whatsapp','pending',39233.00,0.00,39233.00,NULL,NULL,'2026-04-02 13:57:50','2026-04-02 13:57:50'),
(115,8,59,'ORD-YAFPEEXQ','ai','completed',138086.00,0.00,138086.00,NULL,NULL,'2026-04-09 13:57:50','2026-04-09 13:57:50'),
(116,8,60,'ORD-XHDJDPSU','manual','completed',97473.00,4494.00,92979.00,NULL,NULL,'2026-03-17 13:57:50','2026-03-17 13:57:50'),
(117,8,59,'ORD-CGNEGML7','ai','processing',23685.00,0.00,23685.00,NULL,NULL,'2026-03-19 13:57:50','2026-03-19 13:57:50'),
(118,8,58,'ORD-OSNMTSU2','manual','completed',45894.00,3082.00,42812.00,NULL,NULL,'2026-04-04 13:57:50','2026-04-04 13:57:50'),
(119,8,61,'ORD-5ZV3PWGZ','whatsapp','pending',101508.00,4381.00,97127.00,NULL,NULL,'2026-04-05 13:57:50','2026-04-05 13:57:50'),
(120,9,64,'ORD-6BYVD4UY','whatsapp','processing',127247.00,4349.00,122898.00,NULL,NULL,'2026-04-12 13:57:51','2026-04-12 13:57:51'),
(121,9,67,'ORD-WRWI37HM','whatsapp','completed',18166.00,1113.00,17053.00,NULL,NULL,'2026-04-08 13:57:51','2026-04-08 13:57:51'),
(122,9,67,'ORD-OPCNDJUA','whatsapp','cancelled',54709.00,0.00,54709.00,NULL,NULL,'2026-04-04 13:57:51','2026-04-04 13:57:51'),
(123,9,68,'ORD-UEGGLQDI','ai','pending',39872.00,0.00,39872.00,NULL,NULL,'2026-03-22 13:57:51','2026-03-22 13:57:51'),
(124,9,65,'ORD-CPSIIKYA','whatsapp','completed',37919.00,491.00,37428.00,NULL,NULL,'2026-02-16 13:57:51','2026-02-16 13:57:51'),
(125,9,62,'ORD-Q7Q2AAOE','manual','cancelled',114311.00,4809.00,109502.00,NULL,NULL,'2026-02-16 13:57:51','2026-02-16 13:57:51'),
(126,9,68,'ORD-Y2RDRKJU','ai','completed',6716.00,0.00,6716.00,NULL,NULL,'2026-02-23 13:57:51','2026-02-23 13:57:51'),
(127,9,62,'ORD-SATNC2UT','whatsapp','completed',97392.00,0.00,97392.00,NULL,NULL,'2026-02-13 13:57:51','2026-02-13 13:57:51'),
(128,9,66,'ORD-P4XD4KZT','ai','completed',68713.00,293.00,68420.00,NULL,NULL,'2026-04-08 13:57:51','2026-04-08 13:57:51'),
(129,9,63,'ORD-AMYMSU6H','manual','processing',108685.00,0.00,108685.00,NULL,NULL,'2026-04-01 13:57:51','2026-04-01 13:57:51'),
(130,9,64,'ORD-DIGG4K7K','manual','pending',62065.00,0.00,62065.00,NULL,NULL,'2026-03-11 13:57:51','2026-03-11 13:57:51'),
(131,9,62,'ORD-VPHOLFVT','ai','cancelled',124630.00,0.00,124630.00,NULL,NULL,'2026-03-27 13:57:51','2026-03-27 13:57:51'),
(132,9,64,'ORD-LQQWALY8','manual','completed',108250.00,2604.00,105646.00,NULL,NULL,'2026-03-09 13:57:51','2026-03-09 13:57:51'),
(133,9,66,'ORD-NWIEUHLT','manual','completed',17674.00,0.00,17674.00,NULL,NULL,'2026-04-01 13:57:51','2026-04-01 13:57:51'),
(134,9,63,'ORD-QOLVCI7V','whatsapp','pending',57483.00,4923.00,52560.00,NULL,NULL,'2026-04-06 13:57:51','2026-04-06 13:57:51'),
(135,10,69,'ORD-HWMACAC4','ai','completed',54595.00,3164.00,51431.00,NULL,NULL,'2026-02-14 13:57:51','2026-02-14 13:57:51'),
(136,10,75,'ORD-FTVZP1EN','manual','cancelled',53823.00,0.00,53823.00,NULL,NULL,'2026-02-17 13:57:52','2026-02-17 13:57:52'),
(137,10,72,'ORD-61A6V1JK','ai','completed',98915.00,686.00,98229.00,NULL,NULL,'2026-03-03 13:57:52','2026-03-03 13:57:52'),
(138,10,70,'ORD-VHWKGOEY','ai','completed',66486.00,3759.00,62727.00,NULL,NULL,'2026-04-02 13:57:52','2026-04-02 13:57:52'),
(139,10,75,'ORD-TAEXFBRJ','manual','processing',69879.00,0.00,69879.00,NULL,NULL,'2026-03-29 13:57:52','2026-03-29 13:57:52'),
(140,10,69,'ORD-ONIHIQB4','whatsapp','completed',116745.00,0.00,116745.00,NULL,NULL,'2026-03-09 13:57:52','2026-03-09 13:57:52'),
(141,10,73,'ORD-EBDSBWQ0','ai','processing',124063.00,4275.00,119788.00,NULL,NULL,'2026-04-03 13:57:52','2026-04-03 13:57:52'),
(142,10,69,'ORD-XLCVTR3V','whatsapp','completed',48683.00,3759.00,44924.00,NULL,NULL,'2026-04-04 13:57:52','2026-04-04 13:57:52'),
(143,10,70,'ORD-FJ30NO8Z','manual','processing',66646.00,0.00,66646.00,NULL,NULL,'2026-03-07 13:57:52','2026-03-07 13:57:52'),
(144,10,72,'ORD-LGVBISFT','manual','pending',15428.00,3255.00,12173.00,NULL,NULL,'2026-02-21 13:57:52','2026-02-21 13:57:52'),
(145,10,74,'ORD-FFQN7ET2','whatsapp','completed',115268.00,2714.00,112554.00,NULL,NULL,'2026-03-31 13:57:52','2026-03-31 13:57:52'),
(146,10,72,'ORD-BSQSJSJM','manual','processing',142466.00,0.00,142466.00,NULL,NULL,'2026-03-19 13:57:52','2026-03-19 13:57:52'),
(147,10,74,'ORD-NPOHLZWY','whatsapp','processing',44129.00,549.00,43580.00,NULL,NULL,'2026-03-16 13:57:52','2026-03-16 13:57:52'),
(148,11,78,'ORD-PP1WONIQ','manual','pending',71490.00,447.00,71043.00,NULL,NULL,'2026-04-02 13:57:52','2026-04-02 13:57:52'),
(149,11,81,'ORD-LQHX3YEY','whatsapp','processing',133826.00,0.00,133826.00,NULL,NULL,'2026-03-12 13:57:52','2026-03-12 13:57:52'),
(150,11,82,'ORD-MOKWQ2XW','ai','pending',86496.00,0.00,86496.00,NULL,NULL,'2026-04-03 13:57:52','2026-04-03 13:57:52'),
(151,11,81,'ORD-NVRKLYJ9','manual','processing',98799.00,0.00,98799.00,NULL,NULL,'2026-03-27 13:57:52','2026-03-27 13:57:52'),
(152,11,79,'ORD-5QWNGBXZ','whatsapp','completed',104758.00,953.00,103805.00,NULL,NULL,'2026-03-02 13:57:52','2026-03-02 13:57:52'),
(153,11,81,'ORD-QL1UYDN3','manual','processing',72494.00,2242.00,70252.00,NULL,NULL,'2026-03-22 13:57:52','2026-03-22 13:57:52'),
(154,11,76,'ORD-9QX32FGP','manual','completed',53616.00,2487.00,51129.00,NULL,NULL,'2026-03-05 13:57:52','2026-03-05 13:57:52'),
(155,11,80,'ORD-HQSJY47K','manual','pending',63612.00,734.00,62878.00,NULL,NULL,'2026-03-21 13:57:52','2026-03-21 13:57:52'),
(156,11,80,'ORD-GWFKKOC0','manual','cancelled',121666.00,0.00,121666.00,NULL,NULL,'2026-03-24 13:57:52','2026-03-24 13:57:52'),
(157,11,78,'ORD-YBMVJP1B','manual','pending',21069.00,2724.00,18345.00,NULL,NULL,'2026-04-06 13:57:52','2026-04-06 13:57:52'),
(158,11,77,'ORD-2CIE95IK','whatsapp','completed',29392.00,4990.00,24402.00,NULL,NULL,'2026-03-30 13:57:52','2026-03-30 13:57:52'),
(159,11,78,'ORD-JU3CLUY4','manual','cancelled',13562.00,0.00,13562.00,NULL,NULL,'2026-04-05 13:57:52','2026-04-05 13:57:52'),
(160,11,82,'ORD-HOLTWWIN','ai','cancelled',89778.00,1363.00,88415.00,NULL,NULL,'2026-04-03 13:57:52','2026-04-03 13:57:52'),
(161,11,82,'ORD-DGIGVA6B','whatsapp','completed',52840.00,0.00,52840.00,NULL,NULL,'2026-03-23 13:57:52','2026-03-23 13:57:52'),
(162,11,77,'ORD-JMRM25MJ','manual','processing',120433.00,1411.00,119022.00,NULL,NULL,'2026-03-07 13:57:52','2026-03-07 13:57:52'),
(163,12,84,'ORD-DZHFKQAO','manual','processing',30431.00,0.00,30431.00,NULL,NULL,'2026-03-27 13:57:52','2026-03-27 13:57:52'),
(164,12,85,'ORD-DTVZPPYP','whatsapp','cancelled',110269.00,691.00,109578.00,NULL,NULL,'2026-04-03 13:57:52','2026-04-03 13:57:52'),
(165,12,86,'ORD-WBMYXT5P','whatsapp','cancelled',39411.00,3140.00,36271.00,NULL,NULL,'2026-04-10 13:57:52','2026-04-10 13:57:52'),
(166,12,89,'ORD-DHOMNAUQ','manual','completed',35575.00,0.00,35575.00,NULL,NULL,'2026-02-19 13:57:52','2026-02-19 13:57:52'),
(167,12,83,'ORD-F1P0WH0F','manual','completed',70618.00,0.00,70618.00,NULL,NULL,'2026-02-24 13:57:52','2026-02-24 13:57:52'),
(168,12,86,'ORD-VBHN8CFJ','ai','pending',130289.00,4233.00,126056.00,NULL,NULL,'2026-04-05 13:57:52','2026-04-05 13:57:52'),
(169,12,90,'ORD-JQDERJ27','whatsapp','pending',89623.00,0.00,89623.00,NULL,NULL,'2026-04-13 13:57:52','2026-04-13 13:57:52'),
(170,12,89,'ORD-Z7LRAS2I','ai','completed',70718.00,2817.00,67901.00,NULL,NULL,'2026-04-04 13:57:52','2026-04-04 13:57:52'),
(171,12,89,'ORD-VBUBTTDR','ai','pending',89627.00,0.00,89627.00,NULL,NULL,'2026-03-23 13:57:52','2026-03-23 13:57:52'),
(172,12,88,'ORD-HMK6AX6E','ai','completed',89514.00,3797.00,85717.00,NULL,NULL,'2026-03-02 13:57:52','2026-03-02 13:57:52'),
(173,12,89,'ORD-YRPCWBZZ','whatsapp','completed',99576.00,0.00,99576.00,NULL,NULL,'2026-04-14 13:57:52','2026-04-14 13:57:52'),
(174,13,91,'ORD-EXOBE5AN','ai','completed',119260.00,1651.00,117609.00,NULL,NULL,'2026-03-14 13:57:53','2026-03-14 13:57:53'),
(175,13,92,'ORD-OZJB25U9','manual','cancelled',137679.00,459.00,137220.00,NULL,NULL,'2026-02-14 13:57:53','2026-02-14 13:57:53'),
(176,13,95,'ORD-WJTVK7HG','ai','completed',9062.00,2486.00,6576.00,NULL,NULL,'2026-02-21 13:57:53','2026-02-21 13:57:53'),
(177,13,94,'ORD-XDYGH8Y5','ai','completed',30734.00,0.00,30734.00,NULL,NULL,'2026-03-13 13:57:53','2026-03-13 13:57:53'),
(178,13,92,'ORD-2UWRYRWL','whatsapp','completed',39918.00,3576.00,36342.00,NULL,NULL,'2026-03-06 13:57:53','2026-03-06 13:57:53'),
(179,13,91,'ORD-TLM3ILRD','whatsapp','completed',41354.00,0.00,41354.00,NULL,NULL,'2026-02-28 13:57:53','2026-02-28 13:57:53'),
(180,13,96,'ORD-3BSCTV0K','whatsapp','cancelled',124192.00,337.00,123855.00,NULL,NULL,'2026-02-15 13:57:53','2026-02-15 13:57:53'),
(181,13,94,'ORD-2DHZDMAQ','ai','pending',15303.00,3365.00,11938.00,NULL,NULL,'2026-02-21 13:57:53','2026-02-21 13:57:53'),
(182,13,95,'ORD-SVZX5IV2','whatsapp','completed',131256.00,2783.00,128473.00,NULL,NULL,'2026-03-14 13:57:53','2026-03-14 13:57:53'),
(183,13,92,'ORD-W2NANXMZ','manual','processing',53697.00,1394.00,52303.00,NULL,NULL,'2026-04-03 13:57:53','2026-04-03 13:57:53'),
(184,13,92,'ORD-NWNNQMLT','ai','pending',109914.00,0.00,109914.00,NULL,NULL,'2026-02-24 13:57:53','2026-02-24 13:57:53'),
(185,13,94,'ORD-SNSVPLZ6','ai','completed',11611.00,0.00,11611.00,NULL,NULL,'2026-04-09 13:57:53','2026-04-09 13:57:53'),
(186,13,95,'ORD-6UTABEYR','ai','completed',69231.00,0.00,69231.00,NULL,NULL,'2026-02-22 13:57:53','2026-02-22 13:57:53'),
(187,13,93,'ORD-BKHT7MSE','whatsapp','pending',42770.00,1337.00,41433.00,NULL,NULL,'2026-02-13 13:57:53','2026-02-13 13:57:53');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(12,2) NOT NULL DEFAULT 0.00,
  `cost_price` decimal(12,2) NOT NULL DEFAULT 0.00,
  `stock` int(11) NOT NULL DEFAULT 0,
  `low_stock_threshold` int(11) NOT NULL DEFAULT 5,
  `category` varchar(255) DEFAULT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `products_tenant_id_is_active_index` (`tenant_id`,`is_active`),
  CONSTRAINT `products_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES
(1,2,'Rice 50kg',NULL,35979.00,25185.00,120,10,'Gas','JTSPXAWB',NULL,1,NULL,'2026-03-16 13:55:44','2026-04-14 13:55:44'),
(2,2,'Palm Oil 5L',NULL,30906.00,21634.00,192,10,'Beverages','KH4EGHJJ',NULL,1,NULL,'2026-04-08 13:55:44','2026-04-14 13:55:44'),
(3,2,'Sugar 10kg',NULL,35758.00,25030.00,76,10,'Household','JHRHPIV6',NULL,1,NULL,'2026-03-07 13:55:44','2026-04-14 13:55:44'),
(4,2,'Flour 25kg',NULL,30642.00,21449.00,145,10,'Household','GYZF8CZH',NULL,1,NULL,'2026-03-29 13:55:44','2026-04-14 13:55:44'),
(5,2,'Milk 1L',NULL,25598.00,17918.00,166,10,'Groceries','YVECL308',NULL,1,NULL,'2026-04-13 13:55:44','2026-04-14 13:55:44'),
(6,2,'Soap Bar',NULL,39042.00,27329.00,73,10,'Beverages','85VPVGVP',NULL,1,NULL,'2026-02-19 13:55:44','2026-04-14 13:55:44'),
(7,2,'Detergent 1kg',NULL,11874.00,8311.00,180,10,'Groceries','1Q5RT6LD',NULL,1,NULL,'2026-03-31 13:55:44','2026-04-14 13:55:44'),
(8,3,'Rice 50kg',NULL,39212.00,27448.00,199,10,'Household','VL6XJURH',NULL,1,NULL,'2026-04-02 13:57:48','2026-04-14 13:57:48'),
(9,3,'Palm Oil 5L',NULL,38482.00,26937.00,17,10,'Gas','XFRE47SP',NULL,1,NULL,'2026-02-26 13:57:48','2026-04-14 13:57:48'),
(10,3,'Sugar 10kg',NULL,45723.00,32006.00,31,10,'Beverages','DDKGJYIQ',NULL,1,NULL,'2026-04-02 13:57:48','2026-04-14 13:57:48'),
(11,3,'Flour 25kg',NULL,46440.00,32507.00,177,10,'Groceries','FJ8XL2OQ',NULL,1,NULL,'2026-03-06 13:57:48','2026-04-14 13:57:48'),
(12,4,'Rice 50kg',NULL,43720.00,30603.00,142,10,'Household','YRAGWQ3S',NULL,1,NULL,'2026-03-17 13:57:48','2026-04-14 13:57:48'),
(13,4,'Palm Oil 5L',NULL,45366.00,31756.00,192,10,'Gas','JIXIOATV',NULL,1,NULL,'2026-03-30 13:57:48','2026-04-14 13:57:48'),
(14,4,'Sugar 10kg',NULL,17888.00,12521.00,32,10,'Groceries','LQTF2VBX',NULL,1,NULL,'2026-03-23 13:57:48','2026-04-14 13:57:48'),
(15,4,'Flour 25kg',NULL,42085.00,29459.00,25,10,'Gas','4T1HKS7Z',NULL,1,NULL,'2026-03-21 13:57:48','2026-04-14 13:57:48'),
(16,4,'Milk 1L',NULL,47164.00,33014.00,124,10,'Groceries','EBZYGGZ0',NULL,1,NULL,'2026-03-05 13:57:48','2026-04-14 13:57:48'),
(17,4,'Soap Bar',NULL,30838.00,21586.00,105,10,'Beverages','4NBT9Y73',NULL,1,NULL,'2026-02-15 13:57:48','2026-04-14 13:57:48'),
(18,4,'Detergent 1kg',NULL,35745.00,25021.00,87,10,'Beverages','QDEAKCVT',NULL,1,NULL,'2026-03-12 13:57:48','2026-04-14 13:57:48'),
(19,4,'Cooking Gas 12.5kg',NULL,38217.00,26751.00,4,10,'Groceries','X03JZKPI',NULL,1,NULL,'2026-04-08 13:57:48','2026-04-14 13:57:48'),
(20,5,'Rice 50kg',NULL,15459.00,10821.00,21,10,'Groceries','FI3QTJDL',NULL,1,NULL,'2026-04-06 13:57:48','2026-04-14 13:57:48'),
(21,5,'Palm Oil 5L',NULL,14007.00,9804.00,22,10,'Beverages','C4UADZMW',NULL,1,NULL,'2026-03-20 13:57:48','2026-04-14 13:57:48'),
(22,5,'Sugar 10kg',NULL,1486.00,1040.00,99,10,'Beverages','UXFM2ORP',NULL,1,NULL,'2026-02-16 13:57:48','2026-04-14 13:57:48'),
(23,5,'Flour 25kg',NULL,32527.00,22768.00,101,10,'Groceries','YNKXNKYL',NULL,1,NULL,'2026-02-23 13:57:48','2026-04-14 13:57:48'),
(24,5,'Milk 1L',NULL,31854.00,22297.00,141,10,'Beverages','1KLBYCZW',NULL,1,NULL,'2026-03-09 13:57:48','2026-04-14 13:57:48'),
(25,5,'Soap Bar',NULL,20832.00,14582.00,137,10,'Groceries','DARWITP2',NULL,1,NULL,'2026-03-11 13:57:48','2026-04-14 13:57:48'),
(26,5,'Detergent 1kg',NULL,12040.00,8428.00,151,10,'Groceries','CKDCZ1ON',NULL,1,NULL,'2026-03-31 13:57:48','2026-04-14 13:57:48'),
(27,5,'Cooking Gas 12.5kg',NULL,21384.00,14968.00,78,10,'Beverages','6BSR6DCT',NULL,1,NULL,'2026-02-18 13:57:48','2026-04-14 13:57:48'),
(28,6,'Rice 50kg',NULL,14019.00,9813.00,131,10,'Beverages','MCB7CX2V',NULL,1,NULL,'2026-04-04 13:57:49','2026-04-14 13:57:49'),
(29,6,'Palm Oil 5L',NULL,30284.00,21198.00,83,10,'Beverages','WF5VZWWD',NULL,1,NULL,'2026-03-08 13:57:49','2026-04-14 13:57:49'),
(30,6,'Sugar 10kg',NULL,5567.00,3896.00,69,10,'Gas','TPOUCBS8',NULL,1,NULL,'2026-03-30 13:57:49','2026-04-14 13:57:49'),
(31,6,'Flour 25kg',NULL,24341.00,17038.00,47,10,'Household','ABMG9HU9',NULL,1,NULL,'2026-03-30 13:57:49','2026-04-14 13:57:49'),
(32,6,'Milk 1L',NULL,30634.00,21443.00,167,10,'Beverages','V9QQKMLY',NULL,1,NULL,'2026-03-10 13:57:49','2026-04-14 13:57:49'),
(33,7,'Rice 50kg',NULL,29220.00,20454.00,166,10,'Groceries','OWDUJKIT',NULL,1,NULL,'2026-03-04 13:57:49','2026-04-14 13:57:49'),
(34,7,'Palm Oil 5L',NULL,39766.00,27836.00,104,10,'Beverages','WSDV1OOJ',NULL,1,NULL,'2026-02-27 13:57:49','2026-04-14 13:57:49'),
(35,7,'Sugar 10kg',NULL,27168.00,19017.00,199,10,'Gas','3NKWLZRH',NULL,1,NULL,'2026-04-03 13:57:49','2026-04-14 13:57:49'),
(36,8,'Rice 50kg',NULL,8274.00,5791.00,144,10,'Gas','RAUO7ZKN',NULL,1,NULL,'2026-03-29 13:57:50','2026-04-14 13:57:50'),
(37,8,'Palm Oil 5L',NULL,19814.00,13869.00,195,10,'Groceries','EFHBDIGN',NULL,1,NULL,'2026-02-13 13:57:50','2026-04-14 13:57:50'),
(38,8,'Sugar 10kg',NULL,38789.00,27152.00,37,10,'Household','KLX6EOK0',NULL,1,NULL,'2026-03-18 13:57:50','2026-04-14 13:57:50'),
(39,8,'Flour 25kg',NULL,45813.00,32069.00,74,10,'Beverages','UICNDSTC',NULL,1,NULL,'2026-04-02 13:57:50','2026-04-14 13:57:50'),
(40,8,'Milk 1L',NULL,17472.00,12230.00,1,10,'Beverages','5RNSRDMA',NULL,1,NULL,'2026-02-21 13:57:50','2026-04-14 13:57:50'),
(41,8,'Soap Bar',NULL,32882.00,23017.00,117,10,'Gas','RIQEDQI4',NULL,1,NULL,'2026-03-23 13:57:50','2026-04-14 13:57:50'),
(42,8,'Detergent 1kg',NULL,46074.00,32251.00,127,10,'Gas','DUFHQQ10',NULL,1,NULL,'2026-04-12 13:57:50','2026-04-14 13:57:50'),
(43,8,'Cooking Gas 12.5kg',NULL,27968.00,19577.00,59,10,'Beverages','YNLEWICI',NULL,1,NULL,'2026-03-02 13:57:50','2026-04-14 13:57:50'),
(44,9,'Rice 50kg',NULL,14143.00,9900.00,181,10,'Household','CBBFG30Y',NULL,1,NULL,'2026-02-24 13:57:50','2026-04-14 13:57:50'),
(45,9,'Palm Oil 5L',NULL,15194.00,10635.00,149,10,'Beverages','NUEWZKPK',NULL,1,NULL,'2026-02-28 13:57:50','2026-04-14 13:57:50'),
(46,9,'Sugar 10kg',NULL,10728.00,7509.00,173,10,'Household','I7RUBVIP',NULL,1,NULL,'2026-04-04 13:57:50','2026-04-14 13:57:50'),
(47,9,'Flour 25kg',NULL,32358.00,22650.00,131,10,'Beverages','T7FGUUOI',NULL,1,NULL,'2026-03-12 13:57:50','2026-04-14 13:57:50'),
(48,9,'Milk 1L',NULL,10696.00,7487.00,66,10,'Household','MVLQZL80',NULL,1,NULL,'2026-03-17 13:57:50','2026-04-14 13:57:50'),
(49,9,'Soap Bar',NULL,33322.00,23325.00,148,10,'Groceries','ZPGJOH5Y',NULL,1,NULL,'2026-03-05 13:57:50','2026-04-14 13:57:50'),
(50,9,'Detergent 1kg',NULL,1136.00,795.00,179,10,'Household','KDYGTTON',NULL,1,NULL,'2026-04-03 13:57:50','2026-04-14 13:57:50'),
(51,10,'Rice 50kg',NULL,37236.00,26065.00,63,10,'Household','PWHSASIP',NULL,1,NULL,'2026-03-26 13:57:51','2026-04-14 13:57:51'),
(52,10,'Palm Oil 5L',NULL,39356.00,27549.00,198,10,'Gas','JFSO7MM9',NULL,1,NULL,'2026-02-14 13:57:51','2026-04-14 13:57:51'),
(53,10,'Sugar 10kg',NULL,17410.00,12187.00,24,10,'Groceries','PCUSXRPD',NULL,1,NULL,'2026-02-27 13:57:51','2026-04-14 13:57:51'),
(54,10,'Flour 25kg',NULL,18922.00,13245.00,53,10,'Household','LG9MFTCT',NULL,1,NULL,'2026-02-15 13:57:51','2026-04-14 13:57:51'),
(55,10,'Milk 1L',NULL,18236.00,12765.00,128,10,'Groceries','KBTUYUSS',NULL,1,NULL,'2026-03-23 13:57:51','2026-04-14 13:57:51'),
(56,10,'Soap Bar',NULL,30461.00,21322.00,16,10,'Gas','EB2DN1BI',NULL,1,NULL,'2026-03-09 13:57:51','2026-04-14 13:57:51'),
(57,11,'Rice 50kg',NULL,49314.00,34519.00,149,10,'Gas','CG4FWJ3V',NULL,1,NULL,'2026-02-19 13:57:52','2026-04-14 13:57:52'),
(58,11,'Palm Oil 5L',NULL,38532.00,26972.00,173,10,'Beverages','NCYERHGU',NULL,1,NULL,'2026-03-03 13:57:52','2026-04-14 13:57:52'),
(59,11,'Sugar 10kg',NULL,25331.00,17731.00,145,10,'Beverages','PTJTAYGZ',NULL,1,NULL,'2026-02-22 13:57:52','2026-04-14 13:57:52'),
(60,11,'Flour 25kg',NULL,21138.00,14796.00,20,10,'Household','6RN4IVED',NULL,1,NULL,'2026-04-11 13:57:52','2026-04-14 13:57:52'),
(61,11,'Milk 1L',NULL,41148.00,28803.00,12,10,'Groceries','IYRJDJML',NULL,1,NULL,'2026-03-21 13:57:52','2026-04-14 13:57:52'),
(62,11,'Soap Bar',NULL,927.00,648.00,163,10,'Household','AK4QEAM7',NULL,1,NULL,'2026-04-05 13:57:52','2026-04-14 13:57:52'),
(63,11,'Detergent 1kg',NULL,29483.00,20638.00,158,10,'Household','7GXUYIGA',NULL,1,NULL,'2026-03-28 13:57:52','2026-04-14 13:57:52'),
(64,11,'Cooking Gas 12.5kg',NULL,2221.00,1554.00,79,10,'Household','QXZNB4NJ',NULL,1,NULL,'2026-03-02 13:57:52','2026-04-14 13:57:52'),
(65,12,'Rice 50kg',NULL,18281.00,12796.00,130,10,'Beverages','4ZRMHMM0',NULL,1,NULL,'2026-03-21 13:57:52','2026-04-14 13:57:52'),
(66,12,'Palm Oil 5L',NULL,4011.00,2807.00,147,10,'Groceries','CVRXDBAL',NULL,1,NULL,'2026-03-14 13:57:52','2026-04-14 13:57:52'),
(67,12,'Sugar 10kg',NULL,7900.00,5530.00,131,10,'Household','P1LM1YLR',NULL,1,NULL,'2026-03-28 13:57:52','2026-04-14 13:57:52'),
(68,12,'Flour 25kg',NULL,36951.00,25865.00,184,10,'Household','TLM1AQMH',NULL,1,NULL,'2026-04-09 13:57:52','2026-04-14 13:57:52'),
(69,12,'Milk 1L',NULL,11769.00,8238.00,93,10,'Gas','5EXJCMGC',NULL,1,NULL,'2026-03-21 13:57:52','2026-04-14 13:57:52'),
(70,13,'Rice 50kg',NULL,35489.00,24842.00,39,10,'Groceries','K1R1CI2R',NULL,1,NULL,'2026-02-23 13:57:52','2026-04-14 13:57:52'),
(71,13,'Palm Oil 5L',NULL,23050.00,16134.00,192,10,'Groceries','HAUN7S5Z',NULL,1,NULL,'2026-03-17 13:57:52','2026-04-14 13:57:52'),
(72,13,'Sugar 10kg',NULL,38904.00,27232.00,185,10,'Beverages','OXLORQ7X',NULL,1,NULL,'2026-03-18 13:57:52','2026-04-14 13:57:52'),
(73,13,'Flour 25kg',NULL,29624.00,20736.00,154,10,'Gas','FXXKNODA',NULL,1,NULL,'2026-03-09 13:57:52','2026-04-14 13:57:52'),
(74,13,'Milk 1L',NULL,11697.00,8187.00,43,10,'Beverages','QJMT2OGK',NULL,1,NULL,'2026-03-14 13:57:52','2026-04-14 13:57:52'),
(75,13,'Soap Bar',NULL,12862.00,9003.00,93,10,'Gas','3V3UKDVZ',NULL,1,NULL,'2026-04-01 13:57:52','2026-04-14 13:57:52');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prompts`
--

DROP TABLE IF EXISTS `prompts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `prompts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(100) NOT NULL,
  `name` varchar(150) NOT NULL,
  `agent_type` varchar(50) NOT NULL,
  `version` smallint(5) unsigned NOT NULL DEFAULT 1,
  `content` longtext NOT NULL,
  `variables` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`variables`)),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prompts_slug_version_unique` (`slug`,`version`),
  KEY `prompts_slug_index` (`slug`),
  KEY `prompts_agent_type_index` (`agent_type`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prompts`
--

LOCK TABLES `prompts` WRITE;
/*!40000 ALTER TABLE `prompts` DISABLE KEYS */;
INSERT INTO `prompts` VALUES
(1,'customer_agent','Customer Agent v1','customer_agent',1,'You are a friendly and efficient WhatsApp customer service agent for {{store_name}}.\r\nYour job is to help customers with product inquiries, place orders, check order status, and resolve complaints.\r\n\r\nSTRICT RULES:\r\n1. Keep ALL responses under 3 sentences — this is WhatsApp, not email\r\n2. Always use a warm, conversational tone (not robotic)\r\n3. ALWAYS use tools to get real product data — NEVER make up prices, stock, or product names\r\n4. Before placing any order, confirm: item, quantity, and total cost\r\n5. Ask one follow-up question at a time if you need more information\r\n6. For complaints, acknowledge, apologize briefly, and offer a solution\r\n\r\nTOOL USAGE:\r\n- Use `get_product` or `search_products` before answering ANY product question\r\n- Use `get_customer_history` to personalize responses for returning customers\r\n- Use `create_order` ONLY after customer explicitly confirms the order\r\n\r\nRESPONSE FORMAT for WhatsApp:\r\n- Use emojis sparingly (1-2 per message max)\r\n- No long paragraphs — short, punchy sentences\r\n- End with a question or clear next step\r\n\r\nCONTEXT: Store={{store_name}} | Customer={{customer_phone}} | Time={{datetime}}','[\"store_name\",\"customer_phone\",\"datetime\"]',1,'2026-04-04 15:35:05','2026-04-04 15:35:05'),
(2,'inventory_agent','Inventory Agent v1','inventory_agent',1,'You are a precise inventory monitoring agent for {{store_name}}.\r\nYour role is to analyze stock levels, flag critical shortages, and recommend restock quantities.\r\n\r\nRULES:\r\n1. ALWAYS fetch current data using tools before making any statements\r\n2. Flag items at or below threshold as CRITICAL\r\n3. Suggest reorder quantities = (threshold × 3) as a safe buffer\r\n4. Present data in a structured, scannable format\r\n5. Be precise with numbers — no estimates unless clearly labeled\r\n\r\nOUTPUT FORMAT:\r\n- Start with a summary: X products low, Y out of stock\r\n- List critical items by priority (most depleted first)\r\n- End with a concrete restock recommendation\r\n\r\nCONTEXT: Store={{store_name}} | Time={{datetime}}','[\"store_name\",\"datetime\"]',1,'2026-04-04 15:35:05','2026-04-04 15:35:05'),
(3,'customer_intelligence_agent','Customer Intelligence Agent v1','customer_intelligence_agent',1,'You are a customer intelligence analyst for {{store_name}}.\r\nYour role is to analyze purchase patterns, predict reorder cycles, and identify high-value customers.\r\n\r\nRULES:\r\n1. Base ALL insights on real data from tools — never assume patterns\r\n2. State confidence levels when making predictions (High/Medium/Low)\r\n3. Focus on actionable insights that drive revenue\r\n4. Identify: top customers, top products, churn risk, reorder opportunities\r\n\r\nANALYSIS STRUCTURE:\r\n1. Key findings (bullet points)\r\n2. High-value customer segments\r\n3. Reorder predictions with dates\r\n4. Recommended actions\r\n\r\nCONTEXT: Store={{store_name}} | Time={{datetime}}','[\"store_name\",\"datetime\"]',1,'2026-04-04 15:35:05','2026-04-04 15:35:05'),
(4,'automation_agent','Automation Agent v1','automation_agent',1,'You are an automation agent for {{store_name}}.\r\nYour role is to send personalized WhatsApp messages for reminders, follow-ups, reorder nudges, and promotions.\r\n\r\nRULES:\r\n1. Always fetch customer history before crafting a message — personalize everything\r\n2. Keep all WhatsApp messages under 3 sentences\r\n3. Reference the customer\'s last purchase to make messages feel personal\r\n4. Never send duplicate reminders — check history first\r\n5. Be warm and helpful, not pushy or salesy\r\n\r\nMESSAGE TYPES:\r\n- Reorder reminder: \"Hey [name], you last ordered [product] X days ago. Running low? 😊\"\r\n- Follow-up: \"How did you enjoy your recent order from {{store_name}}?\"\r\n- Upsell: \"Based on your [product] purchase, you might love [related product]!\"\r\n\r\nCONTEXT: Store={{store_name}} | Time={{datetime}}','[\"store_name\",\"datetime\"]',1,'2026-04-04 15:35:05','2026-04-04 15:35:05');
/*!40000 ALTER TABLE `prompts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_has_permissions`
--

DROP TABLE IF EXISTS `role_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_has_permissions` (
  `permission_id` bigint(20) unsigned NOT NULL,
  `role_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`role_id`),
  KEY `role_has_permissions_role_id_foreign` (`role_id`),
  CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_has_permissions`
--

LOCK TABLES `role_has_permissions` WRITE;
/*!40000 ALTER TABLE `role_has_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES
(1,'super_admin','web','2026-04-04 15:00:29','2026-04-04 15:00:29'),
(2,'tenant_admin','web','2026-04-04 15:00:29','2026-04-04 15:00:29');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_events`
--

DROP TABLE IF EXISTS `subscription_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscription_events` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `event_type` enum('activated','expired','renewed','suspended','upgraded','downgraded') NOT NULL,
  `plan_type` varchar(255) DEFAULT NULL,
  `effective_at` timestamp NULL DEFAULT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscription_events_tenant_id_event_type_index` (`tenant_id`,`event_type`),
  CONSTRAINT `subscription_events_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_events`
--

LOCK TABLES `subscription_events` WRITE;
/*!40000 ALTER TABLE `subscription_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscription_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sync_logs`
--

DROP TABLE IF EXISTS `sync_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sync_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned DEFAULT NULL,
  `sync_type` varchar(255) NOT NULL,
  `status` enum('success','failed','partial') NOT NULL DEFAULT 'success',
  `records_synced` int(11) NOT NULL DEFAULT 0,
  `message` text DEFAULT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sync_logs_tenant_id_sync_type_index` (`tenant_id`,`sync_type`),
  CONSTRAINT `sync_logs_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sync_logs`
--

LOCK TABLES `sync_logs` WRITE;
/*!40000 ALTER TABLE `sync_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `sync_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taskboard_columns`
--

DROP TABLE IF EXISTS `taskboard_columns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `taskboard_columns` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int(10) unsigned DEFAULT NULL,
  `column_name` varchar(191) NOT NULL,
  `slug` varchar(191) DEFAULT NULL,
  `label_color` varchar(191) NOT NULL,
  `priority` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taskboard_columns_column_name_unique` (`column_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taskboard_columns`
--

LOCK TABLES `taskboard_columns` WRITE;
/*!40000 ALTER TABLE `taskboard_columns` DISABLE KEYS */;
/*!40000 ALTER TABLE `taskboard_columns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tenants`
--

DROP TABLE IF EXISTS `tenants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenants` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `website_id` int(10) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `owner_email` varchar(255) DEFAULT NULL,
  `email_reports_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `plan` varchar(255) NOT NULL DEFAULT 'starter',
  `plan_type` varchar(255) NOT NULL DEFAULT 'free',
  `subscription_status` varchar(255) NOT NULL DEFAULT 'inactive',
  `subscription_start` timestamp NULL DEFAULT NULL,
  `subscription_end` timestamp NULL DEFAULT NULL,
  `api_key` varchar(64) DEFAULT NULL,
  `api_secret` varchar(64) DEFAULT NULL,
  `status` enum('active','suspended','pending') NOT NULL DEFAULT 'pending',
  `logo` varchar(255) DEFAULT NULL,
  `timezone` varchar(255) NOT NULL DEFAULT 'UTC',
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tenants_email_unique` (`email`),
  UNIQUE KEY `tenants_api_key_unique` (`api_key`),
  KEY `tenants_website_id_index` (`website_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenants`
--

LOCK TABLES `tenants` WRITE;
/*!40000 ALTER TABLE `tenants` DISABLE KEYS */;
INSERT INTO `tenants` VALUES
(1,NULL,'Demo Store','demo@store.com','+2348000000000',NULL,0,'pro','free','inactive',NULL,NULL,NULL,NULL,'active',NULL,'UTC',NULL,'2026-04-04 15:00:29','2026-04-04 15:00:29'),
(2,NULL,'MegaMart Lagos','info@megamart.ng',NULL,NULL,0,'enterprise','enterprise','active','2026-03-26 13:55:36','2027-01-17 13:55:36','xYCqlghbUQzXJ9AcqLawYP3xT7FQ0JMR','JRPGvv716d0YAU3U3EqpcoeztM2BYojz','active',NULL,'Africa/Lagos',NULL,'2025-11-15 13:55:36','2026-04-14 13:55:36'),
(3,NULL,'QuickShop Abuja','hello@quickshop.ng',NULL,NULL,0,'pro','pro','active','2026-01-25 13:55:36','2027-01-06 13:55:36','K7Ej8PDDNODF2NFC3YG0OrotIKKOSnIJ','CCvr1yYKNpj8kEZAX2l6oIXUP44QRMUL','active',NULL,'Africa/Lagos',NULL,'2025-11-07 13:55:36','2026-04-14 13:55:36'),
(4,NULL,'FreshGrocer PH','sales@freshgrocer.ng',NULL,NULL,0,'pro','pro','active','2026-03-25 13:55:36','2027-01-03 13:55:36','d5nI2QqJMrybWNACT5zVCaF5VxlVtt3a','BM8SN9Buoq2gnq8SXB4aQuVXCjPpHtRy','active',NULL,'Africa/Lagos',NULL,'2026-03-05 13:55:36','2026-04-14 13:55:36'),
(5,NULL,'TechZone Kano','admin@techzone.ng',NULL,NULL,0,'starter','starter','active','2026-02-21 13:55:36','2026-07-28 13:55:36','X8r0dePcNEMCxP955xVmaG1jGCwlEYuZ','koa3c6OtdG7EQWNKycrn6OUkZJ156EfP','active',NULL,'Africa/Lagos',NULL,'2026-02-20 13:55:36','2026-04-14 13:55:36'),
(6,NULL,'FashionHub Ibadan','team@fashionhub.ng',NULL,NULL,0,'pro','pro','active','2026-03-30 13:55:36','2026-10-23 13:55:36','1WnglABcEKlzWSfGS4M2VPUDTzwxS5NL','Yk4hj2bUoVDz2EPsHhvu2d4ZES29HCti','active',NULL,'Africa/Lagos',NULL,'2025-12-20 13:55:36','2026-04-14 13:55:36'),
(7,NULL,'AutoParts Benin','orders@autoparts.ng',NULL,NULL,0,'enterprise','enterprise','active','2026-01-20 13:55:36','2026-10-22 13:55:36','tkU7JicTGG4v33WeqIbVo6NdZ0nEKbDU','MQL6pUTCAJMrnFiFWEfQjJK3svph9Uox','active',NULL,'Africa/Lagos',NULL,'2026-03-16 13:55:36','2026-04-14 13:55:36'),
(8,NULL,'GreenFarms Ilorin','hi@greenfarms.ng',NULL,NULL,0,'starter','starter','active','2026-03-25 13:55:36','2027-01-11 13:55:36','KQL0pM5JH1NOK6vebf7BsjYT6ctWp3YC','tH4LD0L9NKrELiLz4mZlkiNOrk7QTezA','active',NULL,'Africa/Lagos',NULL,'2026-01-31 13:55:36','2026-04-14 13:55:36'),
(9,NULL,'BookWorld Enugu','shop@bookworld.ng',NULL,NULL,0,'starter','starter','inactive','2026-01-23 13:55:36','2026-06-13 13:55:36','endEAEIivT6fj2OlvP7FPvkjhb5XV8tg','ElBPdULtYnvqoC5iPLIMrfd22cY2HqfU','pending',NULL,'Africa/Lagos',NULL,'2026-02-13 13:55:36','2026-04-14 13:55:36'),
(10,NULL,'PharmaCare Jos','rx@pharmacare.ng',NULL,NULL,0,'pro','pro','active','2026-04-06 13:55:36','2026-08-25 13:55:36','ccGsZMq9LBOp3cgWFzyfPS71rzJLPsHF','BizB662p3hLVwQgDc5ML8dREOAniuIzf','active',NULL,'Africa/Lagos',NULL,'2025-11-22 13:55:36','2026-04-14 13:55:36'),
(11,NULL,'HomeStyle Warri','info@homestyle.ng',NULL,NULL,0,'starter','starter','active','2026-02-12 13:55:36','2026-08-18 13:55:36','60B0A8Mw8K6H9PaUbSivtDPhB1YqhFlc','HLDbmuZWwJjNG8YKmS73qyTm4Gxgy0Cj','active',NULL,'Africa/Lagos',NULL,'2025-12-28 13:55:36','2026-04-14 13:55:36'),
(12,NULL,'SportZone Abeokuta','play@sportzone.ng',NULL,NULL,0,'pro','pro','active','2026-01-26 13:55:36','2026-12-07 13:55:36','WbBEnKqIlS7967CkXX71NOyIXDJbi7Ve','yPtI4fUUS8SxjbdSucgeZSpuUAYva1LQ','active',NULL,'Africa/Lagos',NULL,'2026-02-01 13:55:36','2026-04-14 13:55:36'),
(13,NULL,'BeautySpot Owerri','glow@beautyspot.ng',NULL,NULL,0,'enterprise','enterprise','active','2026-01-28 13:55:36','2027-03-11 13:55:36','kJRq4Tu20VokwbfTrg7CXawDPbEJkdp9','SWC9bN8RyPWsw2CiZjOMuv9jebK4r8Gh','active',NULL,'Africa/Lagos',NULL,'2026-02-07 13:55:36','2026-04-14 13:55:36');
/*!40000 ALTER TABLE `tenants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tool_logs`
--

DROP TABLE IF EXISTS `tool_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tool_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned DEFAULT NULL,
  `tool_name` varchar(255) NOT NULL,
  `input` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`input`)),
  `output` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`output`)),
  `duration_ms` int(11) NOT NULL DEFAULT 0,
  `status` enum('success','error') NOT NULL DEFAULT 'success',
  `error_message` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tool_logs_tenant_id_tool_name_index` (`tenant_id`,`tool_name`),
  CONSTRAINT `tool_logs_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tool_logs`
--

LOCK TABLES `tool_logs` WRITE;
/*!40000 ALTER TABLE `tool_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `tool_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_tenant_id_foreign` (`tenant_id`),
  CONSTRAINT `users_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,NULL,'Super Admin','admin@airetail.com',NULL,'$2y$12$/a9unoMYKHo/xlMwgagBd.4WsNQsd/x2JyUCRLTdUGAQJEPPYq5NW','gpPTqPNtL2SPfsS3CLGU6Wlh0omKqR7yQMmpZ6EmyTxp7h48adOHI4Eek3Gs','2026-04-04 15:00:29','2026-04-14 14:24:31'),
(2,1,'Store Owner','store@airetail.com',NULL,'$2y$12$wZXKMNwke/GmQc/uDWUU.uUpqgHFxHieP/XCC4ciu7lwD1CL97DTi',NULL,'2026-04-04 15:00:30','2026-04-04 15:00:30'),
(3,2,'Manager at MegaMart Lagos','user@megamart.ng',NULL,'$2y$12$OuH5UDGgfO2CQbB97qB9XO2vy1JOD.8GkJGTOVB9Exx1ZBbaAAcU.',NULL,'2025-11-15 13:55:36','2026-04-14 13:55:37'),
(4,3,'Manager at QuickShop Abuja','user@quickshop.ng',NULL,'$2y$12$VczlwR73kqe8C/RgAq/VfuJsIj7uYdIGxL8yCC/NfWk1hm0o9o6qW',NULL,'2025-11-07 13:55:36','2026-04-14 13:55:38'),
(5,4,'Manager at FreshGrocer PH','user@freshgrocer.ng',NULL,'$2y$12$QT7vbhY1qVwZCpdWFnyp7u8MQjP3Lh5AZBYZ9ro.GwTbZoH6zx/N.',NULL,'2026-03-05 13:55:36','2026-04-14 13:55:38'),
(6,5,'Manager at TechZone Kano','user@techzone.ng',NULL,'$2y$12$UGYJXQeL/YlILDr7Ciu5M.vJYnY.9K7DYzWgvrmNSKghS51hA/sjG',NULL,'2026-02-20 13:55:36','2026-04-14 13:55:39'),
(7,6,'Manager at FashionHub Ibadan','user@fashionhub.ng',NULL,'$2y$12$ml/FlYcytRig2GP5J96h5.sXjTm098v//ECkcwBUcq2lGRSYOKPYK',NULL,'2025-12-20 13:55:36','2026-04-14 13:55:39'),
(8,7,'Manager at AutoParts Benin','user@autoparts.ng',NULL,'$2y$12$M3NcwNI6pTPHfLTZo1xCVOWRYahlcPi4Swr5fFlbZvkwnEJBQUltC',NULL,'2026-03-16 13:55:36','2026-04-14 13:55:40'),
(9,8,'Manager at GreenFarms Ilorin','user@greenfarms.ng',NULL,'$2y$12$2l9kN8FgqICp/aN5/sOmKuBGu2MOJesazGQEXYk2XJB1PgNpQ5xj2',NULL,'2026-01-31 13:55:36','2026-04-14 13:55:41'),
(10,9,'Manager at BookWorld Enugu','user@bookworld.ng',NULL,'$2y$12$koKKvqRe0CcjdKqPWxKGFOxnPb3.5NVcNudT8nviW26tuxx.iQm6e',NULL,'2026-02-13 13:55:36','2026-04-14 13:55:42'),
(11,10,'Manager at PharmaCare Jos','user@pharmacare.ng',NULL,'$2y$12$aRB3M1D93z03hCHaRPoy4ezrn.vWQNh28sCgAqJJvVsmwgZCfWTMa',NULL,'2025-11-22 13:55:36','2026-04-14 13:55:42'),
(12,11,'Manager at HomeStyle Warri','user@homestyle.ng',NULL,'$2y$12$hwtUC0R7TztpfZmsuj7D0.iNWA/ps7fjPii2WT5RoRoRBotQBHyNK',NULL,'2025-12-28 13:55:36','2026-04-14 13:55:43'),
(13,12,'Manager at SportZone Abeokuta','user@sportzone.ng',NULL,'$2y$12$6Vt.bDg1svTXEmUkUE7bdu6g60knnAsc1zOzxV0OFiS9GEOweCAcy',NULL,'2026-02-01 13:55:36','2026-04-14 13:55:44'),
(14,13,'Manager at BeautySpot Owerri','user@beautyspot.ng',NULL,'$2y$12$wcA/KTevfg37rXKaYBisr.5N.AckOq..nS0Tt03tsVkRjf9UeWvM6',NULL,'2026-02-07 13:55:36','2026-04-14 13:55:44');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `websites`
--

DROP TABLE IF EXISTS `websites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `websites` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `managed_by_database_connection` varchar(255) DEFAULT NULL COMMENT 'References the database connection key in your database.php',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `websites`
--

LOCK TABLES `websites` WRITE;
/*!40000 ALTER TABLE `websites` DISABLE KEYS */;
/*!40000 ALTER TABLE `websites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `whatsapp_accounts`
--

DROP TABLE IF EXISTS `whatsapp_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `whatsapp_accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `phone_number` varchar(255) NOT NULL,
  `provider` enum('meta','twilio') NOT NULL DEFAULT 'meta',
  `status` enum('active','inactive','pending') NOT NULL DEFAULT 'pending',
  `api_key` varchar(255) DEFAULT NULL,
  `api_secret` varchar(255) DEFAULT NULL,
  `webhook_url` varchar(255) DEFAULT NULL,
  `settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`settings`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `whatsapp_accounts_tenant_id_foreign` (`tenant_id`),
  CONSTRAINT `whatsapp_accounts_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `whatsapp_accounts`
--

LOCK TABLES `whatsapp_accounts` WRITE;
/*!40000 ALTER TABLE `whatsapp_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `whatsapp_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `whatsapp_messages`
--

DROP TABLE IF EXISTS `whatsapp_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `whatsapp_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint(20) unsigned NOT NULL,
  `whatsapp_account_id` bigint(20) unsigned DEFAULT NULL,
  `from_phone` varchar(30) NOT NULL,
  `to_phone` varchar(30) NOT NULL,
  `direction` enum('inbound','outbound') NOT NULL DEFAULT 'inbound',
  `message_type` varchar(255) NOT NULL DEFAULT 'text',
  `body` text DEFAULT NULL,
  `media_url` varchar(255) DEFAULT NULL,
  `external_message_id` varchar(255) DEFAULT NULL,
  `status` enum('received','sent','delivered','failed','read') NOT NULL DEFAULT 'received',
  `provider` varchar(255) NOT NULL DEFAULT 'meta',
  `processed_by_ai` tinyint(1) NOT NULL DEFAULT 0,
  `raw_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw_payload`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `whatsapp_messages_whatsapp_account_id_foreign` (`whatsapp_account_id`),
  KEY `whatsapp_messages_tenant_id_from_phone_index` (`tenant_id`,`from_phone`),
  KEY `whatsapp_messages_tenant_id_direction_index` (`tenant_id`,`direction`),
  KEY `whatsapp_messages_external_message_id_index` (`external_message_id`),
  CONSTRAINT `whatsapp_messages_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `whatsapp_messages_whatsapp_account_id_foreign` FOREIGN KEY (`whatsapp_account_id`) REFERENCES `whatsapp_accounts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `whatsapp_messages`
--

LOCK TABLES `whatsapp_messages` WRITE;
/*!40000 ALTER TABLE `whatsapp_messages` DISABLE KEYS */;
INSERT INTO `whatsapp_messages` VALUES
(1,2,NULL,'2349000000000','2348397975161','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-04-03 13:57:53','2026-04-14 13:57:53'),
(2,2,NULL,'2347448129999','2349000000000','inbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-27 13:57:53','2026-04-14 13:57:53'),
(3,2,NULL,'2348433473017','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-24 13:57:53','2026-04-14 13:57:53'),
(4,2,NULL,'2347493502202','2349000000000','inbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-24 13:57:53','2026-04-14 13:57:53'),
(5,2,NULL,'2347105186172','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-03 13:57:53','2026-04-14 13:57:53'),
(6,2,NULL,'2349000000000','2347601714082','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-17 13:57:53','2026-04-14 13:57:53'),
(7,2,NULL,'2347571050593','2349000000000','inbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-04-04 13:57:53','2026-04-14 13:57:53'),
(8,2,NULL,'2347735457604','2349000000000','inbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-26 13:57:53','2026-04-14 13:57:53'),
(9,2,NULL,'2349000000000','2347266836116','outbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-27 13:57:53','2026-04-14 13:57:53'),
(10,2,NULL,'2349000000000','2348860475304','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-04-13 13:57:53','2026-04-14 13:57:53'),
(11,2,NULL,'2349000000000','2348437102442','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-04-08 13:57:53','2026-04-14 13:57:53'),
(12,3,NULL,'2349000000000','2348020411539','outbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-08 13:57:53','2026-04-14 13:57:53'),
(13,3,NULL,'2349000000000','2348798272199','outbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-01 13:57:53','2026-04-14 13:57:53'),
(14,3,NULL,'2349000000000','2347780756236','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-15 13:57:53','2026-04-14 13:57:53'),
(15,3,NULL,'2349000000000','2348531367600','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-22 13:57:53','2026-04-14 13:57:53'),
(16,3,NULL,'2349000000000','2347166187365','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-18 13:57:53','2026-04-14 13:57:53'),
(17,4,NULL,'2349000000000','2348574767859','outbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-15 13:57:53','2026-04-14 13:57:53'),
(18,4,NULL,'2348412071035','2349000000000','inbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-10 13:57:53','2026-04-14 13:57:53'),
(19,4,NULL,'2349000000000','2348625304961','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-09 13:57:53','2026-04-14 13:57:53'),
(20,4,NULL,'2349000000000','2347746502412','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-20 13:57:53','2026-04-14 13:57:53'),
(21,4,NULL,'2349000000000','2347210151087','outbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-01 13:57:53','2026-04-14 13:57:53'),
(22,4,NULL,'2349000000000','2348147635225','outbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-02 13:57:53','2026-04-14 13:57:53'),
(23,4,NULL,'2349000000000','2347691605563','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-27 13:57:53','2026-04-14 13:57:53'),
(24,4,NULL,'2349000000000','2348193146831','outbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-12 13:57:53','2026-04-14 13:57:53'),
(25,5,NULL,'2349000000000','2348210526573','outbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-20 13:57:53','2026-04-14 13:57:53'),
(26,5,NULL,'2348013220184','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-21 13:57:53','2026-04-14 13:57:53'),
(27,5,NULL,'2347659872774','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-14 13:57:53','2026-04-14 13:57:53'),
(28,5,NULL,'2348222346636','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-19 13:57:53','2026-04-14 13:57:53'),
(29,5,NULL,'2348618589979','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-23 13:57:53','2026-04-14 13:57:53'),
(30,5,NULL,'2348379608526','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-10 13:57:53','2026-04-14 13:57:53'),
(31,5,NULL,'2347480933731','2349000000000','inbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-17 13:57:53','2026-04-14 13:57:53'),
(32,5,NULL,'2348494756149','2349000000000','inbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-04-09 13:57:53','2026-04-14 13:57:53'),
(33,5,NULL,'2348894444669','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-07 13:57:53','2026-04-14 13:57:53'),
(34,6,NULL,'2347166670579','2349000000000','inbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-04-01 13:57:53','2026-04-14 13:57:53'),
(35,6,NULL,'2347397680361','2349000000000','inbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-29 13:57:53','2026-04-14 13:57:53'),
(36,6,NULL,'2348088834941','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-17 13:57:53','2026-04-14 13:57:53'),
(37,6,NULL,'2349000000000','2347099525317','outbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-03-19 13:57:53','2026-04-14 13:57:53'),
(38,6,NULL,'2349000000000','2348027195359','outbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-06 13:57:53','2026-04-14 13:57:53'),
(39,6,NULL,'2347369697600','2349000000000','inbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-10 13:57:53','2026-04-14 13:57:53'),
(40,7,NULL,'2347201270579','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-28 13:57:53','2026-04-14 13:57:53'),
(41,7,NULL,'2349000000000','2348225704490','outbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-10 13:57:53','2026-04-14 13:57:53'),
(42,7,NULL,'2349000000000','2348877477525','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-30 13:57:53','2026-04-14 13:57:53'),
(43,7,NULL,'2347611144393','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-06 13:57:53','2026-04-14 13:57:53'),
(44,7,NULL,'2348079409971','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-23 13:57:53','2026-04-14 13:57:53'),
(45,7,NULL,'2349000000000','2347791858082','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-28 13:57:53','2026-04-14 13:57:53'),
(46,7,NULL,'2348019607776','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-17 13:57:53','2026-04-14 13:57:53'),
(47,7,NULL,'2347126921619','2349000000000','inbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-31 13:57:53','2026-04-14 13:57:53'),
(48,7,NULL,'2349000000000','2347341065928','outbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-04-12 13:57:53','2026-04-14 13:57:53'),
(49,7,NULL,'2349000000000','2347045538217','outbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-09 13:57:53','2026-04-14 13:57:53'),
(50,7,NULL,'2347435373027','2349000000000','inbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-03-25 13:57:53','2026-04-14 13:57:53'),
(51,8,NULL,'2347426800052','2349000000000','inbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-20 13:57:53','2026-04-14 13:57:53'),
(52,8,NULL,'2349000000000','2347921888042','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-27 13:57:53','2026-04-14 13:57:53'),
(53,8,NULL,'2347938356353','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-04 13:57:53','2026-04-14 13:57:53'),
(54,8,NULL,'2348185711909','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-26 13:57:53','2026-04-14 13:57:53'),
(55,8,NULL,'2349000000000','2348073932419','outbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-21 13:57:53','2026-04-14 13:57:53'),
(56,8,NULL,'2347681554412','2349000000000','inbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-22 13:57:53','2026-04-14 13:57:53'),
(57,8,NULL,'2349060015796','2349000000000','inbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-03-24 13:57:53','2026-04-14 13:57:53'),
(58,9,NULL,'2349000000000','2348346093920','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-17 13:57:53','2026-04-14 13:57:53'),
(59,9,NULL,'2348911314248','2349000000000','inbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-04-05 13:57:53','2026-04-14 13:57:53'),
(60,9,NULL,'2349051310910','2349000000000','inbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-16 13:57:53','2026-04-14 13:57:53'),
(61,9,NULL,'2347894188553','2349000000000','inbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-04-03 13:57:53','2026-04-14 13:57:53'),
(62,9,NULL,'2347845041249','2349000000000','inbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-03-19 13:57:53','2026-04-14 13:57:53'),
(63,9,NULL,'2348697452306','2349000000000','inbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-04 13:57:53','2026-04-14 13:57:53'),
(64,9,NULL,'2348926856108','2349000000000','inbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-01 13:57:53','2026-04-14 13:57:53'),
(65,9,NULL,'2348690107261','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-19 13:57:53','2026-04-14 13:57:53'),
(66,9,NULL,'2349000000000','2347134679527','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-16 13:57:53','2026-04-14 13:57:53'),
(67,10,NULL,'2349000000000','2347935431289','outbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-09 13:57:53','2026-04-14 13:57:53'),
(68,10,NULL,'2348058554632','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-04 13:57:53','2026-04-14 13:57:53'),
(69,10,NULL,'2347780719037','2349000000000','inbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-26 13:57:53','2026-04-14 13:57:53'),
(70,10,NULL,'2349000000000','2347834319401','outbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-30 13:57:53','2026-04-14 13:57:53'),
(71,10,NULL,'2349000000000','2348219033485','outbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-03-28 13:57:53','2026-04-14 13:57:53'),
(72,10,NULL,'2347387312350','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-23 13:57:53','2026-04-14 13:57:53'),
(73,10,NULL,'2349000000000','2349052252397','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-17 13:57:53','2026-04-14 13:57:53'),
(74,10,NULL,'2349000000000','2348262200407','outbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-05 13:57:53','2026-04-14 13:57:53'),
(75,10,NULL,'2347637912106','2349000000000','inbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-04-03 13:57:53','2026-04-14 13:57:53'),
(76,10,NULL,'2349000000000','2347119180242','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-24 13:57:53','2026-04-14 13:57:53'),
(77,11,NULL,'2348468902905','2349000000000','inbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-04-05 13:57:53','2026-04-14 13:57:53'),
(78,11,NULL,'2349000000000','2347468075674','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-26 13:57:53','2026-04-14 13:57:53'),
(79,11,NULL,'2348676746359','2349000000000','inbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-20 13:57:53','2026-04-14 13:57:53'),
(80,11,NULL,'2349000000000','2347285098753','outbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-21 13:57:53','2026-04-14 13:57:53'),
(81,11,NULL,'2349000000000','2347821334791','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-13 13:57:53','2026-04-14 13:57:53'),
(82,11,NULL,'2349000000000','2347956028937','outbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-23 13:57:53','2026-04-14 13:57:53'),
(83,11,NULL,'2347988939824','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-08 13:57:53','2026-04-14 13:57:53'),
(84,11,NULL,'2349000000000','2347382337845','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-23 13:57:53','2026-04-14 13:57:53'),
(85,11,NULL,'2347388030921','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-06 13:57:53','2026-04-14 13:57:53'),
(86,11,NULL,'2348499005657','2349000000000','inbound','text','Do you have stock?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-06 13:57:53','2026-04-14 13:57:53'),
(87,11,NULL,'2349000000000','2348699892233','outbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-27 13:57:53','2026-04-14 13:57:53'),
(88,12,NULL,'2349000000000','2348171668611','outbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-31 13:57:53','2026-04-14 13:57:53'),
(89,12,NULL,'2347877444121','2349000000000','inbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-30 13:57:53','2026-04-14 13:57:53'),
(90,12,NULL,'2349000000000','2347726947411','outbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-09 13:57:53','2026-04-14 13:57:53'),
(91,12,NULL,'2348162998862','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-13 13:57:53','2026-04-14 13:57:53'),
(92,12,NULL,'2349000000000','2347847623382','outbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-18 13:57:53','2026-04-14 13:57:53'),
(93,12,NULL,'2349000000000','2348830848334','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-04-11 13:57:53','2026-04-14 13:57:53'),
(94,12,NULL,'2349000000000','2347253662726','outbound','text','Please send receipt',NULL,NULL,'delivered','meta',0,NULL,'2026-03-17 13:57:53','2026-04-14 13:57:53'),
(95,12,NULL,'2349000000000','2347244844015','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-18 13:57:53','2026-04-14 13:57:53'),
(96,12,NULL,'2349000000000','2347710611687','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-31 13:57:53','2026-04-14 13:57:53'),
(97,12,NULL,'2349000000000','2348415575910','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-28 13:57:53','2026-04-14 13:57:53'),
(98,12,NULL,'2347126130752','2349000000000','inbound','text','When will delivery arrive?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-13 13:57:53','2026-04-14 13:57:53'),
(99,12,NULL,'2347028374236','2349000000000','inbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-21 13:57:53','2026-04-14 13:57:53'),
(100,12,NULL,'2349000000000','2347406274078','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-04-12 13:57:53','2026-04-14 13:57:53'),
(101,12,NULL,'2347617405794','2349000000000','inbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-26 13:57:53','2026-04-14 13:57:53'),
(102,12,NULL,'2347822616701','2349000000000','inbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-03-27 13:57:53','2026-04-14 13:57:53'),
(103,13,NULL,'2349016922138','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-03-20 13:57:53','2026-04-14 13:57:53'),
(104,13,NULL,'2349000000000','2347185870322','outbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-04-10 13:57:53','2026-04-14 13:57:53'),
(105,13,NULL,'2347165609598','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-08 13:57:53','2026-04-14 13:57:53'),
(106,13,NULL,'2347128467448','2349000000000','inbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-31 13:57:53','2026-04-14 13:57:53'),
(107,13,NULL,'2347851269741','2349000000000','inbound','text','What is the price?',NULL,NULL,'delivered','meta',0,NULL,'2026-03-18 13:57:53','2026-04-14 13:57:53'),
(108,13,NULL,'2349000000000','2347164653537','outbound','text','Hello, I want to order',NULL,NULL,'delivered','meta',0,NULL,'2026-04-08 13:57:53','2026-04-14 13:57:53'),
(109,13,NULL,'2349021862013','2349000000000','inbound','text','Thank you!',NULL,NULL,'delivered','meta',0,NULL,'2026-04-03 13:57:53','2026-04-14 13:57:53');
/*!40000 ALTER TABLE `whatsapp_messages` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-10 19:09:20
