(cd ~/details/ && git pull) || git clone -b dev git@github.com:kuraigi/itkmitl-bookinfo-details.git ~/details/
(cd ~/ratings/ && git pull) || git clone -b dev git@github.com:kuraigi/itkmitl-bookinfo-ratings.git ~/ratings/
(cd ~/productpage/ && git pull) || git clone -b dev git@github.com:kuraigi/itkmitl-bookinfo-productpage.git ~/productpage/
(cd ~/reviews/ && git pull) || git clone -b dev git@github.com:kuraigi/itkmitl-bookinfo-reviews.git ~/reviews/
docker build -t ratings ~/ratings
docker build -t details ~/details
docker build -t reviews ~/reviews
docker build -t productpage ~/productpage
docker run -d --name mongodb -p 27017:27017 -v $(pwd)/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2
docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings
docker run -d --name details -p 8081:8081 details
docker run -d --name reviews -p 8082:8082 --link ratings:ratings -e 'RATINGS_SERVICE=http://ratings:8080' -e 'ENABLE_RATINGS=true' reviews
docker run -d --name productpage -p 8083:8083 --link details:details --link ratings:ratings --link reviews:reviews -e 'REVIEWS_HOSTNAME=http://reviews:8082' -e 'RATINGS_HOSTNAME=http://ratings:8080' -e 'DETAILS_HOSTNAME=http://details:8081' productpage