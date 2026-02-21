# Base image
From nginx:1.29.5-alpine 

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Creating dir

WORKDIR /app

# Copy files to app

COPY . /usr/share/nginx/html/

#Run the package

RUN nginx

#Expose Port

EXPOSE 3000

CMD["nginx", "-g", "daemon off;"]
