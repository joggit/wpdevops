<?php
if ( ! defined( 'ABSPATH' ) ) exit;
function wp_starter_setup() {
  add_theme_support( 'title-tag' );
  add_theme_support( 'post-thumbnails' );
  add_theme_support( 'html5', array( 'search-form', 'comment-form', 'comment-list', 'gallery', 'caption' ) );
  register_nav_menus( array( 'primary' => 'Primary Menu' ) );
}
add_action( 'after_setup_theme', 'wp_starter_setup' );
function wp_starter_scripts() {
  wp_enqueue_style( 'wp-starter-style', get_stylesheet_uri(), array(), wp_get_theme()->get( 'Version' ) );
}
add_action( 'wp_enqueue_scripts', 'wp_starter_scripts' );
