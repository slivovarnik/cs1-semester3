const express = require('express');
const { Pool } = require('pg');
const AWS = require('@aws-sdk/client-secrets-manager');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Get database credentials from Secrets Manager
// This runs at startup and retrieves credentials privately
// through the VPC endpoint — no credentials in code or env vars
async function getDbCredentials() {
  const client = new AWS.SecretsManagerClient({ 
    region: process.env.AWS_REGION || 'eu-central-1' 
  });
  
  const response = await client.send(
    new AWS.GetSecretValueCommand({
      SecretId: process.env.DB_SECRET_ARN
    })
  );
  
  return JSON.parse(response.SecretString);
}

let pool;

// Initialize database connection and create tables if they do not exist
// Using CREATE TABLE IF NOT EXISTS means the table persists across
// redeployments — if it already exists nothing happens
// This satisfies REQ-NCA-P3-04 persistent storage requirement
async function initDatabase() {
  const creds = await getDbCredentials();
  
  pool = new Pool({
    host: creds.host,
    port: creds.port,
    database: creds.dbname,
    user: creds.username,
    password: creds.password,
    ssl: { rejectUnauthorized: false }
  });

  // Create database if it does not exist
  // Then create the employees table with the exact fields
  // required by CS3: ID, Name, Email, Department, Status, Role
  await pool.query(`
    CREATE TABLE IF NOT EXISTS employees (
      id          SERIAL PRIMARY KEY,
      name        VARCHAR(100) NOT NULL,
      email       VARCHAR(150) NOT NULL UNIQUE,
      department  VARCHAR(100) NOT NULL,
      status      VARCHAR(20)  NOT NULL DEFAULT 'active',
      role        VARCHAR(100) NOT NULL,
      created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  console.log('Database initialized successfully');
}

// Health check endpoint
// Used by Kubernetes liveness and readiness probes
// If this returns 200 the pod is considered healthy
app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy' });
});

// Get all employees
// Returns the full employee list for the frontend table
app.get('/api/employees', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM employees ORDER BY created_at DESC'
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching employees:', err);
    res.status(500).json({ error: 'Failed to fetch employees' });
  }
});

// Create a new employee
// Called by the frontend form when adding a new employee
// This is the onboarding trigger point
app.post('/api/employees', async (req, res) => {
  const { name, email, department, role } = req.body;
  
  if (!name || !email || !department || !role) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO employees (name, email, department, status, role)
       VALUES ($1, $2, $3, 'active', $4)
       RETURNING *`,
      [name, email, department, role]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    if (err.code === '23505') {
      return res.status(409).json({ error: 'Email already exists' });
    }
    console.error('Error creating employee:', err);
    res.status(500).json({ error: 'Failed to create employee' });
  }
});

// Update employee status (offboarding)
// Sets status to inactive when an employee is offboarded
// This is called by the offboarding workflow
app.patch('/api/employees/:id/offboard', async (req, res) => {
  const { id } = req.params;
  
  try {
    const result = await pool.query(
      `UPDATE employees 
       SET status = 'inactive', updated_at = CURRENT_TIMESTAMP
       WHERE id = $1
       RETURNING *`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Employee not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error offboarding employee:', err);
    res.status(500).json({ error: 'Failed to offboard employee' });
  }
});

// Delete employee
app.delete('/api/employees/:id', async (req, res) => {
  const { id } = req.params;
  
  try {
    await pool.query('DELETE FROM employees WHERE id = $1', [id]);
    res.status(204).send();
  } catch (err) {
    console.error('Error deleting employee:', err);
    res.status(500).json({ error: 'Failed to delete employee' });
  }
});

// Start the server
async function start() {
  try {
    await initDatabase();
    app.listen(3000, () => {
      console.log('HR Backend running on port 3000');
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

start();