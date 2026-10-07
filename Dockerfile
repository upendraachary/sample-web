FROM nginx:alpine
# Copy your local index.html directly into Nginx's default public folder
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
