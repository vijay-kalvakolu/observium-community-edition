<?php

/**
 * Observium
 *
 * This file is part of Observium.
 *
 * @package    observium
 * @subpackage config
 * @copyright  (C) 2006-2024 Adam Armstrong
 *
 */

// Database config
$config['db_host'] = getenv('DB_HOST') ?: 'db';
$config['db_user'] = getenv('DB_USER') ?: 'observium';
$config['db_pass'] = getenv('DB_PASSWORD') ?: 'observium';
$config['db_name'] = getenv('DB_NAME') ?: 'observium';

// Base URL
$config['base_url'] = "/";

// Default user
$config['auth_mysql_users'][0]['username'] = getenv('OBSERVIUM_ADMIN_USER') ?: 'admin';
$config['auth_mysql_users'][0]['password'] = getenv('OBSERVIUM_ADMIN_PASS') ?: 'password';
$config['auth_mysql_users'][0]['level'] = 10;