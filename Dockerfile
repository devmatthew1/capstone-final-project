#Step 1
FROM nginx

#Step 2
#Removing pre loaded homepage
RUN rm /usr/share/nginx/html/index.html

#Step 3
#Copying our page
COPY index.html /usr/share/nginx/html