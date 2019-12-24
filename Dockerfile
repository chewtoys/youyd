FROM node
MAINTAINER GuoGuang
ENV NODE_ENV=production
ENV HOST 0.0.0.0
RUN mkdir -p /asdfasdf
COPY . /asdfasdf
WORKDIR /asdfasdf
RUN pwd
EXPOSE 3000
RUN npm install
RUN npm install sass-loader
RUN npm install node-sass
RUN npm run build
CMD ["npm", "start"]
