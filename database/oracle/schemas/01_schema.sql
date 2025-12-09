-- ALGODON Oracle Database Schema
-- Run this script to create all tables, indexes, and triggers

-- Users table
CREATE TABLE users (
  id VARCHAR2(36) PRIMARY KEY,
  email VARCHAR2(255) UNIQUE NOT NULL,
  name VARCHAR2(255),
  image VARCHAR2(500),
  role VARCHAR2(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  stripe_customer_id VARCHAR2(100),
  square_customer_id VARCHAR2(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subscriptions table
CREATE TABLE subscriptions (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) UNIQUE NOT NULL,
  tier VARCHAR2(20) DEFAULT 'free' CHECK (tier IN ('free', 'trial', 'pro')),
  status VARCHAR2(20) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired')),
  trial_start_date TIMESTAMP,
  trial_end_date TIMESTAMP,
  subscription_start_date TIMESTAMP,
  subscription_end_date TIMESTAMP,
  payment_method VARCHAR2(50) CHECK (payment_method IN ('stripe', 'square', 'cashapp', 'crypto', 'web3')),
  stripe_subscription_id VARCHAR2(100),
  square_subscription_id VARCHAR2(100),
  requests_used NUMBER DEFAULT 0,
  requests_limit NUMBER DEFAULT 22,
  auto_renew NUMBER(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_subscription_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Projects table
CREATE TABLE projects (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  name VARCHAR2(255) NOT NULL,
  description VARCHAR2(1000),
  language VARCHAR2(50),
  is_public NUMBER(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_executed_at TIMESTAMP,
  CONSTRAINT fk_project_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Project files table
CREATE TABLE project_files (
  id VARCHAR2(36) PRIMARY KEY,
  project_id VARCHAR2(36) NOT NULL,
  path VARCHAR2(500) NOT NULL,
  content CLOB,
  language VARCHAR2(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_file_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  CONSTRAINT uk_file_project_path UNIQUE (project_id, path)
);

-- User requests table (for tracking free tier usage)
CREATE TABLE user_requests (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  request_type VARCHAR2(50) NOT NULL,
  status VARCHAR2(20) DEFAULT 'success' CHECK (status IN ('success', 'failed')),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  metadata CLOB,
  CONSTRAINT fk_request_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Code executions table
CREATE TABLE code_executions (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  project_id VARCHAR2(36),
  language VARCHAR2(50) NOT NULL,
  code CLOB NOT NULL,
  input CLOB,
  output CLOB,
  error CLOB,
  execution_time NUMBER,
  status VARCHAR2(20) DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed', 'timeout')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_execution_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_execution_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL
);

-- Payments table
CREATE TABLE payments (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  amount NUMBER(10, 2) NOT NULL,
  currency VARCHAR2(10) DEFAULT 'USD',
  provider VARCHAR2(50) NOT NULL CHECK (provider IN ('stripe', 'square', 'cashapp', 'crypto', 'web3')),
  status VARCHAR2(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  transaction_id VARCHAR2(255),
  metadata CLOB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- AI conversations table
CREATE TABLE ai_conversations (
  id VARCHAR2(36) PRIMARY KEY,
  user_id VARCHAR2(36) NOT NULL,
  project_id VARCHAR2(36),
  model VARCHAR2(50) NOT NULL,
  messages CLOB NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_conversation_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_conversation_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL
);

-- AI model configurations table
CREATE TABLE ai_model_configs (
  id VARCHAR2(36) PRIMARY KEY,
  name VARCHAR2(100) UNIQUE NOT NULL,
  provider VARCHAR2(50) NOT NULL,
  model_id VARCHAR2(100) NOT NULL,
  api_key_encrypted VARCHAR2(500),
  temperature NUMBER(3, 2) DEFAULT 0.7,
  max_tokens NUMBER DEFAULT 2000,
  is_active NUMBER(1) DEFAULT 1,
  rate_limit_per_user NUMBER DEFAULT 50,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_project_files_project_id ON project_files(project_id);
CREATE INDEX idx_user_requests_user_id ON user_requests(user_id);
CREATE INDEX idx_user_requests_timestamp ON user_requests(timestamp);
CREATE INDEX idx_code_executions_user_id ON code_executions(user_id);
CREATE INDEX idx_code_executions_project_id ON code_executions(project_id);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE TRIGGER update_users_timestamp
  BEFORE UPDATE ON users
  FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER update_subscriptions_timestamp
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER update_projects_timestamp
  BEFORE UPDATE ON projects
  FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER update_project_files_timestamp
  BEFORE UPDATE ON project_files
  FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Insert default AI models
INSERT INTO ai_model_configs (id, name, provider, model_id, is_active, temperature, max_tokens) VALUES
  (SYS_GUID(), 'GPT-4 Turbo', 'openai', 'gpt-4-turbo-preview', 1, 0.7, 4096),
  (SYS_GUID(), 'Claude 3 Opus', 'anthropic', 'claude-3-opus-20240229', 1, 0.7, 4096),
  (SYS_GUID(), 'Gemini Pro', 'google', 'gemini-pro', 1, 0.7, 2048);

COMMIT;
