<?php
get_header();
?>
<main class="site-main">
  <div class="site-container">
    <?php if ( have_posts() ) : while ( have_posts() ) : the_post(); ?>
      <article <?php post_class(); ?>>
        <h1><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h1>
        <?php the_content(); ?>
      </article>
    <?php endwhile; else : ?>
      <p>No content found.</p>
    <?php endif; ?>
  </div>
</main>
<?php get_footer(); ?>
