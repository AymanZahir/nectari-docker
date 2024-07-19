# Use the official Microsoft SQL Server image as the base image
FROM mcr.microsoft.com/mssql/server:2019-latest AS base

# Set environment variables for SQL Server
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=a20ZYman9595!!

# Expose the default port for SQL Server
EXPOSE 1433

# Copy local scripts and data into the Docker image
COPY --chmod=777 entrypoint.sh /usr/src/app/entrypoint.sh
COPY --chmod=777 restore_db.sh /usr/src/app/restore_db.sh
COPY --chmod=777 data.sql /usr/src/app/data.sql

# Verify that the files are copied correctly
RUN ls -l /usr/src/app/

# Healthcheck parameters to validate that the DB is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 CMD /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" || exit 1

# Run SQL Server initialization and data restore using entrypoint script
ENTRYPOINT ["/bin/bash", "/usr/src/app/entrypoint.sh"]

# Clean up unnecessary files and stop SQL Server
USER root
RUN rm -f /usr/src/app/data.sql

# Start SQL Server and then run the restore_db.sh script
CMD /bin/bash /usr/src/app/restore_db.sh
