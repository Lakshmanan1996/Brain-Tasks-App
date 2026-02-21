# Base image
From nginx:1.29.5-alpine 

# Creating dir

WORKDIR /app

# Copy files to app

Copy . .

#Run the package

RUN nginx

#Expose Port

EXPOSE 3000

CMD["nginx", "-g", "daemon off;"]
