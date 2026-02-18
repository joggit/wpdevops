<?php
/**
 * Front page template (optional home page).
 */
get_header();
?>

<main class="site-main">
  <div class="site-container">
    <h1><?php bloginfo( 'name' ); ?></h1>
    <p><?php bloginfo( 'description' ); ?></p>
    <p><?php esc_html_e( 'WordPress Starter – customise this theme and deploy with the deployer.', 'wp-starter' ); ?></p>
  </div>
</main>

<?php get_footer(); ?>
