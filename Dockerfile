# WordPress app image: theme + plugins baked in. Built by wpdevops workflow.
ARG THEME_SLUG=wordpress-starter
FROM wordpress:latest
ARG THEME_SLUG=wordpress-starter
COPY theme/ /var/www/html/wp-content/themes/${THEME_SLUG}/
COPY plugins/ /var/www/html/wp-content/plugins/
RUN chown -R www-data:www-data /var/www/html/wp-content/themes /var/www/html/wp-content/plugins
