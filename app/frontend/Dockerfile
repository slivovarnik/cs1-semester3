# Using Nginx Alpine for serving the static frontend
# Alpine keeps the image small and reduces attack surface
# Nginx is a production-grade web server suitable for 
# serving static files and proxying API requests
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/

# Copy frontend files
COPY src/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]