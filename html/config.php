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
$config['db_host'] = 'db';
$config['db_user'] = 'observium';
$config['db_pass'] = 'observium';
$config['db_name'] = 'observium';

// Base URL
$config['base_url'] = "/";

// Default user
$config['auth_mysql_users'][0]['username'] = 'admin';
$config['auth_mysql_users'][0]['password'] = 'password';
$config['auth_mysql_users'][0]['level'] = 10;

