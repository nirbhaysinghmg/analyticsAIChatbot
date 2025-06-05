-- 1) users table (no FKs yet)
CREATE TABLE `users` (
  `user_id` VARCHAR(36) NOT NULL,
  `first_seen_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `last_active_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `total_sessions` INT DEFAULT 0,
  `total_conversations` INT DEFAULT 0,
  `total_messages` INT DEFAULT 0,
  `total_duration` INT DEFAULT 0,
  `is_active` TINYINT(1) DEFAULT 0,
  `last_page_url` VARCHAR(255) DEFAULT NULL,
  `user_type` ENUM('new','returning') DEFAULT 'new',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- 2) sessions table (FK → users)
CREATE TABLE `sessions` (
  `session_id` VARCHAR(36) NOT NULL,
  `user_id` VARCHAR(36) DEFAULT NULL,
  `start_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` TIMESTAMP NULL DEFAULT NULL,
  `duration` INT DEFAULT 0,
  `page_url` VARCHAR(255) DEFAULT NULL,
  `device_type` VARCHAR(50) DEFAULT NULL,
  `browser` VARCHAR(50) DEFAULT NULL,
  `os` VARCHAR(50) DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `message_count` INT DEFAULT 0,
  `last_message_time` DATETIME DEFAULT NULL,
  `status` ENUM('active','completed','error') DEFAULT 'active',
  PRIMARY KEY (`session_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_start_time` (`start_time`),
  CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- 3) conversations table (FK → sessions, users)
CREATE TABLE `conversations` (
  `conversation_id` VARCHAR(36) NOT NULL,
  `session_id` VARCHAR(36) DEFAULT NULL,
  `user_id` VARCHAR(36) DEFAULT NULL,
  `start_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` TIMESTAMP NULL DEFAULT NULL,
  `duration` INT DEFAULT 0,
  `status` ENUM('active','completed','handover','dropped') DEFAULT 'active',
  `handover_reason` VARCHAR(255) DEFAULT NULL,
  `resolution_status` ENUM('resolved','unresolved','handover') DEFAULT 'unresolved',
  PRIMARY KEY (`conversation_id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `conversations_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`),
  CONSTRAINT `conversations_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- 4) messages table (FK → conversations, users)
CREATE TABLE `messages` (
  `message_id` VARCHAR(36) NOT NULL,
  `conversation_id` VARCHAR(36) DEFAULT NULL,
  `user_id` VARCHAR(36) DEFAULT NULL,
  `timestamp` DATETIME DEFAULT NULL,
  `message_type` ENUM('user','bot','system') DEFAULT NULL,
  `content` TEXT,
  `intent` VARCHAR(100) DEFAULT NULL,
  `confidence_score` FLOAT DEFAULT NULL,
  `is_fallback` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`message_id`),
  KEY `idx_conversation_id` (`conversation_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`conversation_id`),
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- 5) chatbot_close_events table (FK → users)
CREATE TABLE `chatbot_close_events` (
  `close_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(36) NOT NULL,
  `session_id` VARCHAR(36) DEFAULT NULL,
  `closed_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `time_spent_seconds` INT NOT NULL,
  `last_user_message` TEXT,
  `last_bot_message` TEXT,
  PRIMARY KEY (`close_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `chatbot_close_events_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- 6) human_handover table (FK → users)
CREATE TABLE `human_handover` (
  `handover_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(36) NOT NULL,
  `session_id` VARCHAR(36) DEFAULT NULL,
  `requested_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `method` ENUM('chat','call','email') NOT NULL,
  `issues` TEXT,
  `other_text` VARCHAR(255) DEFAULT NULL,
  `support_option` ENUM('rephrase','talk-exec') NOT NULL,
  `last_message` TEXT,
  `status` ENUM('pending','completed') DEFAULT 'pending',
  PRIMARY KEY (`handover_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `human_handover_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- 7) lead_analytics table (no FK dependencies)
CREATE TABLE `lead_analytics` (
  `lead_id` VARCHAR(36) NOT NULL,
  `lead_type` VARCHAR(50) NOT NULL DEFAULT 'appointment_scheduled',
  `name` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`lead_id`),
  KEY `idx_lead_type` (`lead_type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
