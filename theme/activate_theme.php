<?php
/**
 * One-off script to activate this theme. Run from CLI inside the container.
 */
if (php_sapi_name() !== 'cli') {
    die('Run from CLI only.');
}
$theme_dir = dirname(__FILE__);
$slug = basename($theme_dir);
$wp_load = $theme_dir . '/../../wp-load.php';
if (!is_file($wp_load)) {
    fwrite(STDERR, "activate_theme.php: wp-load.php not found\n");
    exit(1);
}
define('WP_USE_THEMES', false);
require_once $wp_load;
if (!function_exists('switch_theme')) {
    fwrite(STDERR, "activate_theme.php: switch_theme not found\n");
    exit(1);
}
switch_theme($slug);
echo "Active theme set to: " . $slug . "\n";
