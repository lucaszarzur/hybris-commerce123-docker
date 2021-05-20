FROM mysql:5.7

# Add a database
ENV MYSQL_DATABASE commerce123mod

# Set root passwd
ENV MYSQL_ROOT_PASSWORD root

# Add a new user
ENV MYSQL_USER=docker_hybris
ENV MYSQL_PASSWORD=docker_hybris

# EXPOSE 3306

# Add the content of the sql-scripts/ directory to your image
# All scripts in docker-entrypoint-initdb.d/ are automatically
# executed during container startup
# COPY ./sql-scripts/ /docker-entrypoint-initdb.d