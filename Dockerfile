# Use the Windows Server Core base image
FROM mcr.microsoft.com/windows/servercore

# Set environment variables for Apache directory and download URL
ENV APACHE_DIR="C:\\Apache24" \
    APACHE_DOWNLOAD_URL="https://www.apachelounge.com/download/VC15/binaries/httpd-2.4.54-win64-VS16.zip"

# Download and unzip Apache HTTP Server
RUN powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
    "Invoke-WebRequest -Uri $env:APACHE_DOWNLOAD_URL -OutFile 'C:\\apache.zip'; \
    Expand-Archive -Path 'C:\\apache.zip' -DestinationPath 'C:\\'; \
    Remove-Item -Force 'C:\\apache.zip'"

# Set the working directory
WORKDIR C:/Apache24/htdocs

# Copy the local files to the container's working directory
COPY www/ .

# Expose port 8080 for the web server
EXPOSE 8080

# Start Apache HTTP Server on port 8080
CMD ["C:\\Apache24\\bin\\httpd.exe", "-f", "C:\\Apache24\\conf\\httpd.conf", "-D", "FOREGROUND"]
